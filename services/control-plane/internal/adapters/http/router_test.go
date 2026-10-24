package http_test

import (
	"bytes"
	"context"
	"crypto/rand"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"strings"
	"sync"
	"testing"
	"time"

	"github.com/rs/zerolog"
	metricnoop "go.opentelemetry.io/otel/metric/noop"
	sdktrace "go.opentelemetry.io/otel/sdk/trace"

	httpadapter "github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/http"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/memory"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/app"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/api"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

// fakeClock is a settable ports.Clock.
type fakeClock struct {
	mu  sync.Mutex
	now time.Time
}

func (c *fakeClock) Now() time.Time { c.mu.Lock(); defer c.mu.Unlock(); return c.now }

func (c *fakeClock) set(t time.Time) { c.mu.Lock(); defer c.mu.Unlock(); c.now = t }

// fakeVerifier is the ports.AttestationVerifier fake: a token verifies when
// it is "valid" and the request binding is the one the server computed.
type fakeVerifier struct {
	mu       sync.Mutex
	bindings map[[32]byte]bool
}

func (f *fakeVerifier) Verify(_ context.Context, a domain.Attestation, _ domain.Pseudonym) error {
	f.mu.Lock()
	defer f.mu.Unlock()
	if string(a.Token) != "valid" {
		return domain.ErrAttestationInvalid
	}
	f.bindings[a.Binding] = true
	return nil
}

// slowEvidence blocks until the request's context ends.
type slowEvidence struct{}

func (slowEvidence) LatestEvidence(ctx context.Context, _ string) ([]byte, error) {
	<-ctx.Done()
	return nil, ctx.Err()
}

type env struct {
	server    *httptest.Server
	store     *memory.Store
	clock     *fakeClock
	verifier  *fakeVerifier
	validator *validate.Validator
	logs      *bytes.Buffer
}

var t0 = time.Date(2026, 10, 24, 9, 30, 0, 0, time.UTC)

func newEnv(t *testing.T, opts ...func(*httpadapter.Deps)) *env {
	t.Helper()
	v, err := validate.New()
	if err != nil {
		t.Fatal(err)
	}
	e := &env{store: memory.New(), clock: &fakeClock{now: t0}, verifier: &fakeVerifier{bindings: map[[32]byte]bool{}}, validator: v, logs: &bytes.Buffer{}}
	d := httpadapter.Deps{
		Validator: v,
		Corrections: app.SubmitCorrection{
			Verifier: e.verifier, Salts: e.store, Limiter: e.store, Store: e.store, Clock: e.clock, Random: rand.Reader,
		},
		Telemetry:   app.RecordTelemetry{Verifier: e.verifier, Salts: e.store, Store: e.store, Clock: e.clock},
		Evidence:    app.GetEvidence{Store: e.store},
		Idempotency: e.store,
		Ready:       e.store,
		Clock:       e.clock,
		Log:         zerolog.New(&syncWriter{w: e.logs}),
		Tracer:      sdktrace.NewTracerProvider(),
		Meter:       metricnoop.NewMeterProvider(),
	}
	for _, o := range opts {
		o(&d)
	}
	e.server = httptest.NewServer(httpadapter.NewHandler(d))
	t.Cleanup(e.server.Close)
	return e
}

type syncWriter struct {
	mu sync.Mutex
	w  io.Writer
}

func (s *syncWriter) Write(p []byte) (int, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.w.Write(p)
}

const correctionBody = `{"schemaVersion":1,"kind":"profile","payload":{"profileId":"eg.egas.national","event":"FAJR","note":"late"},"country":"EG","roundedLat":30.04,"roundedLon":31.24}`

func randomKey(t *testing.T) string {
	t.Helper()
	b := make([]byte, 18)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	return base64.RawURLEncoding.EncodeToString(b)
}

func attested(keyID, token string) map[string]string {
	return map[string]string{
		httpadapter.HeaderPlatform: "android",
		httpadapter.HeaderKeyID:    base64.RawURLEncoding.EncodeToString([]byte(keyID)),
		httpadapter.HeaderToken:    base64.RawURLEncoding.EncodeToString([]byte(token)),
	}
}

func (e *env) do(t *testing.T, method, path, body string, headers map[string]string) (*http.Response, []byte) {
	t.Helper()
	req, err := http.NewRequestWithContext(context.Background(), method, e.server.URL+path, strings.NewReader(body))
	if err != nil {
		t.Fatal(err)
	}
	if body != "" {
		req.Header.Set("Content-Type", "application/json")
	}
	for k, v := range headers {
		req.Header.Set(k, v)
	}
	res, err := e.server.Client().Do(req)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = res.Body.Close() }()
	b, err := io.ReadAll(res.Body)
	if err != nil {
		t.Fatal(err)
	}
	return res, b
}

func (e *env) postCorrection(t *testing.T, keyID, idem, body string) (*http.Response, []byte) {
	t.Helper()
	h := attested(keyID, "valid")
	h["Idempotency-Key"] = idem
	return e.do(t, http.MethodPost, "/v1/feedback/corrections", body, h)
}

// assertProblem checks an RFC 9457 body valid against problem_details.v1 (REQ-API-001).
func (e *env) assertProblem(t *testing.T, res *http.Response, body []byte, status int, slug string) api.Problem {
	t.Helper()
	if res.StatusCode != status {
		t.Fatalf("status = %d, want %d; body %s", res.StatusCode, status, body)
	}
	if ct := res.Header.Get("Content-Type"); ct != "application/problem+json" {
		t.Fatalf("Content-Type = %q", ct)
	}
	if err := e.validator.Validate(validate.ProblemDetails, body); err != nil {
		t.Fatalf("problem does not match problem_details.v1: %v\n%s", err, body)
	}
	var p api.Problem
	if err := json.Unmarshal(body, &p); err != nil {
		t.Fatal(err)
	}
	if p.Type != "/problems/"+slug || p.Status != status || p.TraceID == strings.Repeat("0", 32) {
		t.Fatalf("problem = %+v, want type %s", p, slug)
	}
	return p
}

func TestREQAPI001EveryErrorIsAProblemWithTraceID(t *testing.T) {
	e := newEnv(t)
	idem := map[string]string{"Idempotency-Key": randomKey(t)}
	cases := []struct {
		name, method, path, body string
		headers                  map[string]string
		status                   int
		slug                     string
	}{
		{"unknown route", http.MethodGet, "/v1/unknown", "", nil, 404, "not-found"},
		{"wrong method", http.MethodGet, "/v1/feedback/corrections", "", nil, 405, "method-not-allowed"},
		{"unknown profile", http.MethodGet, "/v1/evidence/profiles/eg.none.none", "", nil, 404, "not-found"},
		{"missing idempotency key", http.MethodPost, "/v1/feedback/corrections", correctionBody, nil, 400, "missing-idempotency-key"},
		{"schema violation", http.MethodPost, "/v1/feedback/corrections", `{"schemaVersion":1}`, idem, 400, "invalid-body"},
		{"no attestation", http.MethodPost, "/v1/feedback/corrections", correctionBody, map[string]string{"Idempotency-Key": randomKey(t)}, 401, "attestation-required"},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			res, body := e.do(t, tc.method, tc.path, tc.body, tc.headers)
			e.assertProblem(t, res, body, tc.status, tc.slug)
		})
	}
}

func TestREQAPI001ProblemCarriesTheIncomingTraceID(t *testing.T) {
	e := newEnv(t)
	const traceID = "4bf92f3577b34da6a3ce929d0e0e4736"
	res, body := e.do(t, http.MethodGet, "/v1/nothing", "", map[string]string{"traceparent": "00-" + traceID + "-00f067aa0ba902b7-01"})
	if p := e.assertProblem(t, res, body, 404, "not-found"); p.TraceID != traceID {
		t.Fatalf("traceId = %s, want %s", p.TraceID, traceID)
	}
}

func TestREQAPI002BodyOver64KBIsRejected(t *testing.T) {
	e := newEnv(t)
	big := `{"schemaVersion":1,"kind":"other","payload":{"note":"` + strings.Repeat("x", httpadapter.MaxBodyBytes) + `"}}`
	h := attested("key-0123456789abcdef", "valid")
	h["Idempotency-Key"] = randomKey(t)
	res, body := e.do(t, http.MethodPost, "/v1/feedback/corrections", big, h)
	e.assertProblem(t, res, body, 413, "body-too-large")
}

func TestREQAPI002SlowRequestTimesOutAsProblem(t *testing.T) {
	e := newEnv(t, func(d *httpadapter.Deps) {
		d.Evidence = app.GetEvidence{Store: slowEvidence{}}
		d.Timeout = 50 * time.Millisecond
	})
	start := time.Now()
	res, body := e.do(t, http.MethodGet, "/v1/evidence/profiles/eg.egas.national", "", nil)
	e.assertProblem(t, res, body, 503, "timeout")
	if took := time.Since(start); took > 2*time.Second {
		t.Fatalf("timeout took %v", took)
	}
	if httpadapter.RequestTimeout != 5*time.Second || httpadapter.MaxBodyBytes != 64*1024 {
		t.Fatal("§9.3 limits changed")
	}
}

func TestREQAPI003IdempotencyKeyReplaysTheSameReceipt(t *testing.T) {
	e := newEnv(t)
	idem := randomKey(t)
	res1, body1 := e.postCorrection(t, "key-0123456789abcdef", idem, correctionBody)
	res2, body2 := e.postCorrection(t, "key-0123456789abcdef", idem, correctionBody)
	if res1.StatusCode != 201 || res2.StatusCode != 201 || !bytes.Equal(body1, body2) {
		t.Fatalf("first %d %s, replay %d %s", res1.StatusCode, body1, res2.StatusCode, body2)
	}
	if res2.Header.Get("Idempotent-Replayed") != "true" {
		t.Fatal("replay not marked")
	}
	if n := len(e.store.Corrections()); n != 1 {
		t.Fatalf("stored %d corrections, want 1", n)
	}
	other := strings.Replace(correctionBody, "late", "early", 1)
	res3, body3 := e.postCorrection(t, "key-0123456789abcdef", idem, other)
	e.assertProblem(t, res3, body3, 422, "idempotency-key-reused")
}

func TestREQAPI003FailedRequestReleasesItsKey(t *testing.T) {
	e := newEnv(t)
	idem := randomKey(t)
	h := attested("key-0123456789abcdef", "forged")
	h["Idempotency-Key"] = idem
	res, body := e.do(t, http.MethodPost, "/v1/feedback/corrections", correctionBody, h)
	e.assertProblem(t, res, body, 401, "attestation-invalid")
	if res, body := e.postCorrection(t, "key-0123456789abcdef", idem, correctionBody); res.StatusCode != 201 {
		t.Fatalf("retry with the same key = %d %s", res.StatusCode, body)
	}
}

func TestREQAPI004WritesRequireAValidAttestation(t *testing.T) {
	e := newEnv(t)
	for _, tc := range []struct {
		name    string
		headers map[string]string
		status  int
		slug    string
	}{
		{"missing", map[string]string{}, 401, "attestation-required"},
		{"forged token", attested("key-0123456789abcdef", "forged"), 401, "attestation-invalid"},
		{"unknown platform", map[string]string{httpadapter.HeaderPlatform: "web", httpadapter.HeaderKeyID: "a2V5LTAxMjM0NTY3ODlhYmNkZWY", httpadapter.HeaderToken: "dmFsaWQ"}, 400, "invalid-attestation-header"},
		{"short key id", attested("short", "valid"), 400, "invalid-attestation-header"},
	} {
		t.Run(tc.name, func(t *testing.T) {
			tc.headers["Idempotency-Key"] = randomKey(t)
			res, body := e.do(t, http.MethodPost, "/v1/feedback/corrections", correctionBody, tc.headers)
			e.assertProblem(t, res, body, tc.status, tc.slug)
		})
	}
	if n := len(e.store.Corrections()); n != 0 {
		t.Fatalf("stored %d unattested corrections", n)
	}
}

func TestREQAPI004AttestationIsBoundToTheRequest(t *testing.T) {
	e := newEnv(t)
	idem := randomKey(t)
	if res, body := e.postCorrection(t, "key-0123456789abcdef", idem, correctionBody); res.StatusCode != 201 {
		t.Fatalf("%d %s", res.StatusCode, body)
	}
	want := domain.RequestBinding(http.MethodPost, "/v1/feedback/corrections", idem, []byte(correctionBody))
	if !e.verifier.bindings[want] {
		t.Fatal("the verifier did not receive the request binding")
	}
}

func TestREQAPI005UnknownKeysAndPreciseCoordinatesAreRejected(t *testing.T) {
	e := newEnv(t)
	for name, body := range map[string]string{
		"unknown key (REQ-API-005)":         strings.Replace(correctionBody, `"kind"`, `"deviceId":"x","kind"`, 1),
		"3-decimal latitude (REQ-PRIV-001)": strings.Replace(correctionBody, "30.04", "30.044", 1),
		"not JSON":                          `{"schemaVersion":1,`,
	} {
		t.Run(name, func(t *testing.T) {
			res, b := e.postCorrection(t, "key-0123456789abcdef", randomKey(t), body)
			e.assertProblem(t, res, b, 400, "invalid-body")
		})
	}
	res, b := e.do(t, http.MethodPost, "/v1/feedback/corrections", correctionBody, map[string]string{"Content-Type": "text/plain", "Idempotency-Key": randomKey(t)})
	e.assertProblem(t, res, b, 415, "unsupported-media-type")
}

func TestREQAPI005ReceiptMatchesItsSchema(t *testing.T) {
	e := newEnv(t)
	res, body := e.postCorrection(t, "key-0123456789abcdef", randomKey(t), correctionBody)
	if res.StatusCode != 201 {
		t.Fatalf("%d %s", res.StatusCode, body)
	}
	if err := e.validator.Validate(validate.CorrectionReceipt, body); err != nil {
		t.Fatal(err)
	}
	c := e.store.Corrections()[0]
	if c.Kind != domain.CorrectionProfile || c.Location == nil || c.Location.Lat != 30.04 || *c.Country != "EG" || c.Status != domain.CorrectionNew {
		t.Fatalf("stored %+v", c)
	}
}

func TestREQPRIV007CorrectionsAreLimitedTo10PerKeyAndUTCDay(t *testing.T) {
	e := newEnv(t)
	for i := range domain.CorrectionsPerDay {
		if res, body := e.postCorrection(t, "key-0123456789abcdef", randomKey(t), correctionBody); res.StatusCode != 201 {
			t.Fatalf("correction %d: %d %s", i+1, res.StatusCode, body)
		}
	}
	res, body := e.postCorrection(t, "key-0123456789abcdef", randomKey(t), correctionBody)
	e.assertProblem(t, res, body, 429, "rate-limited")
	wantRetry := fmt.Sprint(int((14*time.Hour + 30*time.Minute).Seconds()) + 1)
	if got := res.Header.Get("Retry-After"); got != wantRetry {
		t.Fatalf("Retry-After = %s, want %s (next 00:00 UTC)", got, wantRetry)
	}
	if res, _ := e.postCorrection(t, "key-fedcba9876543210", randomKey(t), correctionBody); res.StatusCode != 201 {
		t.Fatalf("another key was limited: %d", res.StatusCode)
	}
	e.clock.set(t0.Add(15 * time.Hour))
	if res, _ := e.postCorrection(t, "key-0123456789abcdef", randomKey(t), correctionBody); res.StatusCode != 201 {
		t.Fatalf("the next UTC day was limited: %d", res.StatusCode)
	}
	if n := len(e.store.Corrections()); n != domain.CorrectionsPerDay+2 {
		t.Fatalf("stored %d", n)
	}
}

func TestREQAPI006TelemetryNeedsNoIdentityAndAttestationIsOptional(t *testing.T) {
	e := newEnv(t)
	agg := `{"schemaVersion":1,"day":"2026-10-23","appVersion":"1.0.0","platform":"ios","osMajor":18,"counters":{"packageActivations":{"tzdata":1},"healthState":{"READY":3},"testResults":{"heard":1,"notHeard":0,"unknown":0},"syncOutcome":{"ok":2,"warn":0,"fail":0}}}`
	res, body := e.do(t, http.MethodPost, "/v1/telemetry/aggregates", agg, map[string]string{"Idempotency-Key": randomKey(t)})
	if res.StatusCode != 204 {
		t.Fatalf("%d %s", res.StatusCode, body)
	}
	if got := e.store.TelemetryCount("2026-10-23", domain.MetricSyncOutcome, "ok"); got != 2 {
		t.Fatalf("sync ok = %d", got)
	}
	h := attested("key-0123456789abcdef", "forged")
	h["Idempotency-Key"] = randomKey(t)
	res, body = e.do(t, http.MethodPost, "/v1/telemetry/aggregates", agg, h)
	e.assertProblem(t, res, body, 401, "attestation-invalid")
	bad := strings.Replace(agg, `"osMajor":18`, `"osMajor":18,"installId":"abc"`, 1)
	res, body = e.do(t, http.MethodPost, "/v1/telemetry/aggregates", bad, map[string]string{"Idempotency-Key": randomKey(t)})
	e.assertProblem(t, res, body, 400, "invalid-body")
}

func TestEvidenceIsPublicCachedOneHourAndSchemaChecked(t *testing.T) {
	e := newEnv(t)
	summary := `{"schemaVersion":1,"profileId":"eg.egas.national","profileVersion":"2026.1.0","generatedDay":"2026-10-20","sources":[],"statistics":[{"event":"FAJR","sampleDays":30,"meanDeltaSeconds":-12.5,"p95AbsDeltaSeconds":40,"maxAbsDeltaSeconds":58}]}`
	e.store.PutEvidence("eg.egas.national", "2026.1.0", []byte(summary))
	res, body := e.do(t, http.MethodGet, "/v1/evidence/profiles/eg.egas.national", "", nil)
	if res.StatusCode != 200 || string(body) != summary || res.Header.Get("Cache-Control") != "public, max-age=3600" {
		t.Fatalf("%d %q %s", res.StatusCode, res.Header.Get("Cache-Control"), body)
	}
	e.store.PutEvidence("eg.bad.summary", "2026.1.0", []byte(`{"table":[]}`))
	res, body = e.do(t, http.MethodGet, "/v1/evidence/profiles/eg.bad.summary", "", nil)
	e.assertProblem(t, res, body, 500, "internal")
}

func TestHealthAndReadiness(t *testing.T) {
	e := newEnv(t)
	for _, path := range []string{"/healthz", "/readyz"} {
		if res, body := e.do(t, http.MethodGet, path, "", nil); res.StatusCode != 200 {
			t.Fatalf("%s = %d %s", path, res.StatusCode, body)
		}
	}
}

func TestREQPRIV001AccessLogHasNoAddressHeadersOrKeys(t *testing.T) {
	e := newEnv(t)
	h := attested("key-0123456789abcdef", "valid")
	h["Idempotency-Key"] = randomKey(t)
	h["User-Agent"] = "DailyMuslim/1.0 (Pixel 9)"
	h["X-Forwarded-For"] = "203.0.113.7"
	if res, body := e.do(t, http.MethodPost, "/v1/feedback/corrections", correctionBody, h); res.StatusCode != 201 {
		t.Fatalf("%d %s", res.StatusCode, body)
	}
	logs := e.logs.String()
	for _, banned := range []string{"203.0.113.7", "127.0.0.1", "Pixel", h[httpadapter.HeaderKeyID], h["Idempotency-Key"], "30.04", "late"} {
		if strings.Contains(logs, banned) {
			t.Errorf("access log contains %q:\n%s", banned, logs)
		}
	}
	if !strings.Contains(logs, `"route":"POST /v1/feedback/corrections"`) {
		t.Errorf("access log lacks the route pattern:\n%s", logs)
	}
}
