package trust

import (
	"bytes"
	"crypto/sha256"
	"encoding/base64"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"slices"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// Envelope is one decoded metadata file: the typed model, the canonical
// bytes its signatures cover, and the address of the file itself.
type Envelope struct {
	Metadata tuf.Metadata
	// Length and SHA256 address the file's exact bytes, which the parent
	// role pins (snapshot pins targets.json, timestamp pins snapshot.json).
	Length int
	SHA256 string

	canonicalSigned []byte
}

// ParseEnvelope decodes a metadata file. The signatures are checked later,
// against the JCS form of the file's own `signed` member (not of the
// re-encoded model), so a verifier never signs off on bytes it did not
// read (REQ-DIST-004).
func ParseEnvelope(file []byte) (Envelope, error) {
	var raw struct {
		Signed json.RawMessage `json:"signed"`
	}
	if err := json.Unmarshal(file, &raw); err != nil {
		return Envelope{}, fmt.Errorf("%w: %w", ErrMalformed, err)
	}
	canonical, err := jcs.Canonicalize(raw.Signed)
	if err != nil {
		return Envelope{}, fmt.Errorf("%w: signed: %w", ErrMalformed, err)
	}
	var m tuf.Metadata
	if err := json.Unmarshal(file, &m); err != nil {
		return Envelope{}, fmt.Errorf("%w: %w", ErrMalformed, err)
	}
	sum := sha256.Sum256(file)
	return Envelope{Metadata: m, Length: len(file), SHA256: hex.EncodeToString(sum[:]), canonicalSigned: canonical}, nil
}

// Sequence is the document's monotonic number: `version` for root,
// `sequence` for the other roles.
func (e Envelope) Sequence() int {
	switch doc := e.Metadata.Signed.Variant.(type) {
	case tuf.Root:
		return doc.Version
	case tuf.Targets:
		return doc.Sequence
	case tuf.Snapshot:
		return doc.Sequence
	case tuf.Timestamp:
		return doc.Sequence
	default:
		return 0
	}
}

// Sign signs signed with every signer and returns the envelope, one
// signature per distinct key, sorted by keyId. Ed25519 over the JCS form of
// signed (REQ-DIST-004).
func Sign(signed tuf.Signed, signers []Signer) (tuf.Metadata, error) {
	canonical, err := jcs.Marshal(signed)
	if err != nil {
		return tuf.Metadata{}, fmt.Errorf("canonicalise signed: %w", err)
	}
	sigs := make([]tuf.Signature, 0, len(signers))
	seen := map[string]bool{}
	for _, s := range signers {
		id := s.PublicKey().ID()
		if seen[id] {
			continue
		}
		seen[id] = true
		sig, err := s.Sign(canonical)
		if err != nil {
			return tuf.Metadata{}, fmt.Errorf("sign with key %s: %w", id, err)
		}
		if !s.PublicKey().Verify(canonical, sig) {
			return tuf.Metadata{}, fmt.Errorf("%w: signer %s produced a signature its public key rejects", ErrKeyMismatch, id)
		}
		sigs = append(sigs, tuf.Signature{KeyID: id, Sig: base64.StdEncoding.EncodeToString(sig)})
	}
	slices.SortFunc(sigs, func(a, b tuf.Signature) int { return strings.Compare(a.KeyID, b.KeyID) })
	return tuf.Metadata{Signed: signed, Signatures: sigs}, nil
}

// EncodeFile writes m as a metadata file: two-space indented JSON with a
// final newline, HTML characters unescaped. The bytes are what the parent
// role hashes; signatures cover JCS(signed) only (§15 D59).
func EncodeFile(m tuf.Metadata) ([]byte, error) {
	var buf bytes.Buffer
	enc := json.NewEncoder(&buf)
	enc.SetEscapeHTML(false)
	enc.SetIndent("", "  ")
	if err := enc.Encode(m); err != nil {
		return nil, fmt.Errorf("encode metadata: %w", err)
	}
	return buf.Bytes(), nil
}

// VerifyThreshold checks that at least threshold distinct keys of keyIDs
// that appear in keys have a valid signature (REQ-DIST-001). Signatures by
// unknown keys are ignored and a key counts once.
func (e Envelope) VerifyThreshold(role string, keys []PublicKey, keyIDs []string, threshold int) error {
	if threshold < 1 {
		return fmt.Errorf("%w: %s threshold %d", ErrMalformed, role, threshold)
	}
	allowed := map[string]PublicKey{}
	for _, k := range keys {
		if slices.Contains(keyIDs, k.ID()) {
			allowed[k.ID()] = k
		}
	}
	valid := map[string]bool{}
	for _, s := range e.Metadata.Signatures {
		key, ok := allowed[s.KeyID]
		if !ok || valid[s.KeyID] {
			continue
		}
		sig, err := base64.StdEncoding.Strict().DecodeString(s.Sig)
		if err != nil {
			continue
		}
		if key.Verify(e.canonicalSigned, sig) {
			valid[s.KeyID] = true
		}
	}
	if len(valid) < threshold {
		return fmt.Errorf("%w: %s has %d valid signature(s), needs %d", ErrSignature, role, len(valid), threshold)
	}
	return nil
}
