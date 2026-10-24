// Package kmskeys is a KeyRing whose private keys stay in Google Cloud KMS
// (§9.1: the targets role in KMS under a dual-control release environment;
// §15 D85). It speaks the KMS REST API (v1) with a short-lived OAuth
// access token from the CI's OIDC exchange (REQ-SEC-030), so no Google SDK
// is linked and no credential file exists. Each named key maps to one
// EC_SIGN_ED25519 crypto key version; requests and answers carry CRC32C
// checksums, and trust.Sign verifies every signature against the key's
// public half before it is used.
package kmskeys

import (
	"bytes"
	"context"
	"crypto/ed25519"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"errors"
	"fmt"
	"hash/crc32"
	"io"
	"net/http"
	"regexp"
	"strconv"
	"strings"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// Endpoint is the Cloud KMS API.
const Endpoint = "https://cloudkms.googleapis.com"

// Algorithm is the only key algorithm accepted (Appendix C: Ed25519).
const Algorithm = "EC_SIGN_ED25519"

// requestTimeout bounds one KMS call; maxResponse bounds its answer.
const (
	requestTimeout = 30 * time.Second
	maxResponse    = 64 << 10
)

var (
	// ErrConfig is returned for a key name, version or token that is
	// missing or malformed.
	ErrConfig = errors.New("kmskeys: bad configuration")
	// ErrKMS is returned for a failed KMS call or an answer that does not
	// check out (status, algorithm, checksum).
	ErrKMS = errors.New("kmskeys: KMS call failed")
)

var versionPattern = regexp.MustCompile(`^projects/[a-z0-9-]+/locations/[a-z0-9-]+/keyRings/[A-Za-z0-9_-]+/cryptoKeys/[A-Za-z0-9_-]+/cryptoKeyVersions/[0-9]+$`)

var castagnoli = crc32.MakeTable(crc32.Castagnoli)

// Ring implements ports.KeyRing. Lookup reads Prefix+"<ROLE>_KEY_<N>" (the
// crypto key version resource of the named key) and Prefix+"ACCESS_TOKEN".
// Endpoint and Client default to the KMS API and http.DefaultClient.
type Ring struct {
	Prefix   string
	Lookup   func(string) (string, bool)
	Endpoint string
	Client   *http.Client
}

// Signer implements ports.KeyRing: it fetches and checks the version's
// public key; ErrNotFound when no version is configured for name.
func (r Ring) Signer(ctx context.Context, name string) (trust.Signer, error) {
	role, n, ok := strings.Cut(name, "-")
	if !ok || role == "" || n == "" || strings.ContainsAny(n, `-/\.`) || strings.ContainsAny(role, `/\.`) {
		return nil, fmt.Errorf("%w: key name %q is not <role>-<n>", ErrConfig, name)
	}
	variable := r.Prefix + strings.ToUpper(role) + "_KEY_" + strings.ToUpper(n)
	version, ok := r.Lookup(variable)
	if !ok || version == "" {
		return nil, fmt.Errorf("key %s (%s): %w", name, variable, ports.ErrNotFound)
	}
	if !versionPattern.MatchString(version) {
		return nil, fmt.Errorf("%w: %s is not a crypto key version resource", ErrConfig, variable)
	}
	token, ok := r.Lookup(r.Prefix + "ACCESS_TOKEN")
	if !ok || token == "" {
		return nil, fmt.Errorf("%w: %sACCESS_TOKEN is not set", ErrConfig, r.Prefix)
	}
	s := signer{ring: r, version: version, token: token}
	pub, err := s.fetchPublicKey(ctx)
	if err != nil {
		return nil, fmt.Errorf("key %s: %w", name, err)
	}
	s.pub = pub
	return s, nil
}

type signer struct {
	ring    Ring
	version string
	token   string
	pub     trust.PublicKey
}

func (s signer) PublicKey() trust.PublicKey { return s.pub }

// Sign asks KMS for the Ed25519 signature of message (Ed25519 signs the
// data itself, not a digest).
func (s signer) Sign(ctx context.Context, message []byte) ([]byte, error) {
	body, err := json.Marshal(map[string]string{
		"data":       base64.StdEncoding.EncodeToString(message),
		"dataCrc32c": strconv.FormatUint(uint64(crc32.Checksum(message, castagnoli)), 10),
	})
	if err != nil {
		return nil, fmt.Errorf("encode sign request: %w", err)
	}
	answer, err := call[signAnswer](ctx, s, http.MethodPost, s.version+":asymmetricSign", body)
	if err != nil {
		return nil, err
	}
	sig, err := base64.StdEncoding.DecodeString(answer.Signature)
	switch {
	case err != nil:
		return nil, fmt.Errorf("%w: signature is not base64", ErrKMS)
	case !answer.VerifiedDataCrc32c:
		return nil, fmt.Errorf("%w: KMS did not verify the data checksum", ErrKMS)
	case answer.Name != s.version:
		return nil, fmt.Errorf("%w: answered for %q", ErrKMS, answer.Name)
	case answer.SignatureCrc32c != strconv.FormatUint(uint64(crc32.Checksum(sig, castagnoli)), 10):
		return nil, fmt.Errorf("%w: signature checksum mismatch", ErrKMS)
	case len(sig) != ed25519.SignatureSize:
		return nil, fmt.Errorf("%w: signature is %d bytes", ErrKMS, len(sig))
	}
	return sig, nil
}

func (s signer) fetchPublicKey(ctx context.Context) (trust.PublicKey, error) {
	answer, err := call[publicKeyAnswer](ctx, s, http.MethodGet, s.version+"/publicKey", nil)
	if err != nil {
		return trust.PublicKey{}, err
	}
	if answer.Algorithm != Algorithm {
		return trust.PublicKey{}, fmt.Errorf("%w: algorithm %q, want %s", ErrKMS, answer.Algorithm, Algorithm)
	}
	if answer.PemCrc32c != strconv.FormatUint(uint64(crc32.Checksum([]byte(answer.PEM), castagnoli)), 10) {
		return trust.PublicKey{}, fmt.Errorf("%w: public key checksum mismatch", ErrKMS)
	}
	block, _ := pem.Decode([]byte(answer.PEM))
	if block == nil || block.Type != "PUBLIC KEY" {
		return trust.PublicKey{}, fmt.Errorf("%w: public key is not a PEM PUBLIC KEY", ErrKMS)
	}
	key, err := x509.ParsePKIXPublicKey(block.Bytes)
	if err != nil {
		return trust.PublicKey{}, fmt.Errorf("%w: public key: %w", ErrKMS, err)
	}
	raw, ok := key.(ed25519.PublicKey)
	if !ok {
		return trust.PublicKey{}, fmt.Errorf("%w: public key is a %T", ErrKMS, key)
	}
	return trust.NewPublicKey(raw)
}

// signAnswer is the asymmetricSign response.
type signAnswer struct {
	Signature          string `json:"signature"`
	SignatureCrc32c    string `json:"signatureCrc32c"`
	VerifiedDataCrc32c bool   `json:"verifiedDataCrc32c"`
	Name               string `json:"name"`
}

// publicKeyAnswer is the getPublicKey response.
type publicKeyAnswer struct {
	PEM       string `json:"pem"`
	Algorithm string `json:"algorithm"`
	PemCrc32c string `json:"pemCrc32c"`
}

type answer interface{ signAnswer | publicKeyAnswer }

// call sends one authorised request and decodes a 200 JSON answer.
func call[T answer](ctx context.Context, s signer, method, resource string, body []byte) (T, error) {
	var out T
	ctx, cancel := context.WithTimeout(ctx, requestTimeout)
	defer cancel()
	endpoint := s.ring.Endpoint
	if endpoint == "" {
		endpoint = Endpoint
	}
	var reader io.Reader = http.NoBody
	if body != nil {
		reader = bytes.NewReader(body)
	}
	req, err := http.NewRequestWithContext(ctx, method, endpoint+"/v1/"+resource, reader)
	if err != nil {
		return out, fmt.Errorf("%w: %w", ErrConfig, err)
	}
	req.Header.Set("Authorization", "Bearer "+s.token)
	if body != nil {
		req.Header.Set("Content-Type", "application/json")
	}
	client := s.ring.Client
	if client == nil {
		client = http.DefaultClient
	}
	resp, err := client.Do(req)
	if err != nil {
		return out, fmt.Errorf("%w: %w", ErrKMS, err)
	}
	defer resp.Body.Close() //nolint:errcheck // read-only answer; the decode error is what matters
	data, err := io.ReadAll(io.LimitReader(resp.Body, maxResponse))
	if err != nil {
		return out, fmt.Errorf("%w: read answer: %w", ErrKMS, err)
	}
	if resp.StatusCode != http.StatusOK {
		return out, fmt.Errorf("%w: %s %s: HTTP %d", ErrKMS, method, resource, resp.StatusCode)
	}
	if err := json.Unmarshal(data, &out); err != nil {
		return out, fmt.Errorf("%w: decode answer: %w", ErrKMS, err)
	}
	return out, nil
}
