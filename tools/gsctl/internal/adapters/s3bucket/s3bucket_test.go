package s3bucket_test

import (
	"crypto/rand"
	"encoding/hex"
	"errors"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/cdnstandin"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/s3bucket"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

// The live half needs an S3 endpoint on loopback (§15 D85: SeaweedFS in
// CI and in the cloud session); without GSCTL_S3_TEST_ENDPOINT it skips.
func liveConfig(t *testing.T) s3bucket.Config {
	t.Helper()
	endpoint := os.Getenv("GSCTL_S3_TEST_ENDPOINT")
	if endpoint == "" {
		t.Skip("GSCTL_S3_TEST_ENDPOINT not set (see tools/gsctl/README.md)")
	}
	cfg := s3bucket.Config{
		Endpoint:        endpoint,
		AccessKeyID:     os.Getenv("GSCTL_S3_TEST_ACCESS_KEY_ID"),
		SecretAccessKey: os.Getenv("GSCTL_S3_TEST_SECRET_ACCESS_KEY"),
		Insecure:        true,
	}
	client, err := minio.New(cfg.Endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(cfg.AccessKeyID, cfg.SecretAccessKey, ""),
		Region: s3bucket.Region,
	})
	if err != nil {
		t.Fatal(err)
	}
	suffix := make([]byte, 6)
	if _, err := rand.Read(suffix); err != nil {
		t.Fatal(err)
	}
	cfg.Bucket = "gsctl-test-" + hex.EncodeToString(suffix)
	if err := client.MakeBucket(t.Context(), cfg.Bucket, minio.MakeBucketOptions{Region: s3bucket.Region}); err != nil {
		t.Fatalf("make bucket: %v", err)
	}
	return cfg
}

func newLive(t *testing.T, prefix string) s3bucket.Bucket {
	t.Helper()
	cfg := liveConfig(t)
	cfg.Prefix = prefix
	b, err := s3bucket.New(cfg)
	if err != nil {
		t.Fatal(err)
	}
	return b
}

func TestObjectStoreContract_REQ_TEST_004(t *testing.T) {
	t.Run("s3bucket", func(t *testing.T) {
		testsupport.ObjectStoreContract(t, func(t *testing.T) ports.ObjectStore { return newLive(t, "") })
	})
	t.Run("s3bucket with a prefix", func(t *testing.T) {
		testsupport.ObjectStoreContract(t, func(t *testing.T) ports.ObjectStore { return newLive(t, "staging") })
	})
}

func TestStoredCachePolicyIsServed_REQ_DIST_005(t *testing.T) {
	b := newLive(t, "")
	if err := b.PutObject(t.Context(), "lab/metadata/timestamp.json", []byte(`{}`), "public, max-age=300"); err != nil {
		t.Fatal(err)
	}
	if err := b.PutObject(t.Context(), "lab/packages/p/1/ab.dmpkg", []byte{0x1f, 0x8b}, "public, max-age=31536000, immutable"); err != nil {
		t.Fatal(err)
	}
	server := httptest.NewServer(cdnstandin.Handler(b))
	t.Cleanup(server.Close)
	tests := []struct {
		path, cache, contentType string
		status                   int
	}{
		{"/lab/metadata/timestamp.json", "public, max-age=300", "application/json", http.StatusOK},
		{"/lab/packages/p/1/ab.dmpkg", "public, max-age=31536000, immutable", "application/octet-stream", http.StatusOK},
		{"/lab/metadata/root.json", "", "", http.StatusNotFound},
		{"/lab/../x", "", "", http.StatusNotFound},
	}
	for _, tc := range tests {
		req, err := http.NewRequestWithContext(t.Context(), http.MethodGet, server.URL+tc.path, http.NoBody)
		if err != nil {
			t.Fatal(err)
		}
		resp, err := server.Client().Do(req)
		if err != nil {
			t.Fatal(err)
		}
		_ = resp.Body.Close() // read-only test response
		if resp.StatusCode != tc.status {
			t.Errorf("GET %s = %d, want %d", tc.path, resp.StatusCode, tc.status)
			continue
		}
		if tc.status == http.StatusOK && (resp.Header.Get("Cache-Control") != tc.cache || resp.Header.Get("Content-Type") != tc.contentType) {
			t.Errorf("GET %s headers %v", tc.path, resp.Header)
		}
	}
}

func TestKeysOutsideTheLayoutAreRefusedBeforeAnyRequest(t *testing.T) {
	t.Parallel()
	// The endpoint is never contacted: the key check comes first.
	b, err := s3bucket.New(s3bucket.Config{Endpoint: "127.0.0.1:1", Bucket: "b", AccessKeyID: "k", SecretAccessKey: "s", Insecure: true})
	if err != nil {
		t.Fatal(err)
	}
	for _, key := range []string{"", "../x", "lab/.hidden", `lab\x`, "lab//x"} {
		if err := b.PutObject(t.Context(), key, nil, ""); !errors.Is(err, ports.ErrBadKey) {
			t.Errorf("PutObject(%q) err = %v, want ErrBadKey", key, err)
		}
		if _, err := b.GetObject(t.Context(), key); !errors.Is(err, ports.ErrBadKey) {
			t.Errorf("GetObject(%q) err = %v, want ErrBadKey", key, err)
		}
	}
}

func TestConfigIsCheckedBeforeUse(t *testing.T) {
	t.Parallel()
	good := s3bucket.Config{Endpoint: "acct.r2.cloudflarestorage.com", Bucket: "dm-dist", AccessKeyID: "k", SecretAccessKey: "s"}
	tests := []struct {
		name string
		edit func(*s3bucket.Config)
		ok   bool
	}{
		{"R2 over HTTPS", func(*s3bucket.Config) {}, true},
		{"a prefix", func(c *s3bucket.Config) { c.Prefix = "/staging/" }, true},
		{"plain HTTP to loopback", func(c *s3bucket.Config) { c.Endpoint, c.Insecure = "127.0.0.1:8333", true }, true},
		{"plain HTTP elsewhere", func(c *s3bucket.Config) { c.Insecure = true }, false},
		{"a scheme in the endpoint", func(c *s3bucket.Config) { c.Endpoint = "https://acct.r2.cloudflarestorage.com" }, false},
		{"no bucket", func(c *s3bucket.Config) { c.Bucket = "" }, false},
		{"no secret", func(c *s3bucket.Config) { c.SecretAccessKey = "" }, false},
		{"a dot prefix", func(c *s3bucket.Config) { c.Prefix = ".x" }, false},
	}
	for _, tc := range tests {
		cfg := good
		tc.edit(&cfg)
		_, err := s3bucket.New(cfg)
		if tc.ok != (err == nil) || (err != nil && !errors.Is(err, s3bucket.ErrConfig)) {
			t.Errorf("%s: err = %v", tc.name, err)
		}
	}
}
