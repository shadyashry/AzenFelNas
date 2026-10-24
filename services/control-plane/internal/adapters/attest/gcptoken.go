package attest

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"
	"time"
)

// MetadataEndpoint serves the Cloud Run service account's access token
// with the Play Integrity scope.
const MetadataEndpoint = "http://metadata.google.internal/computeMetadata/v1/instance/service-accounts/default/token" +
	"?scopes=https://www.googleapis.com/auth/playintegrity"

// MetadataTokens fetches and caches the runtime service account's access
// token from the metadata server. Safe for concurrent use.
type MetadataTokens struct {
	Client *http.Client
	// Endpoint overrides MetadataEndpoint in tests.
	Endpoint string

	mu      sync.Mutex
	token   string
	expires time.Time
}

// Token implements TokenSource; it refreshes a minute before expiry.
func (m *MetadataTokens) Token(ctx context.Context) (string, error) {
	m.mu.Lock()
	defer m.mu.Unlock()
	if m.token != "" && time.Until(m.expires) > time.Minute {
		return m.token, nil
	}
	endpoint := m.Endpoint
	if endpoint == "" {
		endpoint = MetadataEndpoint
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, endpoint, http.NoBody)
	if err != nil {
		return "", fmt.Errorf("metadata token: %w", err)
	}
	req.Header.Set("Metadata-Flavor", "Google")
	res, err := m.Client.Do(req)
	if err != nil {
		return "", fmt.Errorf("metadata token: %w", err)
	}
	defer func() { _ = res.Body.Close() }() // the body was read; a close error changes nothing
	if res.StatusCode != http.StatusOK {
		return "", fmt.Errorf("metadata token: status %d", res.StatusCode)
	}
	var body struct {
		AccessToken string `json:"access_token"`
		ExpiresIn   int    `json:"expires_in"`
	}
	if err := json.NewDecoder(io.LimitReader(res.Body, 64<<10)).Decode(&body); err != nil {
		return "", fmt.Errorf("metadata token: %w", err)
	}
	if body.AccessToken == "" {
		return "", fmt.Errorf("metadata token: empty token")
	}
	m.token, m.expires = body.AccessToken, time.Now().Add(time.Duration(body.ExpiresIn)*time.Second)
	return m.token, nil
}
