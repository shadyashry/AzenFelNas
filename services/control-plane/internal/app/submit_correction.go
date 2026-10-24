// Package app holds the control plane's use cases, one per type (DESIGN.md
// §17.1). They depend on ports only; wiring happens in cmd/api.
package app

import (
	"context"
	"fmt"
	"io"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// CorrectionInput is a validated correction request with its attestation.
type CorrectionInput struct {
	Kind        domain.CorrectionKind
	PayloadJSON []byte
	Country     *string
	Location    *domain.RoundedLocation
	Attestation *domain.Attestation
}

// SubmitCorrection stores an attested user correction, at most
// domain.CorrectionsPerDay per attestation key and UTC day (§9.3).
type SubmitCorrection struct {
	Verifier ports.AttestationVerifier
	Salts    ports.SaltSource
	Limiter  ports.RateLimiter
	Store    ports.CorrectionStore
	Clock    ports.Clock
	Random   io.Reader
}

// Execute returns the new correction's receipt id, or domain.ErrAttestationRequired,
// domain.ErrAttestationInvalid, domain.ErrRateLimited or an I/O error (wrapped).
func (u SubmitCorrection) Execute(ctx context.Context, in CorrectionInput) (domain.ReceiptID, error) {
	if in.Attestation == nil {
		return "", domain.ErrAttestationRequired
	}
	now := u.Clock.Now().UTC()
	day := domain.DayOf(now)
	pseudonym, err := pseudonymOf(ctx, u.Salts, in.Attestation.KeyID, day)
	if err != nil {
		return "", err
	}
	if err := u.Verifier.Verify(ctx, *in.Attestation, pseudonym); err != nil {
		return "", fmt.Errorf("verify attestation: %w", err)
	}
	allowed, err := u.Limiter.Consume(ctx, pseudonym, day, domain.CorrectionsPerDay, now)
	if err != nil {
		return "", fmt.Errorf("consume rate limit: %w", err)
	}
	if !allowed {
		return "", domain.ErrRateLimited
	}
	id, err := domain.NewReceiptID(u.Random)
	if err != nil {
		return "", err
	}
	c := domain.Correction{
		ID:          id,
		ReceivedUTC: now,
		Kind:        in.Kind,
		PayloadJSON: in.PayloadJSON,
		Country:     in.Country,
		Location:    in.Location,
		Status:      domain.CorrectionNew,
	}
	if err := u.Store.InsertCorrection(ctx, c); err != nil {
		return "", fmt.Errorf("insert correction: %w", err)
	}
	return id, nil
}

func pseudonymOf(ctx context.Context, salts ports.SaltSource, key domain.AttestationKeyID, day domain.Day) (domain.Pseudonym, error) {
	salt, err := salts.DailySalt(ctx, day)
	if err != nil {
		return domain.Pseudonym{}, fmt.Errorf("daily salt: %w", err)
	}
	return domain.PseudonymOf(key, salt), nil
}
