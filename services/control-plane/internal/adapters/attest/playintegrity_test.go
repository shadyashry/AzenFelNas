package attest_test

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"net/http/httptest"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/attest"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
)

type fixedClock struct{ t time.Time }

func (c fixedClock) Now() time.Time { return c.t }

type staticTokens struct{}

func (staticTokens) Token(context.Context) (string, error) { return "access", nil }

var now = time.Date(2026, 10, 24, 9, 30, 0, 0, time.UTC)

func payload(hash string, at time.Time, verdict string, device ...string) map[string]any {
	return map[string]any{"tokenPayloadExternal": map[string]any{
		"requestDetails":  map[string]any{"requestPackageName": "app.dailymuslim", "requestHash": hash, "timestampMillis": fmt.Sprint(at.UnixMilli())},
		"appIntegrity":    map[string]any{"appRecognitionVerdict": verdict, "packageName": "app.dailymuslim", "certificateSha256Digest": []string{"cert-a"}},
		"deviceIntegrity": map[string]any{"deviceRecognitionVerdict": device},
	}}
}

func TestREQAPI004PlayIntegrityVerdicts(t *testing.T) {
	att := domain.Attestation{Platform: domain.PlatformAndroid, KeyID: []byte("installation-key-0001"), Token: []byte("tok"), Binding: [32]byte{7}}
	good := attest.ExpectedRequestHash(att.KeyID, att.Binding)
	cases := []struct {
		name   string
		status int
		body   map[string]any
		certs  []string
		want   error
	}{
		{"genuine app on a genuine device", 200, payload(good, now.Add(-time.Minute), "PLAY_RECOGNIZED", "MEETS_DEVICE_INTEGRITY"), []string{"cert-a"}, nil},
		{"token for another request", 200, payload("other", now, "PLAY_RECOGNIZED", "MEETS_DEVICE_INTEGRITY"), nil, domain.ErrAttestationInvalid},
		{"stale token", 200, payload(good, now.Add(-6*time.Minute), "PLAY_RECOGNIZED", "MEETS_DEVICE_INTEGRITY"), nil, domain.ErrAttestationInvalid},
		{"unrecognised app", 200, payload(good, now, "UNRECOGNIZED_VERSION", "MEETS_DEVICE_INTEGRITY"), nil, domain.ErrAttestationInvalid},
		{"basic integrity only", 200, payload(good, now, "PLAY_RECOGNIZED", "MEETS_BASIC_INTEGRITY"), nil, domain.ErrAttestationInvalid},
		{"another signing certificate", 200, payload(good, now, "PLAY_RECOGNIZED", "MEETS_DEVICE_INTEGRITY"), []string{"cert-b"}, domain.ErrAttestationInvalid},
		{"malformed token", 400, map[string]any{}, nil, domain.ErrAttestationInvalid},
		{"google unavailable", 503, map[string]any{}, nil, domain.ErrAttestationUnavailable},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
				if r.URL.Path != "/app.dailymuslim:decodeIntegrityToken" || r.Header.Get("Authorization") != "Bearer access" {
					t.Errorf("request %s %q", r.URL.Path, r.Header.Get("Authorization"))
				}
				var in map[string]string
				if err := json.NewDecoder(r.Body).Decode(&in); err != nil || in["integrity_token"] != "tok" {
					t.Errorf("body %v %v", in, err)
				}
				w.WriteHeader(tc.status)
				_ = json.NewEncoder(w).Encode(tc.body)
			}))
			defer srv.Close()
			v := attest.PlayIntegrity{
				PackageName: "app.dailymuslim", CertSHA256: tc.certs, Tokens: staticTokens{},
				Client: srv.Client(), Clock: fixedClock{now}, Endpoint: srv.URL + "/",
			}
			err := v.Verify(context.Background(), att, domain.Pseudonym{})
			if tc.want == nil && err != nil || tc.want != nil && !errors.Is(err, tc.want) {
				t.Fatalf("err = %v, want %v", err, tc.want)
			}
		})
	}
}

func TestMetadataTokensAreCachedUntilNearExpiry(t *testing.T) {
	calls := 0
	srv := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		calls++
		if r.Header.Get("Metadata-Flavor") != "Google" {
			t.Error("missing Metadata-Flavor")
		}
		_, _ = fmt.Fprintf(w, `{"access_token":"t%d","expires_in":3600}`, calls)
	}))
	defer srv.Close()
	m := &attest.MetadataTokens{Client: srv.Client(), Endpoint: srv.URL}
	for range 3 {
		tok, err := m.Token(context.Background())
		if err != nil || tok != "t1" {
			t.Fatalf("token = %q, %v", tok, err)
		}
	}
	if calls != 1 {
		t.Fatalf("metadata called %d times", calls)
	}
}

func TestByPlatformDispatchesAndUnconfiguredFailsClosed(t *testing.T) {
	v := attest.ByPlatform{Android: attest.Unconfigured{Reason: "no android"}, IOS: attest.Unconfigured{Reason: "no ios"}}
	for _, p := range []domain.Platform{domain.PlatformAndroid, domain.PlatformIOS} {
		if err := v.Verify(context.Background(), domain.Attestation{Platform: p}, domain.Pseudonym{}); !errors.Is(err, domain.ErrAttestationUnavailable) {
			t.Fatalf("%s: %v", p, err)
		}
	}
	if err := v.Verify(context.Background(), domain.Attestation{Platform: "web"}, domain.Pseudonym{}); !errors.Is(err, domain.ErrAttestationInvalid) {
		t.Fatalf("web: %v", err)
	}
}
