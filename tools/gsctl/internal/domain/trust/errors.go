// Package trust holds the TUF-lite rules of Appendix C and ADR-009: key
// identity (§15 D17), the signature envelope over JCS-canonical `signed`
// (REQ-DIST-004), role thresholds (REQ-DIST-001), monotonic sequences
// (REQ-DIST-002, REQ-PKG-005), content addresses (REQ-DIST-003) and the
// bottom-up chain check. Pure: no I/O and no clock; callers pass "now".
package trust

import "errors"

// Sentinel errors; Code maps them to Appendix J failure codes.
var (
	// ErrMalformed: a metadata file that cannot be decoded, has the wrong
	// role type or breaks a structural rule of Appendix C.
	ErrMalformed = errors.New("metadata malformed")
	// ErrSignature: fewer valid signatures than the role threshold.
	ErrSignature = errors.New("signature threshold not met")
	// ErrHashMismatch: a file or package does not match the length or
	// SHA-256 its parent role pins.
	ErrHashMismatch = errors.New("hash or length mismatch")
	// ErrSequenceRegression: a sequence not strictly greater than the
	// trusted or previous one.
	ErrSequenceRegression = errors.New("sequence regression")
	// ErrTimestampExpiry: a timestamp that would expire more than 7 days
	// after signing (§9.1).
	ErrTimestampExpiry = errors.New("timestamp expiry beyond 7 days")
	// ErrImmutableTarget: a target name already published with other
	// content (REQ-DIST-003).
	ErrImmutableTarget = errors.New("target is immutable")
	// ErrInsufficientKeys: fewer signing keys available than the role
	// threshold.
	ErrInsufficientKeys = errors.New("fewer signing keys than the threshold")
	// ErrKeyMismatch: a key that is not the one the configuration or the
	// signed root names.
	ErrKeyMismatch = errors.New("key mismatch")
)

// Code returns the Appendix J failure code for err, or "" when none
// applies (a signing-side or usage error).
func Code(err error) string {
	switch {
	case errors.Is(err, ErrMalformed), errors.Is(err, ErrSignature):
		return "PKG_SIG_INVALID"
	case errors.Is(err, ErrHashMismatch):
		return "PKG_HASH_MISMATCH"
	case errors.Is(err, ErrSequenceRegression):
		return "PKG_SEQUENCE_REGRESSION"
	default:
		return ""
	}
}
