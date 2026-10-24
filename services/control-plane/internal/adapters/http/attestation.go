package http

import (
	"encoding/base64"
	"errors"
	"net/http"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
)

// Attestation request headers (§15 D86). All values are unpadded base64url.
const (
	HeaderPlatform       = "X-DM-Attestation-Platform"
	HeaderKeyID          = "X-DM-Attestation-Key"
	HeaderToken          = "X-DM-Attestation-Token" //nolint:gosec // G101: a header name, not a credential
	HeaderKeyAttestation = "X-DM-Key-Attestation"
)

var errMalformedAttestation = errors.New("http: malformed attestation headers")

// parseAttestation returns nil when the request carries no attestation, the
// attestation bound to this request, or errMalformedAttestation.
func parseAttestation(r *http.Request, body []byte) (*domain.Attestation, error) {
	platform := r.Header.Get(HeaderPlatform)
	if platform == "" && r.Header.Get(HeaderKeyID) == "" && r.Header.Get(HeaderToken) == "" {
		return nil, nil //nolint:nilnil // "no attestation" is a valid, non-error outcome
	}
	a := &domain.Attestation{
		Binding: domain.RequestBinding(r.Method, r.URL.Path, r.Header.Get("Idempotency-Key"), body),
	}
	switch domain.Platform(platform) {
	case domain.PlatformAndroid, domain.PlatformIOS:
		a.Platform = domain.Platform(platform)
	default:
		return nil, errMalformedAttestation
	}
	key, err := decode(r.Header.Get(HeaderKeyID))
	if err != nil || len(key) < 16 || len(key) > 64 {
		return nil, errMalformedAttestation
	}
	token, err := decode(r.Header.Get(HeaderToken))
	if err != nil || len(token) == 0 {
		return nil, errMalformedAttestation
	}
	a.KeyID, a.Token = key, token
	if v := r.Header.Get(HeaderKeyAttestation); v != "" {
		if a.KeyAttestation, err = decode(v); err != nil {
			return nil, errMalformedAttestation
		}
	}
	return a, nil
}

func decode(s string) ([]byte, error) {
	b, err := base64.RawURLEncoding.DecodeString(s)
	if err != nil {
		return nil, errMalformedAttestation
	}
	return b, nil
}
