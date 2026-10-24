package domain

// Platform is the attesting platform.
type Platform string

// Platform values.
const (
	PlatformAndroid Platform = "android"
	PlatformIOS     Platform = "ios"
)

// Attestation is the evidence a client sends with a write (REQ-API-004).
// Binding is the request digest the token must commit to, so a token cannot
// be replayed on another body (§15 D86).
type Attestation struct {
	Platform Platform
	KeyID    AttestationKeyID
	// Token is the Play Integrity token (Android) or the App Attest assertion (iOS).
	Token []byte
	// KeyAttestation is the App Attest attestation object, sent with the first
	// assertion of a key on a UTC day (iOS only).
	KeyAttestation []byte
	Binding        [32]byte
}
