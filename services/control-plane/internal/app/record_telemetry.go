package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/telemetry"
)

// RecordTelemetry adds one device's opt-in daily aggregate (Appendix L).
// Attestation is optional here (§9.3); when one is sent it must verify.
type RecordTelemetry struct {
	Verifier ports.AttestationVerifier
	Salts    ports.SaltSource
	Store    ports.TelemetryStore
	Clock    ports.Clock
}

// Execute stores the aggregate's counts or returns domain.ErrAttestationInvalid
// or an I/O error (wrapped).
func (u RecordTelemetry) Execute(ctx context.Context, a telemetry.Aggregate, att *domain.Attestation) error {
	if att != nil {
		pseudonym, err := pseudonymOf(ctx, u.Salts, att.KeyID, domain.DayOf(u.Clock.Now()))
		if err != nil {
			return err
		}
		if err := u.Verifier.Verify(ctx, *att, pseudonym); err != nil {
			return fmt.Errorf("verify attestation: %w", err)
		}
	}
	if err := u.Store.AddTelemetry(ctx, domain.FlattenAggregate(a)); err != nil {
		return fmt.Errorf("add telemetry: %w", err)
	}
	return nil
}
