// Package porttest is the contract suite every storage adapter must pass
// (REQ-TEST-004): the memory fake and Postgres run the same tests, so the
// fake used by the API tests behaves like production. Test-only support code.
package porttest

import (
	"bytes"
	"context"
	"errors"
	"sync"
	"sync/atomic"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// Subject is a storage adapter implementing every storage port.
type Subject interface {
	ports.CorrectionStore
	ports.TelemetryStore
	ports.EvidenceStore
	ports.SaltSource
	ports.RateLimiter
	ports.AttestedKeyStore
	ports.IdempotencyStore
	ports.Purger
	ports.Pinger
}

// Harness creates fresh, empty subjects and reads back what the ports cannot.
type Harness struct {
	New            func(t *testing.T) Subject
	SeedEvidence   func(t *testing.T, s Subject, profileID, version string, summary []byte)
	CorrectionIDs  func(t *testing.T, s Subject) []domain.ReceiptID
	TelemetryCount func(t *testing.T, s Subject, day, metric, dim string) int64
}

var t0 = time.Date(2026, 10, 24, 9, 30, 0, 0, time.UTC)

// Run runs the whole contract against h.
func Run(t *testing.T, h Harness) {
	t.Helper()
	t.Run("REQ-PRIV-007 daily salt is stable within a day and differs across days", func(t *testing.T) { salts(t, h) })
	t.Run("REQ-PRIV-007 rate limit allows exactly the limit per pseudonym and day", func(t *testing.T) { rateLimit(t, h) })
	t.Run("REQ-PRIV-007 rate limit is atomic under concurrency", func(t *testing.T) { rateLimitConcurrent(t, h) })
	t.Run("REQ-API-003 idempotency claim, replay, mismatch and release", func(t *testing.T) { idempotency(t, h) })
	t.Run("REQ-API-004 attested key counter only advances", func(t *testing.T) { attestedKeys(t, h) })
	t.Run("corrections are inserted once per receipt id", func(t *testing.T) { corrections(t, h) })
	t.Run("telemetry increments accumulate", func(t *testing.T) { telemetry(t, h) })
	t.Run("evidence returns the newest profile version", func(t *testing.T) { evidence(t, h) })
	t.Run("REQ-DATA-002 purge deletes exactly the rows past retention", func(t *testing.T) { purge(t, h) })
	t.Run("ping succeeds", func(t *testing.T) {
		if err := h.New(t).Ping(context.Background()); err != nil {
			t.Fatal(err)
		}
	})
}

func pseudonym(b byte) domain.Pseudonym {
	var p domain.Pseudonym
	p[0] = b
	return p
}

func must(t *testing.T, err error) {
	t.Helper()
	if err != nil {
		t.Fatal(err)
	}
}

func salts(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	a, err := s.DailySalt(ctx, domain.DayOf(t0))
	must(t, err)
	again, err := s.DailySalt(ctx, domain.DayOf(t0.Add(10*time.Hour)))
	must(t, err)
	next, err := s.DailySalt(ctx, domain.DayOf(t0.Add(24*time.Hour)))
	must(t, err)
	if len(a) < 32 || !bytes.Equal(a, again) || bytes.Equal(a, next) {
		t.Fatalf("salts: len %d, same day equal %v, next day equal %v", len(a), bytes.Equal(a, again), bytes.Equal(a, next))
	}
}

func rateLimit(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	day := domain.DayOf(t0)
	for i := range 3 {
		ok, err := s.Consume(ctx, pseudonym(1), day, 3, t0)
		must(t, err)
		if !ok {
			t.Fatalf("use %d refused", i+1)
		}
	}
	ok, err := s.Consume(ctx, pseudonym(1), day, 3, t0)
	must(t, err)
	if ok {
		t.Fatal("use 4 of 3 allowed")
	}
	ok, err = s.Consume(ctx, pseudonym(2), day, 3, t0)
	must(t, err)
	if !ok {
		t.Fatal("another pseudonym was limited")
	}
	ok, err = s.Consume(ctx, pseudonym(1), domain.DayOf(t0.Add(24*time.Hour)), 3, t0.Add(24*time.Hour))
	must(t, err)
	if !ok {
		t.Fatal("the next day was limited")
	}
}

func rateLimitConcurrent(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	var allowed atomic.Int32
	var wg sync.WaitGroup
	errs := make(chan error, 25)
	for range 25 {
		wg.Go(func() {
			ok, err := s.Consume(ctx, pseudonym(9), domain.DayOf(t0), domain.CorrectionsPerDay, t0)
			if err != nil {
				errs <- err
				return
			}
			if ok {
				allowed.Add(1)
			}
		})
	}
	wg.Wait()
	close(errs)
	for err := range errs {
		t.Fatal(err)
	}
	if got := allowed.Load(); got != domain.CorrectionsPerDay {
		t.Fatalf("allowed %d of 25 concurrent uses, want %d", got, domain.CorrectionsPerDay)
	}
}

func idempotency(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	k := ports.IdempotencyKey{Route: "/v1/feedback/corrections", Key: "k-1"}
	hash := [32]byte{1}
	expect := func(want ports.ClaimOutcome, hash [32]byte) ports.Claim {
		t.Helper()
		c, err := s.Claim(ctx, k, hash, t0)
		must(t, err)
		if c.Outcome != want {
			t.Fatalf("claim outcome = %d, want %d", c.Outcome, want)
		}
		return c
	}
	expect(ports.ClaimNew, hash)
	expect(ports.ClaimInFlight, hash)
	must(t, s.Release(ctx, k))
	expect(ports.ClaimNew, hash)
	stored := ports.StoredResponse{Status: 201, ContentType: "application/json", Body: []byte(`{"receiptId":"x"}`)}
	must(t, s.Complete(ctx, k, stored))
	c := expect(ports.ClaimReplay, hash)
	if c.Response.Status != stored.Status || c.Response.ContentType != stored.ContentType || !bytes.Equal(c.Response.Body, stored.Body) {
		t.Fatalf("replay = %+v, want %+v", c.Response, stored)
	}
	must(t, s.Release(ctx, k)) // a completed key is never released
	expect(ports.ClaimReplay, hash)
	expect(ports.ClaimMismatch, [32]byte{2})
	other := ports.IdempotencyKey{Route: "/v1/telemetry/aggregates", Key: "k-1"}
	c2, err := s.Claim(ctx, other, [32]byte{2}, t0)
	must(t, err)
	if c2.Outcome != ports.ClaimNew {
		t.Fatalf("the same key on another route = %d, want new", c2.Outcome)
	}
}

func attestedKeys(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	if _, err := s.AttestedKey(ctx, pseudonym(3)); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing key err = %v", err)
	}
	if ok, err := s.AdvanceCounter(ctx, pseudonym(3), 1); err != nil || ok {
		t.Fatalf("advance missing key = %v, %v", ok, err)
	}
	must(t, s.PutAttestedKey(ctx, pseudonym(3), ports.AttestedKey{PublicKey: []byte{0x30, 1}, Counter: 0}, t0))
	for _, step := range []struct {
		counter uint32
		want    bool
	}{{1, true}, {1, false}, {0, false}, {5, true}, {4, false}} {
		ok, err := s.AdvanceCounter(ctx, pseudonym(3), step.counter)
		must(t, err)
		if ok != step.want {
			t.Fatalf("advance to %d = %v, want %v", step.counter, ok, step.want)
		}
	}
	k, err := s.AttestedKey(ctx, pseudonym(3))
	must(t, err)
	if k.Counter != 5 || !bytes.Equal(k.PublicKey, []byte{0x30, 1}) {
		t.Fatalf("key = %+v", k)
	}
}

func correction(id domain.ReceiptID, at time.Time) domain.Correction {
	country := "EG"
	return domain.Correction{
		ID: id, ReceivedUTC: at, Kind: domain.CorrectionProfile, PayloadJSON: []byte(`{"note":"x"}`),
		Country: &country, Location: &domain.RoundedLocation{Lat: 30.04, Lon: 31.24}, Status: domain.CorrectionNew,
	}
}

func corrections(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	id := domain.ReceiptID("0b4f8c9e-2d1a-4c3b-9e8f-7a6b5c4d3e2f")
	must(t, s.InsertCorrection(ctx, correction(id, t0)))
	if err := s.InsertCorrection(ctx, correction(id, t0)); err == nil {
		t.Fatal("duplicate receipt id inserted")
	}
	plain := domain.Correction{ID: "1b4f8c9e-2d1a-4c3b-9e8f-7a6b5c4d3e2f", ReceivedUTC: t0, Kind: domain.CorrectionOther, PayloadJSON: []byte(`{"note":"y"}`), Status: domain.CorrectionNew}
	must(t, s.InsertCorrection(ctx, plain))
	if got := h.CorrectionIDs(t, s); len(got) != 2 {
		t.Fatalf("stored %v", got)
	}
}

func telemetry(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	row := domain.TelemetryCount{Day: "2026-10-24", Metric: domain.MetricSyncOutcome, Dim: "ok", Count: 2}
	must(t, s.AddTelemetry(ctx, []domain.TelemetryCount{row}))
	must(t, s.AddTelemetry(ctx, []domain.TelemetryCount{row, {Day: "2026-10-24", Metric: domain.MetricSyncOutcome, Dim: "fail", Count: 1}}))
	if got := h.TelemetryCount(t, s, "2026-10-24", domain.MetricSyncOutcome, "ok"); got != 4 {
		t.Fatalf("ok count = %d, want 4", got)
	}
}

func evidence(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	if _, err := s.LatestEvidence(ctx, "eg.egas.national"); !errors.Is(err, domain.ErrNotFound) {
		t.Fatalf("missing evidence err = %v", err)
	}
	h.SeedEvidence(t, s, "eg.egas.national", "2026.9.3", []byte(`{"v":"2026.9.3"}`))
	h.SeedEvidence(t, s, "eg.egas.national", "2026.10.0", []byte(`{"v":"2026.10.0"}`))
	h.SeedEvidence(t, s, "eg.egas.national", "2026.2.7", []byte(`{"v":"2026.2.7"}`))
	got, err := s.LatestEvidence(ctx, "eg.egas.national")
	must(t, err)
	if !bytes.Contains(got, []byte("2026.10.0")) {
		t.Fatalf("latest = %s, want 2026.10.0", got)
	}
}

func purge(t *testing.T, h Harness) {
	s, ctx := h.New(t), context.Background()
	now := t0
	old, fresh := domain.ReceiptID("2b4f8c9e-2d1a-4c3b-9e8f-7a6b5c4d3e2f"), domain.ReceiptID("3b4f8c9e-2d1a-4c3b-9e8f-7a6b5c4d3e2f")
	must(t, s.InsertCorrection(ctx, correction(old, now.Add(-domain.CorrectionRetention-time.Hour))))
	must(t, s.InsertCorrection(ctx, correction(fresh, now.Add(-domain.CorrectionRetention+time.Hour))))
	oldDay := domain.DayOf(now.Add(-domain.TelemetryRetention - 48*time.Hour)).String()
	freshDay := domain.DayOf(now.Add(-domain.TelemetryRetention + 48*time.Hour)).String()
	must(t, s.AddTelemetry(ctx, []domain.TelemetryCount{{Day: oldDay, Metric: "m", Dim: "d", Count: 1}, {Day: freshDay, Metric: "m", Dim: "d", Count: 1}}))
	yesterday := now.Add(-25 * time.Hour)
	_, err := s.Consume(ctx, pseudonym(5), domain.DayOf(yesterday), 10, yesterday)
	must(t, err)
	_, err = s.Consume(ctx, pseudonym(6), domain.DayOf(now), 10, now.Add(-time.Hour))
	must(t, err)
	must(t, s.PutAttestedKey(ctx, pseudonym(5), ports.AttestedKey{PublicKey: []byte{1}}, yesterday))
	must(t, s.PutAttestedKey(ctx, pseudonym(6), ports.AttestedKey{PublicKey: []byte{1}}, now.Add(-time.Hour)))
	_, err = s.Claim(ctx, ports.IdempotencyKey{Route: "r", Key: "old"}, [32]byte{}, yesterday)
	must(t, err)
	_, err = s.Claim(ctx, ports.IdempotencyKey{Route: "r", Key: "new"}, [32]byte{}, now.Add(-time.Hour))
	must(t, err)
	_, err = s.DailySalt(ctx, domain.DayOf(yesterday))
	must(t, err)
	todaySalt, err := s.DailySalt(ctx, domain.DayOf(now))
	must(t, err)

	counts, err := s.Purge(ctx, domain.CutoffsAt(now))
	must(t, err)

	want := domain.PurgeCounts{Corrections: 1, Telemetry: 1, Pseudonyms: 2, Idempotency: 1, Salts: 1}
	if counts != want {
		t.Fatalf("purged %+v, want %+v", counts, want)
	}
	if ids := h.CorrectionIDs(t, s); len(ids) != 1 || ids[0] != fresh {
		t.Fatalf("kept corrections %v, want [%s]", ids, fresh)
	}
	if h.TelemetryCount(t, s, freshDay, "m", "d") != 1 {
		t.Fatal("fresh telemetry purged")
	}
	if _, err := s.AttestedKey(ctx, pseudonym(6)); err != nil {
		t.Fatalf("fresh attested key purged: %v", err)
	}
	if c, err := s.Claim(ctx, ports.IdempotencyKey{Route: "r", Key: "new"}, [32]byte{}, now); err != nil || c.Outcome != ports.ClaimInFlight {
		t.Fatalf("fresh idempotency key purged: %+v %v", c, err)
	}
	if salt, err := s.DailySalt(ctx, domain.DayOf(now)); err != nil || !bytes.Equal(salt, todaySalt) {
		t.Fatalf("today's salt changed: %v", err)
	}
}
