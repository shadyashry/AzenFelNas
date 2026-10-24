package trust

import (
	"context"
	"crypto/ed25519"
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"strings"
)

// PublicKey is an Ed25519 public key with its keyId (§15 D17): the
// lowercase hex SHA-256 of the 32 raw key bytes.
type PublicKey struct {
	id  string
	key ed25519.PublicKey
}

// NewPublicKey wraps the 32 raw bytes of an Ed25519 public key.
func NewPublicKey(raw []byte) (PublicKey, error) {
	if len(raw) != ed25519.PublicKeySize {
		return PublicKey{}, fmt.Errorf("%w: public key has %d bytes, want %d", ErrMalformed, len(raw), ed25519.PublicKeySize)
	}
	sum := sha256.Sum256(raw)
	return PublicKey{id: hex.EncodeToString(sum[:]), key: ed25519.PublicKey(append([]byte(nil), raw...))}, nil
}

// ParsePublicKeyHex reads the lowercase hex of the 32 raw key bytes.
func ParsePublicKeyHex(s string) (PublicKey, error) {
	if len(s) != 2*ed25519.PublicKeySize || s != strings.ToLower(s) {
		return PublicKey{}, fmt.Errorf("%w: public key %q is not 64 lowercase hex digits", ErrMalformed, s)
	}
	raw, err := hex.DecodeString(s)
	if err != nil {
		return PublicKey{}, fmt.Errorf("%w: public key: %w", ErrMalformed, err)
	}
	return NewPublicKey(raw)
}

// ID is the keyId.
func (k PublicKey) ID() string { return k.id }

// Hex is the lowercase hex of the raw key, the schema's `public`.
func (k PublicKey) Hex() string { return hex.EncodeToString(k.key) }

// Verify reports whether sig is a valid Ed25519 signature of message.
func (k PublicKey) Verify(message, sig []byte) bool {
	return len(k.key) == ed25519.PublicKeySize && ed25519.Verify(k.key, message, sig)
}

// Equal reports whether k and other are the same key.
func (k PublicKey) Equal(other PublicKey) bool { return k.id == other.id }

// Signer produces Ed25519 signatures with one private key: a PEM file for
// the dev keys, Cloud KMS for production (S25, S27). Implementations never
// expose the private key.
type Signer interface {
	// PublicKey is the key the signatures verify against.
	PublicKey() PublicKey
	// Sign returns the 64-byte Ed25519 signature of message; ctx bounds a
	// remote signer (Cloud KMS, §15 D85).
	Sign(ctx context.Context, message []byte) ([]byte, error)
}

// NamedKey is a public key with the name its files use ("root-1").
type NamedKey struct {
	Name string
	Key  PublicKey
}

// RoleKeys are the keys allowed to sign a role and how many must.
type RoleKeys struct {
	Threshold int
	Keys      []NamedKey
}

// KeyConfig assigns keys to the four roles; it is what a root document
// is built from.
type KeyConfig struct {
	Roles map[RoleName]RoleKeys
}

// Anchor is the root key set a client already trusts: the keys
// embedded in the app for the first root, the previous root's root role
// for a rotation (Appendix C).
type Anchor struct {
	Keys      []PublicKey
	Threshold int
}
