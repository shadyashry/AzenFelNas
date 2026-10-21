package main

import (
	"bytes"
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/sysclock"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

type result struct {
	code           int
	stdout, stderr string
}

func gsctl(t *testing.T, vars map[string]string, args ...string) result {
	t.Helper()
	var stdout, stderr bytes.Buffer
	lookup := func(k string) (string, bool) { v, ok := vars[k]; return v, ok }
	code := run(t.Context(), args, env{lookup: lookup, clock: sysclock.Clock{}, stdout: &stdout, stderr: &stderr})
	return result{code: code, stdout: stdout.String(), stderr: stderr.String()}
}

func expect(t *testing.T, r result, code int, contains string) {
	t.Helper()
	if r.code != code || !strings.Contains(r.stdout+r.stderr, contains) {
		t.Fatalf("exit %d (want %d), output does not contain %q:\nstdout: %s\nstderr: %s", r.code, code, contains, r.stdout, r.stderr)
	}
}

func flip(t *testing.T, path string, at int) []byte {
	t.Helper()
	original, err := os.ReadFile(path) //nolint:gosec // a file of the test's own temp repository
	if err != nil {
		t.Fatal(err)
	}
	changed := bytes.Clone(original)
	changed[at%len(changed)] ^= 0x01
	if err := os.WriteFile(path, changed, 0o600); err != nil { //nolint:gosec // a file of the test's own temp repository
		t.Fatal(err)
	}
	return original
}

// The S09 done-test in Go: validate, build, sign every role (keys from a
// directory and from CI-style variables), verify; a tampered byte fails;
// a sequence regression is refused when signing and when verifying.
func TestCLISignVerifyTamperAndRegression_REQ_DIST_001_REQ_DIST_002_REQ_DIST_004_REQ_PKG_005(t *testing.T) {
	ks := testsupport.NewKeySet(t)
	keys, private, repo := t.TempDir(), t.TempDir(), t.TempDir()
	ks.WritePublic(t, keys)
	ks.WritePrivate(t, private, "root-1", "root-2", "root-3")
	vars := map[string]string{
		"DM_DEV_TARGETS_KEY_1":   ks.Base64PEM(t, "targets-1"),
		"DM_DEV_SNAPSHOT_KEY_1":  ks.Base64PEM(t, "snapshot-1"),
		"DM_DEV_TIMESTAMP_KEY_1": ks.Base64PEM(t, "timestamp-1"),
	}
	profiles := filepath.Join("..", "..", "profiles")
	rootKeys := filepath.Join(keys, "root-keys.json")

	expect(t, gsctl(t, nil, "validate", "-profiles", profiles, "-channel", "dev"), exitOK, "valid: 4 profile(s) for dev")
	expect(t, gsctl(t, nil, "validate", "-profiles", profiles, "-channel", "beta"), exitFailed, "PROFILE_INVALID")
	expect(t, gsctl(t, nil, "build", "-profiles", profiles, "-channel", "dev", "-repo", repo, "-version", "2026.10.1",
		"-effective-from", "2026-11-01", "-note-ar", "ملفات أولية", "-note-en", "Seed profiles"), exitOK, "built: prayer_profiles/2026.10.1")
	expect(t, gsctl(t, vars, "sign", "-repo", repo, "-role", "root", "-keys", keys, "-key-dir", private), exitOK, "3 signature(s)")
	for _, role := range []string{"targets", "snapshot", "timestamp"} {
		expect(t, gsctl(t, vars, "sign", "-repo", repo, "-role", role, "-keys", keys), exitOK, "signed: "+role+" sequence 1")
	}
	expect(t, gsctl(t, nil, "verify", "-repo", repo, "-root-keys", rootKeys), exitOK, "verified: root version 1, timestamp 1, snapshot 1, targets 1; 1 target(s)")

	t.Run("a tampered metadata byte fails", func(t *testing.T) {
		path := filepath.Join(repo, "metadata", "targets.json")
		original := flip(t, path, 200)
		expect(t, gsctl(t, nil, "verify", "-repo", repo, "-root-keys", rootKeys), exitFailed, "PKG_SIG_INVALID")
		if err := os.WriteFile(path, original, 0o600); err != nil {
			t.Fatal(err)
		}
	})
	t.Run("a tampered package byte fails", func(t *testing.T) {
		matches, err := filepath.Glob(filepath.Join(repo, "packages", "prayer_profiles", "2026.10.1", "*.dmpkg"))
		if err != nil || len(matches) != 1 {
			t.Fatalf("packages %v, %v", matches, err)
		}
		original := flip(t, matches[0], 40)
		expect(t, gsctl(t, nil, "verify", "-repo", repo, "-root-keys", rootKeys), exitFailed, "PKG_HASH_MISMATCH")
		if err := os.WriteFile(matches[0], original, 0o600); err != nil {
			t.Fatal(err)
		}
	})
	t.Run("a sequence regression is refused", func(t *testing.T) {
		expect(t, gsctl(t, vars, "sign", "-repo", repo, "-role", "targets", "-keys", keys, "-sequence", "1"), exitFailed, "PKG_SEQUENCE_REGRESSION")
		expect(t, gsctl(t, nil, "verify", "-repo", repo, "-root-keys", rootKeys, "-after-targets", "1"), exitFailed, "PKG_SEQUENCE_REGRESSION")
	})
	t.Run("the untouched repository still verifies", func(t *testing.T) {
		expect(t, gsctl(t, nil, "verify", "-repo", repo, "-root-keys", rootKeys), exitOK, "verified")
	})
}

// What gsctl signed with the dev keys still verifies against the committed
// trust anchor; dm_packages verifies the same files in Dart (§13 S09).
func TestCommittedRoundTripVectorVerifies_REQ_DIST_001_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	expect(t, gsctl(t, nil, "verify", "-repo", filepath.Join("testdata", "roundtrip", "dev"),
		"-root-keys", filepath.Join("keys", "dev", "root-keys.json")), exitOK, "verified: root version 1, timestamp 1, snapshot 1, targets 1; 1 target(s)")
}

// The §9.2 PR gate end to end: the head is the committed seeds, the base
// a copy with one angle moved (the value only has to differ).
func TestCLICheckChangeRefusesAnglesWithCoordinateData(t *testing.T) {
	t.Parallel()
	profiles := filepath.Join("..", "..", "profiles")
	base := t.TempDir()
	for _, rel := range []string{"ae/ae.awqaf.standard.yaml", "eg/eg.egas.standard.yaml", "engine/engine.default.yaml", "sa/sa.ummalqura.standard.yaml"} {
		data, err := os.ReadFile(filepath.Join(profiles, filepath.FromSlash(rel))) //nolint:gosec // the repository's own seed profiles
		if err != nil {
			t.Fatal(err)
		}
		if rel == "eg/eg.egas.standard.yaml" {
			moved := strings.Replace(string(data), "degrees: 19.5", "degrees: 20.5", 1)
			if moved == string(data) {
				t.Fatal("fixture angle not found in the EG seed")
			}
			data = []byte(moved)
		}
		if err := os.MkdirAll(filepath.Join(base, filepath.Dir(filepath.FromSlash(rel))), 0o750); err != nil {
			t.Fatal(err)
		}
		if err := os.WriteFile(filepath.Join(base, filepath.FromSlash(rel)), data, 0o600); err != nil { //nolint:gosec // the test's own temp directory
			t.Fatal(err)
		}
	}
	changes := func(paths ...string) string {
		f := filepath.Join(t.TempDir(), "changed.txt")
		if err := os.WriteFile(f, []byte(strings.Join(paths, "\n")+"\n"), 0o600); err != nil { //nolint:gosec // the test's own temp directory
			t.Fatal(err)
		}
		return f
	}

	expect(t, gsctl(t, nil, "check-change", "-base-profiles", base, "-profiles", profiles,
		"-changed", changes("profiles/eg/eg.egas.standard.yaml")), exitOK, "ok: no angle change")
	expect(t, gsctl(t, nil, "check-change", "-base-profiles", base, "-profiles", profiles,
		"-changed", changes("profiles/eg/eg.egas.standard.yaml", "lab/benchmarks/cities.v1.json")), exitFailed, "angles change in eg.egas.standard")
	expect(t, gsctl(t, nil, "check-change", "-base-profiles", profiles, "-profiles", profiles,
		"-changed", changes("lab/benchmarks/cities.v1.json")), exitOK, "ok: no angle change")
}

func TestCLIUsageErrorsExitWithTwo(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name string
		args []string
	}{
		{name: "no arguments", args: nil},
		{name: "unknown command", args: []string{"publish"}},
		{name: "missing required flag", args: []string{"validate"}},
		{name: "unknown channel", args: []string{"validate", "-channel", "staging"}},
		{name: "unknown role", args: []string{"sign", "-repo", "r", "-role", "mirror"}},
		{name: "stray argument", args: []string{"verify", "-repo", "r", "extra"}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			r := gsctl(t, nil, tc.args...)
			if r.code != exitUsage || r.stderr == "" {
				t.Fatalf("run(%v) = %d, stderr %q; want %d with a message", tc.args, r.code, r.stderr, exitUsage)
			}
		})
	}
}

func TestCLISignsNothingWithoutPrivateKeys(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	keys, repo := t.TempDir(), t.TempDir()
	ks.WritePublic(t, keys)
	expect(t, gsctl(t, nil, "sign", "-repo", repo, "-role", "root", "-keys", keys), exitFailed, "0 of 2 required key(s)")
	if _, err := os.Stat(filepath.Join(repo, "metadata", "root.json")); !os.IsNotExist(err) {
		t.Fatalf("root.json written without keys: %v", err)
	}
}
