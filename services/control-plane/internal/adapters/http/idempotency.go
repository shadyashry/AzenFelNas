package http

import (
	"crypto/sha256"
	"errors"
	"io"
	"net/http"
	"regexp"

	"github.com/rs/zerolog"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// idempotencyKeyPattern bounds the client's key: a random token, never an identifier (§15 D86).
var idempotencyKeyPattern = regexp.MustCompile(`^[A-Za-z0-9_-]{16,64}$`)

// idempotentPOST reads the JSON body once and makes the POST idempotent by
// its Idempotency-Key (REQ-API-003): a repeat of a completed request replays
// the stored 2xx response; a repeat with another body is 422; a concurrent
// repeat is 409. Non-2xx outcomes release the key so the client may retry.
func idempotentPOST(store ports.IdempotencyStore, clock ports.Clock, log zerolog.Logger, next func(w http.ResponseWriter, r *http.Request, body []byte)) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if mediaType(r) != "application/json" {
			writeProblem(w, r, problemUnsupportedMedia, "")
			return
		}
		key := r.Header.Get("Idempotency-Key")
		if !idempotencyKeyPattern.MatchString(key) {
			writeProblem(w, r, problemMissingIdempotency, "send a random Idempotency-Key of 16-64 characters [A-Za-z0-9_-]")
			return
		}
		body, err := io.ReadAll(r.Body)
		if err != nil {
			var tooLarge *http.MaxBytesError
			if errors.As(err, &tooLarge) {
				writeProblem(w, r, problemBodyTooLarge, "")
				return
			}
			writeProblem(w, r, problemInvalidBody, "the body could not be read")
			return
		}
		ik := ports.IdempotencyKey{Route: r.URL.Path, Key: key}
		claim, err := store.Claim(r.Context(), ik, sha256.Sum256(body), clock.Now())
		if err != nil {
			log.Error().Err(err).Msg("idempotency claim")
			writeProblem(w, r, problemUnavailable, "")
			return
		}
		switch claim.Outcome {
		case ports.ClaimReplay:
			w.Header().Set("Idempotent-Replayed", "true")
			writeStored(w, claim.Response)
			return
		case ports.ClaimInFlight:
			writeProblem(w, r, problemInFlight, "")
			return
		case ports.ClaimMismatch:
			writeProblem(w, r, problemKeyReused, "")
			return
		case ports.ClaimNew:
		}
		buf := newBufferedWriter()
		next(buf, r, body)
		if buf.status >= 200 && buf.status < 300 {
			stored := ports.StoredResponse{Status: buf.status, ContentType: buf.header.Get("Content-Type"), Body: buf.body.Bytes()}
			if err := store.Complete(r.Context(), ik, stored); err != nil {
				log.Error().Err(err).Msg("idempotency complete")
			}
		} else if err := store.Release(r.Context(), ik); err != nil {
			log.Error().Err(err).Msg("idempotency release")
		}
		buf.copyTo(w)
	}
}

func writeStored(w http.ResponseWriter, s ports.StoredResponse) {
	w.Header().Set("Content-Type", s.ContentType)
	w.Header().Set("Cache-Control", "no-store")
	w.WriteHeader(s.Status)
	_, _ = w.Write(s.Body) // the client may be gone; nothing left to report to
}

func mediaType(r *http.Request) string {
	ct := r.Header.Get("Content-Type")
	for i := range len(ct) {
		if ct[i] == ';' {
			ct = ct[:i]
			break
		}
	}
	return ct
}
