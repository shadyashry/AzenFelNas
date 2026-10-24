package main

import (
	"bytes"
	"context"
	"io"
	"net/http"
	"os"
	"path/filepath"
	"regexp"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/sysclock"
)

// lineWriter hands each write to a channel, so a test can read what a
// running command prints without sharing a buffer across goroutines.
type lineWriter chan string

func (w lineWriter) Write(p []byte) (int, error) {
	w <- string(p)
	return len(p), nil
}

// The committed dev channel (signed by gsctl with the dev keys) publishes
// into the §9.1 layout, republishing changes nothing, and the local CDN
// serves the exact bytes with the §9.1 cache policy (§15 D65).
func TestCLIPublishesAndServesTheLocalBucket_REQ_DIST_002_REQ_DIST_005(t *testing.T) {
	t.Parallel()
	vector := filepath.Join("testdata", "roundtrip", "dev")
	rootKeys := filepath.Join("keys", "dev", "root-keys.json")
	bucket := t.TempDir()

	expect(t, gsctl(t, nil, "publish", "-repo", vector, "-channel", "dev", "-bucket", bucket, "-root-keys", rootKeys),
		exitOK, "1 package(s) [prayer_profiles/2026.10.1], metadata [root, targets, snapshot, timestamp]")
	expect(t, gsctl(t, nil, "publish", "-repo", vector, "-channel", "dev", "-bucket", bucket, "-root-keys", rootKeys),
		exitOK, "0 package(s) [], metadata []")
	expect(t, gsctl(t, nil, "publish", "-repo", vector, "-channel", "production", "-bucket", bucket), exitUsage, "dev and lab")

	ctx, cancel := context.WithCancel(t.Context())
	out := make(lineWriter, 4)
	done := make(chan int, 1)
	go func() {
		done <- run(ctx, []string{"serve", "-bucket", bucket, "-addr", "127.0.0.1:0"},
			env{lookup: func(string) (string, bool) { return "", false }, clock: sysclock.Clock{}, stdout: out, stderr: io.Discard})
	}()
	var base string
	select {
	case line := <-out:
		base = regexp.MustCompile(`http://[^ ]+/`).FindString(line)
	case <-time.After(10 * time.Second):
		t.Fatal("serve did not start")
	}
	want, err := os.ReadFile(filepath.Join(vector, "metadata", "timestamp.json")) //nolint:gosec // the committed test vector
	if err != nil {
		t.Fatal(err)
	}
	req, err := http.NewRequestWithContext(t.Context(), http.MethodGet, base+"dev/metadata/timestamp.json", http.NoBody)
	if err != nil {
		t.Fatal(err)
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	got, err := io.ReadAll(resp.Body)
	_ = resp.Body.Close() // fully read above
	if err != nil || resp.StatusCode != http.StatusOK || !bytes.Equal(got, want) || resp.Header.Get("Cache-Control") != "public, max-age=300" {
		t.Fatalf("GET timestamp.json = %d %q, %d bytes, %v", resp.StatusCode, resp.Header.Get("Cache-Control"), len(got), err)
	}

	cancel()
	select {
	case code := <-done:
		if code != exitOK {
			t.Fatalf("serve exited %d", code)
		}
	case <-time.After(10 * time.Second):
		t.Fatal("serve did not stop")
	}
}

// pull restores a published channel into an empty repository; promote
// stages its reviewed targets for the channel above; the bucket flag
// accepts a directory or s3:// with its variables (§15 D85).
func TestCLIPullsAndPromotesFromTheBucket_REQ_DIST_002_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	vector := filepath.Join("testdata", "roundtrip", "dev")
	rootKeys := filepath.Join("keys", "dev", "root-keys.json")
	bucket := t.TempDir()
	expect(t, gsctl(t, nil, "publish", "-repo", vector, "-channel", "dev", "-bucket", bucket, "-root-keys", rootKeys), exitOK, "1 package(s)")

	pulled := t.TempDir()
	expect(t, gsctl(t, nil, "pull", "-repo", pulled, "-channel", "dev", "-bucket", bucket, "-root-keys", rootKeys),
		exitOK, "pulled: dev timestamp 1, snapshot 1, targets 1; 1 target(s)")
	expect(t, gsctl(t, nil, "verify", "-repo", pulled, "-root-keys", rootKeys), exitOK, "verified: root version 1")
	expect(t, gsctl(t, nil, "pull", "-repo", t.TempDir(), "-channel", "lab", "-bucket", bucket, "-root-keys", rootKeys),
		exitOK, "lab was never published")

	lab := t.TempDir()
	expect(t, gsctl(t, nil, "promote", "-repo", lab, "-from", "dev", "-to", "lab", "-sequence", "1", "-bucket", bucket, "-root-keys", rootKeys),
		exitOK, "staged for lab from dev targets 1: prayer_profiles/2026.10.1")
	if _, err := os.Stat(filepath.Join(lab, "staged", "prayer_profiles", "2026.10.1.json")); err != nil {
		t.Fatalf("promotion staged nothing: %v", err)
	}
	expect(t, gsctl(t, nil, "promote", "-repo", t.TempDir(), "-from", "dev", "-to", "lab", "-sequence", "2", "-bucket", bucket, "-root-keys", rootKeys),
		exitFailed, "reviewed 2")
	expect(t, gsctl(t, nil, "promote", "-repo", t.TempDir(), "-from", "lab", "-to", "beta", "-sequence", "1", "-bucket", bucket), exitUsage, "dev and lab")
	expect(t, gsctl(t, nil, "pull", "-repo", t.TempDir(), "-channel", "lab", "-bucket", "s3://dm-dist"), exitUsage, "endpoint")
	expect(t, gsctl(t, map[string]string{"DM_S3_ENDPOINT": "acct.r2.cloudflarestorage.com", "DM_S3_ACCESS_KEY_ID": "k", "DM_S3_SECRET_ACCESS_KEY": "s", "DM_S3_INSECURE": "1"},
		"pull", "-repo", t.TempDir(), "-channel", "lab", "-bucket", "s3://dm-dist"), exitUsage, "loopback")
	expect(t, gsctl(t, nil, "pull", "-repo", t.TempDir(), "-channel", "lab", "-bucket", "s3:///x"), exitUsage, "s3://<bucket>")
}
