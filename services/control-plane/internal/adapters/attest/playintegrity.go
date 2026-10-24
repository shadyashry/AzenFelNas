package attest

import (
	"bytes"
	"context"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"slices"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// PlayIntegrityEndpoint is Google's decode endpoint (v1).
const PlayIntegrityEndpoint = "https://playintegrity.googleapis.com/v1/"

// TokenSource returns an OAuth 2.0 access token for the Play Integrity scope.
type TokenSource interface {
	Token(ctx context.Context) (string, error)
}

// PlayIntegrity verifies Play Integrity standard-request tokens by asking
// Google to decode them (server-side decryption, §15 D86).
type PlayIntegrity struct {
	PackageName string
	// CertSHA256 lists the accepted app signing certificate digests
	// (base64url without padding, as Google reports them); empty accepts any
	// Play-recognised signing certificate.
	CertSHA256 []string
	Tokens     TokenSource
	Client     *http.Client
	Clock      ports.Clock
	// Endpoint overrides PlayIntegrityEndpoint in tests.
	Endpoint string
	// MaxAge bounds the token's age; zero means 5 minutes.
	MaxAge time.Duration
}

// ExpectedRequestHash is the requestHash the app passes to the standard
// request: base64url(sha256(keyId || binding)), unpadded.
func ExpectedRequestHash(keyID domain.AttestationKeyID, binding [32]byte) string {
	h := sha256.New()
	h.Write(keyID)
	h.Write(binding[:])
	return base64.RawURLEncoding.EncodeToString(h.Sum(nil))
}

type decodeResponse struct {
	TokenPayloadExternal struct {
		RequestDetails struct {
			RequestPackageName string `json:"requestPackageName"`
			RequestHash        string `json:"requestHash"`
			TimestampMillis    string `json:"timestampMillis"`
		} `json:"requestDetails"`
		AppIntegrity struct {
			AppRecognitionVerdict   string   `json:"appRecognitionVerdict"`
			PackageName             string   `json:"packageName"`
			CertificateSha256Digest []string `json:"certificateSha256Digest"`
		} `json:"appIntegrity"`
		DeviceIntegrity struct {
			DeviceRecognitionVerdict []string `json:"deviceRecognitionVerdict"`
		} `json:"deviceIntegrity"`
	} `json:"tokenPayloadExternal"`
}

// Verify implements ports.AttestationVerifier.
func (v PlayIntegrity) Verify(ctx context.Context, a domain.Attestation, _ domain.Pseudonym) error {
	payload, err := v.decode(ctx, a.Token)
	if err != nil {
		return err
	}
	p := payload.TokenPayloadExternal
	invalid := func(why string) error { return fmt.Errorf("%w: play integrity: %s", domain.ErrAttestationInvalid, why) }
	if p.RequestDetails.RequestPackageName != v.PackageName || p.AppIntegrity.PackageName != v.PackageName {
		return invalid("package name")
	}
	if p.RequestDetails.RequestHash != ExpectedRequestHash(a.KeyID, a.Binding) {
		return invalid("request hash")
	}
	var millis int64
	if _, err := fmt.Sscan(p.RequestDetails.TimestampMillis, &millis); err != nil {
		return invalid("timestamp")
	}
	maxAge := v.MaxAge
	if maxAge == 0 {
		maxAge = 5 * time.Minute
	}
	age := v.Clock.Now().Sub(time.UnixMilli(millis))
	if age > maxAge || age < -time.Minute {
		return invalid("stale token")
	}
	if p.AppIntegrity.AppRecognitionVerdict != "PLAY_RECOGNIZED" {
		return invalid("app not recognised")
	}
	if len(v.CertSHA256) > 0 && !slices.ContainsFunc(p.AppIntegrity.CertificateSha256Digest, func(d string) bool { return slices.Contains(v.CertSHA256, d) }) {
		return invalid("signing certificate")
	}
	if !slices.Contains(p.DeviceIntegrity.DeviceRecognitionVerdict, "MEETS_DEVICE_INTEGRITY") {
		return invalid("device integrity")
	}
	return nil
}

func (v PlayIntegrity) decode(ctx context.Context, token []byte) (decodeResponse, error) {
	var out decodeResponse
	access, err := v.Tokens.Token(ctx)
	if err != nil {
		return out, fmt.Errorf("%w: access token: %w", domain.ErrAttestationUnavailable, err)
	}
	body, err := json.Marshal(map[string]string{"integrity_token": string(token)})
	if err != nil {
		return out, fmt.Errorf("%w: encode: %w", domain.ErrAttestationUnavailable, err)
	}
	endpoint := v.Endpoint
	if endpoint == "" {
		endpoint = PlayIntegrityEndpoint
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, endpoint+v.PackageName+":decodeIntegrityToken", bytes.NewReader(body))
	if err != nil {
		return out, fmt.Errorf("%w: request: %w", domain.ErrAttestationUnavailable, err)
	}
	req.Header.Set("Authorization", "Bearer "+access)
	req.Header.Set("Content-Type", "application/json")
	res, err := v.Client.Do(req)
	if err != nil {
		return out, fmt.Errorf("%w: decode: %w", domain.ErrAttestationUnavailable, err)
	}
	defer func() { _ = res.Body.Close() }() // the body was read; a close error changes nothing
	raw, err := io.ReadAll(io.LimitReader(res.Body, 1<<20))
	if err != nil {
		return out, fmt.Errorf("%w: read: %w", domain.ErrAttestationUnavailable, err)
	}
	switch {
	case res.StatusCode == http.StatusBadRequest:
		return out, fmt.Errorf("%w: play integrity rejected the token", domain.ErrAttestationInvalid)
	case res.StatusCode != http.StatusOK:
		return out, fmt.Errorf("%w: play integrity status %d", domain.ErrAttestationUnavailable, res.StatusCode)
	}
	if err := json.Unmarshal(raw, &out); err != nil {
		return out, fmt.Errorf("%w: decode response: %w", domain.ErrAttestationUnavailable, err)
	}
	return out, nil
}
