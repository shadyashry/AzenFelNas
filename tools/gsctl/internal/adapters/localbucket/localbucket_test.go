package localbucket_test

import (
	"errors"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/localbucket"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

func TestObjectStoreContract_REQ_TEST_004(t *testing.T) {
	t.Run("localbucket", func(t *testing.T) {
		testsupport.ObjectStoreContract(t, func(t *testing.T) ports.ObjectStore { return localbucket.Bucket{Dir: t.TempDir()} })
	})
	t.Run("in-memory fake", func(t *testing.T) {
		testsupport.ObjectStoreContract(t, func(*testing.T) ports.ObjectStore { return testsupport.NewBucket() })
	})
}

func TestKeysOutsideTheBucketAreRefused(t *testing.T) {
	t.Parallel()
	b := localbucket.Bucket{Dir: t.TempDir()}
	for _, key := range []string{"../x", "dev/../../x", "/abs", `dev\x`, ".cache-control/dev/x", "dev//x", ""} {
		if err := b.PutObject(t.Context(), key, nil, ""); !errors.Is(err, localbucket.ErrBadKey) {
			t.Errorf("PutObject(%q) err = %v, want ErrBadKey", key, err)
		}
	}
}

// The handler serves objects as the CDN does (§9.1, REQ-DIST-005).
func TestHandlerServesObjectsWithTheirCachePolicy_REQ_DIST_005(t *testing.T) {
	t.Parallel()
	b := localbucket.Bucket{Dir: t.TempDir()}
	if err := b.PutObject(t.Context(), "dev/metadata/timestamp.json", []byte(`{}`), "public, max-age=300"); err != nil {
		t.Fatal(err)
	}
	if err := b.PutObject(t.Context(), "dev/packages/p/1/ab.dmpkg", []byte{0x1f, 0x8b}, "public, max-age=31536000, immutable"); err != nil {
		t.Fatal(err)
	}
	server := httptest.NewServer(b.Handler())
	t.Cleanup(server.Close)
	tests := []struct {
		method, path, cache, contentType string
		status                           int
	}{
		{http.MethodGet, "/dev/metadata/timestamp.json", "public, max-age=300", "application/json", http.StatusOK},
		{http.MethodHead, "/dev/packages/p/1/ab.dmpkg", "public, max-age=31536000, immutable", "application/octet-stream", http.StatusOK},
		{http.MethodGet, "/dev/metadata/root.json", "", "", http.StatusNotFound},
		{http.MethodGet, "/.cache-control/dev/metadata/timestamp.json", "", "", http.StatusNotFound},
		{http.MethodGet, "/dev/", "", "", http.StatusNotFound},
		{http.MethodPost, "/dev/metadata/timestamp.json", "", "", http.StatusMethodNotAllowed},
	}
	for _, tc := range tests {
		req, err := http.NewRequestWithContext(t.Context(), tc.method, server.URL+tc.path, http.NoBody)
		if err != nil {
			t.Fatal(err)
		}
		resp, err := server.Client().Do(req)
		if err != nil {
			t.Fatal(err)
		}
		_ = resp.Body.Close() // read-only test response
		if resp.StatusCode != tc.status {
			t.Errorf("%s %s = %d, want %d", tc.method, tc.path, resp.StatusCode, tc.status)
			continue
		}
		if tc.status == http.StatusOK && (resp.Header.Get("Cache-Control") != tc.cache || resp.Header.Get("Content-Type") != tc.contentType || resp.Header.Get("Content-Encoding") != "") {
			t.Errorf("%s %s headers %v", tc.method, tc.path, resp.Header)
		}
	}
}
