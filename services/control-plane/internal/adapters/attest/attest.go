// Package attest verifies write attestations (REQ-API-004, §15 D86): Play
// Integrity standard requests on Android and App Attest on iOS. Each token
// commits to the request binding, so it cannot be replayed on another body,
// and the attested key id feeds the daily pseudonym (REQ-PRIV-007).
package attest

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// ByPlatform dispatches to the verifier of the attestation's platform.
type ByPlatform struct {
	Android ports.AttestationVerifier
	IOS     ports.AttestationVerifier
}

// Verify implements ports.AttestationVerifier.
func (b ByPlatform) Verify(ctx context.Context, a domain.Attestation, p domain.Pseudonym) error {
	switch a.Platform {
	case domain.PlatformAndroid:
		return b.Android.Verify(ctx, a, p)
	case domain.PlatformIOS:
		return b.IOS.Verify(ctx, a, p)
	default:
		return fmt.Errorf("%w: platform %q", domain.ErrAttestationInvalid, a.Platform)
	}
}

// Unconfigured fails closed: every attestation is unavailable. cmd/api uses
// it for a platform whose credentials are not configured.
type Unconfigured struct{ Reason string }

// Verify implements ports.AttestationVerifier.
func (u Unconfigured) Verify(context.Context, domain.Attestation, domain.Pseudonym) error {
	return fmt.Errorf("%w: %s", domain.ErrAttestationUnavailable, u.Reason)
}
