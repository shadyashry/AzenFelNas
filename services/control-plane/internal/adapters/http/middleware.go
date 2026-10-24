package http

import (
	"bytes"
	"context"
	"errors"
	"maps"
	"net/http"
	"time"

	"github.com/rs/zerolog"
	"go.opentelemetry.io/otel/trace"
)

// Limits of §9.3 (REQ-API-002).
const (
	RequestTimeout = 5 * time.Second
	MaxBodyBytes   = 64 << 10
)

// bufferedWriter collects a response so a handler that overruns its deadline
// can be replaced by a problem (REQ-API-002).
type bufferedWriter struct {
	header http.Header
	body   bytes.Buffer
	status int
}

func newBufferedWriter() *bufferedWriter { return &bufferedWriter{header: http.Header{}} }

func (b *bufferedWriter) Header() http.Header { return b.header }

func (b *bufferedWriter) Write(p []byte) (int, error) {
	if b.status == 0 {
		b.status = http.StatusOK
	}
	return b.body.Write(p)
}

func (b *bufferedWriter) WriteHeader(status int) {
	if b.status == 0 {
		b.status = status
	}
}

func (b *bufferedWriter) copyTo(w http.ResponseWriter) {
	maps.Copy(w.Header(), b.header)
	status := b.status
	if status == 0 {
		status = http.StatusOK
	}
	w.WriteHeader(status)
	_, _ = w.Write(b.body.Bytes()) // the client may be gone; nothing left to report to
}

// withTimeout gives every request a deadline of d; a handler still running at
// the deadline is answered with a 503 timeout problem (REQ-API-002). Handlers
// pass the context to every I/O call, so they stop soon after.
func withTimeout(d time.Duration, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx, cancel := context.WithTimeout(r.Context(), d)
		defer cancel()
		r = r.WithContext(ctx)
		buf := newBufferedWriter()
		done := make(chan struct{})
		panicked := make(chan any, 1)
		go func() {
			defer close(done)
			defer func() {
				if p := recover(); p != nil {
					panicked <- p
				}
			}()
			next.ServeHTTP(buf, r)
		}()
		select {
		case <-done:
			select {
			case p := <-panicked:
				panic(p)
			default:
			}
			buf.copyTo(w)
		case <-ctx.Done():
			writeProblem(w, r, problemTimeout, "")
		}
	})
}

// withBodyLimit caps every request body at n bytes (REQ-API-002).
func withBodyLimit(n int64, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		r.Body = http.MaxBytesReader(w, r.Body, n)
		next.ServeHTTP(w, r)
	})
}

// statusRecorder remembers the status for the access log.
type statusRecorder struct {
	http.ResponseWriter
	status int
}

func (s *statusRecorder) WriteHeader(status int) {
	if s.status == 0 {
		s.status = status
	}
	s.ResponseWriter.WriteHeader(status)
}

func (s *statusRecorder) Write(p []byte) (int, error) {
	if s.status == 0 {
		s.status = http.StatusOK
	}
	return s.ResponseWriter.Write(p)
}

// withRecoverAndLog turns a panic into a 500 problem and writes one access
// log line per request: route pattern, status, duration and trace id. It
// never logs the client address, user agent, headers or body (REQ-PRIV-001).
func withRecoverAndLog(log zerolog.Logger, gcpProject string, routes *http.ServeMux, next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		rec := &statusRecorder{ResponseWriter: w}
		defer func() {
			if p := recover(); p != nil {
				if err, ok := p.(error); ok && errors.Is(err, http.ErrAbortHandler) {
					panic(p)
				}
				log.Error().Str("route", pattern(routes, r)).Msg("panic in handler")
				if rec.status == 0 {
					writeProblem(rec, r, problemInternal, "")
				}
			}
			sc := trace.SpanContextFromContext(r.Context())
			ev := log.Info()
			if rec.status >= http.StatusInternalServerError {
				ev = log.Error()
			}
			if gcpProject != "" {
				ev = ev.Str("logging.googleapis.com/trace", "projects/"+gcpProject+"/traces/"+sc.TraceID().String())
			}
			ev.Str("method", r.Method).
				Str("route", pattern(routes, r)).
				Int("status", rec.status).
				Int64("durationMs", time.Since(start).Milliseconds()).
				Str("traceId", sc.TraceID().String()).
				Msg("request")
		}()
		next.ServeHTTP(rec, r)
	})
}

// pattern returns the matched route pattern, never the raw path.
func pattern(routes *http.ServeMux, r *http.Request) string {
	if _, p := routes.Handler(r); p != "" {
		return p
	}
	return "unmatched"
}
