package http

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"regexp"
	"strconv"
	"time"

	"github.com/rs/zerolog"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/app"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/api"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/telemetry"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

// Use cases as the handlers consume them.
type (
	correctionSubmitter interface {
		Execute(ctx context.Context, in app.CorrectionInput) (domain.ReceiptID, error)
	}
	telemetryRecorder interface {
		Execute(ctx context.Context, a telemetry.Aggregate, att *domain.Attestation) error
	}
	evidenceGetter interface {
		Execute(ctx context.Context, profileID string) ([]byte, error)
	}
)

var profileIDPattern = regexp.MustCompile(`^[a-z]{2}\.[a-z0-9_]+\.[a-z0-9_]+$|^engine\.default$`)

type handlers struct {
	validator   *validate.Validator
	corrections correctionSubmitter
	telemetry   telemetryRecorder
	evidence    evidenceGetter
	ready       ports.Pinger
	clock       ports.Clock
	log         zerolog.Logger
}

func (h handlers) postCorrection(w http.ResponseWriter, r *http.Request, body []byte) {
	req, err := api.Decode[api.CorrectionRequest](h.validator, validate.CorrectionRequest, body)
	if err != nil {
		writeProblem(w, r, problemInvalidBody, err.Error())
		return
	}
	in := app.CorrectionInput{Kind: domain.CorrectionKind(req.Kind), Country: req.Country}
	if in.PayloadJSON, err = json.Marshal(req.Payload); err != nil {
		writeProblem(w, r, problemInternal, "")
		return
	}
	if req.RoundedLat != nil && req.RoundedLon != nil {
		loc, err := domain.NewRoundedLocation(*req.RoundedLat, *req.RoundedLon)
		if err != nil {
			writeProblem(w, r, problemInvalidBody, "coordinates must be rounded to 2 decimals on the device")
			return
		}
		in.Location = &loc
	}
	if in.Attestation, err = parseAttestation(r, body); err != nil {
		writeProblem(w, r, problemInvalidAttestation, "")
		return
	}
	id, err := h.corrections.Execute(r.Context(), in)
	if err != nil {
		h.writeError(w, r, err)
		return
	}
	h.writeJSON(w, r, http.StatusCreated, api.CorrectionReceipt{ReceiptID: string(id)})
}

func (h handlers) postTelemetry(w http.ResponseWriter, r *http.Request, body []byte) {
	agg, err := api.Decode[telemetry.Aggregate](h.validator, validate.TelemetryAggregate, body)
	if err != nil {
		writeProblem(w, r, problemInvalidBody, err.Error())
		return
	}
	att, err := parseAttestation(r, body)
	if err != nil {
		writeProblem(w, r, problemInvalidAttestation, "")
		return
	}
	if err := h.telemetry.Execute(r.Context(), agg, att); err != nil {
		h.writeError(w, r, err)
		return
	}
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(http.StatusNoContent)
}

func (h handlers) getEvidence(w http.ResponseWriter, r *http.Request) {
	id := r.PathValue("id")
	if !profileIDPattern.MatchString(id) {
		writeProblem(w, r, problemNotFound, "")
		return
	}
	summary, err := h.evidence.Execute(r.Context(), id)
	if err != nil {
		h.writeError(w, r, err)
		return
	}
	if err := h.validator.Validate(validate.EvidenceSummary, summary); err != nil {
		h.log.Error().Err(err).Str("profileId", id).Msg("stored evidence summary does not match its schema")
		writeProblem(w, r, problemInternal, "")
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "public, max-age=3600")
	w.WriteHeader(http.StatusOK)
	// G705: the body is served as application/json after schema validation, never as HTML.
	_, _ = w.Write(summary) //nolint:gosec // the client may be gone; nothing left to report to
}

func (h handlers) healthz(w http.ResponseWriter, r *http.Request) {
	h.writeJSON(w, r, http.StatusOK, map[string]string{"status": "ok"})
}

func (h handlers) readyz(w http.ResponseWriter, r *http.Request) {
	ctx, cancel := context.WithTimeout(r.Context(), 2*time.Second)
	defer cancel()
	if err := h.ready.Ping(ctx); err != nil {
		h.log.Warn().Err(err).Msg("not ready")
		writeProblem(w, r, problemUnavailable, "")
		return
	}
	h.writeJSON(w, r, http.StatusOK, map[string]string{"status": "ready"})
}

func (h handlers) notFound(w http.ResponseWriter, r *http.Request) {
	writeProblem(w, r, problemNotFound, "")
}

func methodNotAllowed(allow string) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Allow", allow)
		writeProblem(w, r, problemMethodNotAllowed, "")
	}
}

// writeError maps a use-case error to its problem (REQ-API-001).
func (h handlers) writeError(w http.ResponseWriter, r *http.Request, err error) {
	switch {
	case errors.Is(err, domain.ErrAttestationRequired):
		w.Header().Set("WWW-Authenticate", `DM-Attest realm="api.azenfelnas.app"`)
		writeProblem(w, r, problemAttestationRequired, "")
	case errors.Is(err, domain.ErrAttestationInvalid):
		w.Header().Set("WWW-Authenticate", `DM-Attest realm="api.azenfelnas.app"`)
		writeProblem(w, r, problemAttestationInvalid, "")
	case errors.Is(err, domain.ErrRateLimited):
		now := h.clock.Now().UTC()
		retry := domain.DayOf(now).AddDate(0, 0, 1).Sub(now)
		w.Header().Set("Retry-After", strconv.Itoa(int(retry.Seconds())+1))
		writeProblem(w, r, problemRateLimited, "the daily limit resets at 00:00 UTC")
	case errors.Is(err, domain.ErrNotFound):
		writeProblem(w, r, problemNotFound, "")
	case errors.Is(err, context.DeadlineExceeded):
		writeProblem(w, r, problemTimeout, "")
	case errors.Is(err, domain.ErrAttestationUnavailable):
		h.log.Warn().Err(err).Msg("attestation service unavailable")
		writeProblem(w, r, problemUnavailable, "")
	default:
		h.log.Error().Err(err).Msg("unexpected error")
		writeProblem(w, r, problemInternal, "")
	}
}

func (h handlers) writeJSON(w http.ResponseWriter, r *http.Request, status int, v any) {
	body, err := json.Marshal(v)
	if err != nil {
		h.log.Error().Err(err).Msg("encode response")
		writeProblem(w, r, problemInternal, "")
		return
	}
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(status)
	_, _ = w.Write(body) // the client may be gone; nothing left to report to
}
