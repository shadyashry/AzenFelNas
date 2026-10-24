package app_test

import (
	"context"
	"crypto/rand"
	"errors"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/memory"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/app"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
)

type clock struct{ t time.Time }

func (c clock) Now() time.Time { return c.t }

// rejectingVerifier is the ports.AttestationVerifier fake that refuses everything.
type rejectingVerifier struct{}

func (rejectingVerifier) Verify(context.Context, domain.Attestation, domain.Pseudonym) error {
	return domain.ErrAttestationInvalid
}

func TestREQAPI004RejectedAttestationSpendsNoAllowance(t *testing.T) {
	t.Parallel()
	store := memory.New()
	now := time.Date(2026, 10, 24, 9, 30, 0, 0, time.UTC)
	u := app.SubmitCorrection{Verifier: rejectingVerifier{}, Salts: store, Limiter: store, Store: store, Clock: clock{now}, Random: rand.Reader}
	att := &domain.Attestation{Platform: domain.PlatformAndroid, KeyID: []byte("installation-key-0001"), Token: []byte("t")}
	for range domain.CorrectionsPerDay + 1 {
		if _, err := u.Execute(context.Background(), app.CorrectionInput{Kind: domain.CorrectionOther, PayloadJSON: []byte(`{}`), Attestation: att}); !errors.Is(err, domain.ErrAttestationInvalid) {
			t.Fatalf("err = %v", err)
		}
	}
	salt, err := store.DailySalt(context.Background(), domain.DayOf(now))
	if err != nil {
		t.Fatal(err)
	}
	ok, err := store.Consume(context.Background(), domain.PseudonymOf(att.KeyID, salt), domain.DayOf(now), domain.CorrectionsPerDay, now)
	if err != nil || !ok {
		t.Fatalf("allowance was spent by rejected attestations: %v %v", ok, err)
	}
	if len(store.Corrections()) != 0 {
		t.Fatal("a correction was stored")
	}
}

func TestREQAPI004MissingAttestationIsRequired(t *testing.T) {
	t.Parallel()
	store := memory.New()
	u := app.SubmitCorrection{Verifier: rejectingVerifier{}, Salts: store, Limiter: store, Store: store, Clock: clock{time.Now()}, Random: rand.Reader}
	if _, err := u.Execute(context.Background(), app.CorrectionInput{Kind: domain.CorrectionOther}); !errors.Is(err, domain.ErrAttestationRequired) {
		t.Fatalf("err = %v", err)
	}
}
