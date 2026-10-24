// Package http is the control plane's HTTP adapter (DESIGN.md §9.3): /v1
// JSON routes with RFC 9457 problem details carrying the trace id
// (REQ-API-001), a 5 s timeout and 64 kB body limit on every route
// (REQ-API-002), Idempotency-Key on every POST (REQ-API-003), attestation on
// writes (REQ-API-004), schema-validated bodies (REQ-API-005) and no user
// identity anywhere (REQ-API-006). Handlers are thin: decode, call one use
// case, encode.
package http

import (
	"net/http"
	"time"

	"github.com/rs/zerolog"
	"go.opentelemetry.io/contrib/instrumentation/net/http/otelhttp"
	"go.opentelemetry.io/otel/metric"
	"go.opentelemetry.io/otel/propagation"
	"go.opentelemetry.io/otel/trace"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

// Deps are the handler's collaborators, wired in cmd/api.
type Deps struct {
	Validator   *validate.Validator
	Corrections correctionSubmitter
	Telemetry   telemetryRecorder
	Evidence    evidenceGetter
	Idempotency ports.IdempotencyStore
	Ready       ports.Pinger
	Clock       ports.Clock
	Log         zerolog.Logger
	Tracer      trace.TracerProvider
	Meter       metric.MeterProvider
	// Timeout overrides RequestTimeout in tests; zero means RequestTimeout.
	Timeout time.Duration
	// GCPProject, when set, adds the Cloud Logging trace field to access logs.
	GCPProject string
}

// NewHandler returns the API's root handler.
func NewHandler(d Deps) http.Handler {
	h := handlers{
		validator: d.Validator, corrections: d.Corrections, telemetry: d.Telemetry, evidence: d.Evidence,
		ready: d.Ready, clock: d.Clock, log: d.Log,
	}
	mux := http.NewServeMux()
	mux.Handle("POST /v1/feedback/corrections", idempotentPOST(d.Idempotency, d.Clock, d.Log, h.postCorrection))
	mux.Handle("/v1/feedback/corrections", methodNotAllowed(http.MethodPost))
	mux.Handle("POST /v1/telemetry/aggregates", idempotentPOST(d.Idempotency, d.Clock, d.Log, h.postTelemetry))
	mux.Handle("/v1/telemetry/aggregates", methodNotAllowed(http.MethodPost))
	mux.HandleFunc("GET /v1/evidence/profiles/{id}", h.getEvidence)
	mux.Handle("/v1/evidence/profiles/{id}", methodNotAllowed(http.MethodGet+", "+http.MethodHead))
	mux.HandleFunc("GET /healthz", h.healthz)
	mux.HandleFunc("GET /readyz", h.readyz)
	mux.HandleFunc("/", h.notFound)

	root := withBodyLimit(MaxBodyBytes, mux)
	timeout := RequestTimeout
	if d.Timeout > 0 {
		timeout = d.Timeout
	}
	root = withTimeout(timeout, root)
	root = withRecoverAndLog(d.Log, d.GCPProject, mux, root)
	return otelhttp.NewHandler(root, "control-plane",
		otelhttp.WithTracerProvider(d.Tracer),
		otelhttp.WithMeterProvider(d.Meter),
		otelhttp.WithPropagators(propagation.TraceContext{}),
		otelhttp.WithSpanNameFormatter(func(_ string, r *http.Request) string {
			return r.Method + " " + pattern(mux, r)
		}),
	)
}
