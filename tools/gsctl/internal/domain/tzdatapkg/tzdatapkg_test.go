package tzdatapkg_test

import (
	"encoding/binary"
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/tzdatapkg"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/pipeline"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

var pinned = filepath.Join("..", "..", "..", "..", "..", "packages", "dm_civil_time", "data", "tzdata", "2026e")

func read(t *testing.T, name string) []byte {
	t.Helper()
	b, err := os.ReadFile(filepath.Join(pinned, name)) //nolint:gosec // the repository's pinned pipeline output
	if err != nil {
		t.Fatal(err)
	}
	return b
}

func manifest(t *testing.T) pipeline.Manifest {
	t.Helper()
	var m pipeline.Manifest
	if err := json.Unmarshal(read(t, "manifest.json"), &m); err != nil {
		t.Fatal(err)
	}
	return m
}

func TestTzdbVersionIsTheIANAReleaseOfTheTargetVersion(t *testing.T) {
	t.Parallel()
	for version, want := range map[string]string{"2026e": "2026e", "2026e.1": "2026e", "2027ab.12": "2027ab"} {
		if got, err := tzdatapkg.TzdbVersion(version); err != nil || got != want {
			t.Errorf("%s: %q, %v", version, got, err)
		}
	}
	for _, version := range []string{"2026", "2026E", "2026e.0", "2026e-1", "2026.10.1", ""} {
		if _, err := tzdatapkg.TzdbVersion(version); !errors.Is(err, profileset.ErrRelease) {
			t.Errorf("%q accepted", version)
		}
	}
}

func TestCountZonesReadsThePinnedPayload_REQ_TIME_020(t *testing.T) {
	t.Parallel()
	if zones, err := tzdatapkg.CountZones(read(t, "tzdata.tzf")); err != nil || zones != 598 {
		t.Fatalf("%d zones, %v", zones, err)
	}
}

func TestCountZonesRefusesBrokenFraming(t *testing.T) {
	t.Parallel()
	payload := read(t, "tzdata.tzf")
	odd := append([]byte(nil), payload...)
	binary.BigEndian.PutUint32(odd, binary.BigEndian.Uint32(odd)+1)
	header := append([]byte(nil), payload...)
	binary.BigEndian.PutUint32(header[8+16:], 1<<30) // zones section far outside the chunk
	for name, b := range map[string][]byte{
		"empty": nil, "truncated": payload[:5], "odd length": odd, "section outside": header,
	} {
		if _, err := tzdatapkg.CountZones(b); !errors.Is(err, tzdatapkg.ErrPayload) {
			t.Errorf("%s: %v", name, err)
		}
	}
}

func TestCheckBuildNeedsTheManifestToVouchForThePayload_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	payload, m := read(t, "tzdata.tzf"), manifest(t)
	if zones, err := tzdatapkg.CheckBuild(payload, m, "2026e"); err != nil || zones != 598 {
		t.Fatalf("pinned build: %d, %v", zones, err)
	}
	withoutFirstZone := payload[8+binary.BigEndian.Uint32(payload):]
	if _, err := tzdatapkg.CheckBuild(withoutFirstZone, m, "2026e"); !errors.Is(err, tzdatapkg.ErrManifest) {
		t.Errorf("other bytes: %v", err)
	}
	if _, err := tzdatapkg.CheckBuild(payload, m, "2026d"); !errors.Is(err, tzdatapkg.ErrManifest) {
		t.Errorf("other release: %v", err)
	}
	other := m
	other.Pipeline = "lab.reference"
	if _, err := tzdatapkg.CheckBuild(payload, other, "2026e"); !errors.Is(err, tzdatapkg.ErrManifest) {
		t.Errorf("other pipeline: %v", err)
	}
}

func TestTargetIsABinaryPayloadWithTheReleaseInputs_REQ_GOV_004(t *testing.T) {
	t.Parallel()
	release := profileset.Release{
		Version: "2026e", EffectiveFrom: "2026-11-01", Priority: tuf.PriorityUrgent,
		ChangeNote: tuf.ChangeNote{Ar: "تحديث", En: "Update"},
	}
	name, target, err := tzdatapkg.Target(release, "1.0.0", []byte{1, 2, 3})
	if err != nil {
		t.Fatal(err)
	}
	c := target.Custom
	if name != "tzdata/2026e" || c.PayloadFormat != tuf.PayloadBin || c.SchemaVersion != 1 ||
		c.Compat.MinApp != "1.0.0" || c.Compat.MinEngineSchema != 1 || c.Priority != tuf.PriorityUrgent || target.Length != 3 {
		t.Fatalf("%s %+v", name, target)
	}
	if _, _, err := tzdatapkg.Target(release, "1.0", nil); !errors.Is(err, profileset.ErrRelease) {
		t.Errorf("min-app 1.0: %v", err)
	}
}
