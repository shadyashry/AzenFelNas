package http

import (
	"encoding/json"
	"net/http"
	"strconv"

	"go.opentelemetry.io/otel/trace"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/api"
)

// problemKind is one entry of the problem catalogue (§15 D86); every error
// response is one of these, as RFC 9457 problem details (REQ-API-001).
type problemKind struct {
	slug   string
	status int
	title  string
}

var (
	problemInvalidBody         = problemKind{"invalid-body", http.StatusBadRequest, "The request body does not match its schema"}
	problemMissingIdempotency  = problemKind{"missing-idempotency-key", http.StatusBadRequest, "Idempotency-Key header required"}
	problemInvalidAttestation  = problemKind{"invalid-attestation-header", http.StatusBadRequest, "Malformed attestation headers"}
	problemAttestationRequired = problemKind{"attestation-required", http.StatusUnauthorized, "Attestation required"}
	problemAttestationInvalid  = problemKind{"attestation-invalid", http.StatusUnauthorized, "Attestation did not verify"}
	problemNotFound            = problemKind{"not-found", http.StatusNotFound, "Not found"}
	problemMethodNotAllowed    = problemKind{"method-not-allowed", http.StatusMethodNotAllowed, "Method not allowed"}
	problemInFlight            = problemKind{"idempotency-in-flight", http.StatusConflict, "A request with this Idempotency-Key is in progress"}
	problemBodyTooLarge        = problemKind{"body-too-large", http.StatusRequestEntityTooLarge, "Request body larger than 64 kB"}
	problemUnsupportedMedia    = problemKind{"unsupported-media-type", http.StatusUnsupportedMediaType, "Content-Type must be application/json"}
	problemKeyReused           = problemKind{"idempotency-key-reused", http.StatusUnprocessableEntity, "Idempotency-Key was used with a different request"}
	problemRateLimited         = problemKind{"rate-limited", http.StatusTooManyRequests, "Daily limit reached"}
	problemInternal            = problemKind{"internal", http.StatusInternalServerError, "Internal error"}
	problemUnavailable         = problemKind{"unavailable", http.StatusServiceUnavailable, "Temporarily unavailable"}
	problemTimeout             = problemKind{"timeout", http.StatusServiceUnavailable, "The request took longer than 5 s"}
)

// problemBody builds the problem for r, carrying its W3C trace id.
func problemBody(r *http.Request, k problemKind, detail string) api.Problem {
	return api.Problem{
		Type:     "/problems/" + k.slug,
		Title:    k.title,
		Status:   k.status,
		Detail:   detail,
		Instance: r.URL.Path,
		TraceID:  trace.SpanContextFromContext(r.Context()).TraceID().String(),
	}
}

// writeProblem writes k as application/problem+json.
func writeProblem(w http.ResponseWriter, r *http.Request, k problemKind, detail string) {
	body, err := json.Marshal(problemBody(r, k, detail))
	if err != nil {
		// api.Problem has only strings and an int; Marshal cannot fail.
		http.Error(w, k.title, k.status)
		return
	}
	h := w.Header()
	h.Set("Content-Type", "application/problem+json")
	h.Set("Content-Length", strconv.Itoa(len(body)))
	h.Set("Cache-Control", "no-store")
	w.WriteHeader(k.status)
	_, _ = w.Write(body) // the client may be gone; nothing left to report to
}
