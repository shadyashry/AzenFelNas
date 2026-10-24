// Package ports declares the control plane's narrow interfaces (DESIGN.md
// §9.3, §17.5): each is defined by the use case or adapter that consumes it
// and has one to three methods. Adapters implement them; contract tests in
// porttest run against every implementation (REQ-TEST-004).
package ports

import (
	"context"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
)

// Clock returns the current instant.
type Clock interface {
	Now() time.Time
}

// CorrectionStore persists corrections.
type CorrectionStore interface {
	InsertCorrection(ctx context.Context, c domain.Correction) error
}

// TelemetryStore adds daily aggregate counts.
type TelemetryStore interface {
	AddTelemetry(ctx context.Context, rows []domain.TelemetryCount) error
}

// EvidenceStore reads published evidence summaries.
type EvidenceStore interface {
	// LatestEvidence returns the summary JSON of the newest version of
	// profileID, or domain.ErrNotFound.
	LatestEvidence(ctx context.Context, profileID string) ([]byte, error)
}

// SaltSource returns the random server salt of a UTC day, creating it on first use.
type SaltSource interface {
	DailySalt(ctx context.Context, day domain.Day) (domain.Salt, error)
}

// RateLimiter counts uses of a pseudonym per day.
type RateLimiter interface {
	// Consume atomically spends one use and reports false, spending nothing,
	// when limit uses were already spent on day.
	Consume(ctx context.Context, p domain.Pseudonym, day domain.Day, limit int, now time.Time) (bool, error)
}

// AttestationVerifier checks a write's attestation (REQ-API-004).
type AttestationVerifier interface {
	// Verify returns nil, domain.ErrAttestationInvalid or
	// domain.ErrAttestationUnavailable (wrapped).
	Verify(ctx context.Context, a domain.Attestation, p domain.Pseudonym) error
}

// AttestedKey is an App Attest public key verified today, with its last counter.
type AttestedKey struct {
	PublicKey []byte // PKIX DER
	Counter   uint32
}

// AttestedKeyStore keeps App Attest public keys under the daily pseudonym for
// at most 24 h (REQ-PRIV-007).
type AttestedKeyStore interface {
	// AttestedKey returns the key stored under p, or domain.ErrNotFound.
	AttestedKey(ctx context.Context, p domain.Pseudonym) (AttestedKey, error)
	PutAttestedKey(ctx context.Context, p domain.Pseudonym, k AttestedKey, now time.Time) error
	// AdvanceCounter stores counter and reports true only when it is greater than the stored one.
	AdvanceCounter(ctx context.Context, p domain.Pseudonym, counter uint32) (bool, error)
}

// IdempotencyKey scopes a client's Idempotency-Key to one route (REQ-API-003).
type IdempotencyKey struct {
	Route string
	Key   string
}

// StoredResponse is a completed response kept for replay.
type StoredResponse struct {
	Status      int
	ContentType string
	Body        []byte
}

// ClaimOutcome is the result of claiming an idempotency key.
type ClaimOutcome int

// ClaimOutcome values.
const (
	// ClaimNew means the caller owns the key and must Complete or Release it.
	ClaimNew ClaimOutcome = iota + 1
	// ClaimReplay means a response is stored for the same request.
	ClaimReplay
	// ClaimInFlight means the same request is still being processed.
	ClaimInFlight
	// ClaimMismatch means the key was used with a different request.
	ClaimMismatch
)

// Claim is a ClaimOutcome with the stored response of a ClaimReplay.
type Claim struct {
	Outcome  ClaimOutcome
	Response StoredResponse
}

// IdempotencyStore remembers POST outcomes for 24 h (REQ-API-003).
type IdempotencyStore interface {
	Claim(ctx context.Context, k IdempotencyKey, requestHash [32]byte, now time.Time) (Claim, error)
	Complete(ctx context.Context, k IdempotencyKey, r StoredResponse) error
	Release(ctx context.Context, k IdempotencyKey) error
}

// Purger deletes rows past their retention (REQ-DATA-002).
type Purger interface {
	Purge(ctx context.Context, c domain.Cutoffs) (domain.PurgeCounts, error)
}

// Pinger reports whether a dependency is ready.
type Pinger interface {
	Ping(ctx context.Context) error
}
