package main

import (
	"os"
	"path/filepath"
	"strings"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

var pinnedTzdata = filepath.Join("..", "..", "packages", "dm_civil_time", "data", "tzdata", "2026e")

// S10: the pipeline's tzdata payload becomes a signed tzdata/2026e target
// that verifies like any other package (§15 D69).
func TestCLIBuildsSignsAndVerifiesTzdata_REQ_DIST_003_REQ_TIME_020(t *testing.T) {
	ks := testsupport.NewKeySet(t)
	keys, private, repo := t.TempDir(), t.TempDir(), t.TempDir()
	ks.WritePublic(t, keys)
	ks.WritePrivate(t, private, "root-1", "root-2", "targets-1", "snapshot-1", "timestamp-1")
	payload := filepath.Join(pinnedTzdata, "tzdata.tzf")
	manifest := filepath.Join(pinnedTzdata, "manifest.json")
	build := func(version, manifestPath string) result {
		return gsctl(t, nil, "build", "-type", "tzdata", "-payload", payload, "-manifest", manifestPath,
			"-repo", repo, "-version", version, "-effective-from", "2026-11-01",
			"-note-ar", "بيانات المناطق الزمنية 2026e", "-note-en", "Time zone data 2026e")
	}

	expect(t, build("2026e", manifest), exitOK, "built: tzdata/2026e from 598 zone(s)")
	for _, role := range []string{"root", "targets", "snapshot", "timestamp"} {
		expect(t, gsctl(t, nil, "sign", "-repo", repo, "-role", role, "-keys", keys, "-key-dir", private), exitOK, "signed: "+role)
	}
	expect(t, gsctl(t, nil, "verify", "-repo", repo, "-root-keys", filepath.Join(keys, "root-keys.json")), exitOK, "1 target(s)")

	t.Run("a version naming another TZDB release is refused", func(t *testing.T) {
		expect(t, build("2026d", manifest), exitFailed, "built from TZDB \"2026e\"")
	})
	t.Run("a version that is not an IANA release name is refused", func(t *testing.T) {
		expect(t, build("2026.10.1", manifest), exitFailed, "<IANA release>")
	})
	t.Run("a manifest that does not vouch for the payload is refused", func(t *testing.T) {
		original, err := os.ReadFile(manifest) //nolint:gosec // the repository's pinned pipeline output
		if err != nil {
			t.Fatal(err)
		}
		forged := filepath.Join(t.TempDir(), "manifest.json")
		sha := "78ba31d78fb7bf870e312a187e8bef849189c3521dbf68d1ee5f5fe4f8e71891"
		forgedBytes := []byte(strings.Replace(string(original), sha, strings.Repeat("0", 64), 1))
		if err := os.WriteFile(forged, forgedBytes, 0o600); err != nil { //nolint:gosec // a file in the test's own temp directory
			t.Fatal(err)
		}
		expect(t, build("2026e.1", forged), exitFailed, "the manifest says")
	})
	t.Run("tzdata needs a payload and a manifest", func(t *testing.T) {
		expect(t, gsctl(t, nil, "build", "-type", "tzdata", "-repo", repo, "-version", "2026e",
			"-effective-from", "2026-11-01", "-note-ar", "x", "-note-en", "x"), exitUsage, "-payload and -manifest")
		expect(t, gsctl(t, nil, "build", "-type", "hijri", "-repo", repo, "-version", "1",
			"-effective-from", "2026-11-01", "-note-ar", "x", "-note-en", "x"), exitUsage, "-type \"hijri\"")
	})
	t.Run("a refused build stages nothing", func(t *testing.T) {
		entries, err := os.ReadDir(filepath.Join(repo, "staged"))
		if err != nil && !os.IsNotExist(err) {
			t.Fatal(err)
		}
		if len(entries) != 0 {
			t.Fatalf("staged after refusals: %v", entries)
		}
	})
}
