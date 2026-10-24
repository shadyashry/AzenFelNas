package domain

import "errors"

// Sentinel errors that the HTTP adapter maps to problem details (REQ-API-001).
var (
	// ErrCoordinatePrecision is returned when a coordinate carries more than
	// two decimals (REQ-PRIV-001).
	ErrCoordinatePrecision = errors.New("domain: coordinate has more than 2 decimals")
	// ErrAttestationRequired is returned when a write carries no attestation (REQ-API-004).
	ErrAttestationRequired = errors.New("domain: attestation required")
	// ErrAttestationInvalid is returned when an attestation does not verify (REQ-API-004).
	ErrAttestationInvalid = errors.New("domain: attestation invalid")
	// ErrAttestationUnavailable is returned when the attestation service cannot be reached.
	ErrAttestationUnavailable = errors.New("domain: attestation service unavailable")
	// ErrRateLimited is returned when the daily correction limit is spent.
	ErrRateLimited = errors.New("domain: daily limit reached")
	// ErrNotFound is returned when a requested resource does not exist.
	ErrNotFound = errors.New("domain: not found")
)
