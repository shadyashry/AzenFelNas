package main

import (
	"bytes"
	"context"
	"encoding/base64"
	"io"
	"net"
	"net/http"
	"os"
	"strings"
	"testing"
	"time"
)

func getenv(m map[string]string) func(string) string { return func(k string) string { return m[k] } }

func TestRunRejectsBadConfigurationAndUnknownCommands(t *testing.T) {
	t.Parallel()
	var stderr bytes.Buffer
	if got := run(context.Background(), nil, getenv(map[string]string{"DM_ENV": "production", "DM_STORE": "memory"}), &stderr); got != 2 {
		t.Fatalf("bad config: run = %d, want 2", got)
	}
	if got := run(context.Background(), []string{"deploy"}, getenv(map[string]string{"DM_STORE": "memory"}), &stderr); got != 1 {
		t.Fatalf("unknown command: run = %d, want 1", got)
	}
	if !strings.Contains(stderr.String(), `"severity":"ERROR"`) {
		t.Fatalf("log lines lack the Cloud Logging severity: %s", stderr.String())
	}
}

func freeAddr(t *testing.T) string {
	t.Helper()
	l, err := net.Listen("tcp", "127.0.0.1:0")
	if err != nil {
		t.Fatal(err)
	}
	addr := l.Addr().String()
	if err := l.Close(); err != nil {
		t.Fatal(err)
	}
	return addr
}

// TestServeWiresTheAPIAndFailsClosedWithoutAttestationConfig runs the real
// composition root on a socket with the memory store and no platform
// credentials: health is up, and attested writes are refused (REQ-API-004).
func TestServeWiresTheAPIAndFailsClosedWithoutAttestationConfig(t *testing.T) {
	t.Parallel()
	addr := freeAddr(t)
	ctx, cancel := context.WithCancel(context.Background())
	done := make(chan int, 1)
	var logs bytes.Buffer
	go func() {
		done <- run(ctx, []string{"serve"}, getenv(map[string]string{"DM_STORE": "memory", "DM_HTTP_ADDR": addr}), &lockedWriter{w: &logs})
	}()
	base := "http://" + addr
	client := &http.Client{Timeout: 2 * time.Second}
	deadline := time.Now().Add(5 * time.Second)
	for {
		res, err := client.Get(base + "/healthz") //nolint:noctx // test poll
		if err == nil {
			_ = res.Body.Close()
			break
		}
		if time.Now().After(deadline) {
			t.Fatalf("server did not start: %v", err)
		}
		time.Sleep(20 * time.Millisecond)
	}
	req, err := http.NewRequestWithContext(ctx, http.MethodPost, base+"/v1/feedback/corrections",
		strings.NewReader(`{"schemaVersion":1,"kind":"other","payload":{"note":"x"}}`))
	if err != nil {
		t.Fatal(err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Idempotency-Key", "0123456789abcdef0123")
	req.Header.Set("X-DM-Attestation-Platform", "ios")
	req.Header.Set("X-DM-Attestation-Key", base64.RawURLEncoding.EncodeToString(make([]byte, 32)))
	req.Header.Set("X-DM-Attestation-Token", "dG9rZW4")
	res, err := client.Do(req)
	if err != nil {
		t.Fatal(err)
	}
	body, err := io.ReadAll(res.Body)
	_ = res.Body.Close()
	if err != nil {
		t.Fatal(err)
	}
	if res.StatusCode != http.StatusServiceUnavailable || !strings.Contains(string(body), `"/problems/unavailable"`) {
		t.Fatalf("unconfigured iOS attestation: %d %s", res.StatusCode, body)
	}
	cancel()
	select {
	case code := <-done:
		if code != 0 {
			t.Fatalf("serve exited %d", code)
		}
	case <-time.After(15 * time.Second):
		t.Fatal("serve did not shut down")
	}
}

// TestMigrateAndPurgeAgainstPostgres runs the deploy job's commands.
func TestMigrateAndPurgeAgainstPostgres(t *testing.T) {
	t.Parallel()
	dsn := os.Getenv("DM_PG_TEST_URL")
	if dsn == "" {
		t.Skip("DM_PG_TEST_URL not set; runs in ci-go")
	}
	vars := getenv(map[string]string{"DM_DATABASE_URL": dsn})
	var logs bytes.Buffer
	for _, cmd := range []string{"migrate", "migrate", "purge"} {
		if got := run(context.Background(), []string{cmd}, vars, &logs); got != 0 {
			t.Fatalf("%s = %d: %s", cmd, got, logs.String())
		}
	}
	if !strings.Contains(logs.String(), `"message":"purged"`) {
		t.Fatalf("purge did not report: %s", logs.String())
	}
}
