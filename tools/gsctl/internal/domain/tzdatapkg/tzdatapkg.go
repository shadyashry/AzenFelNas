// Package tzdatapkg holds the rules of the `tzdata` package (§9.5, §15 D66,
// D69): the target version names the IANA release, the payload is the
// package:timezone `.tzf` database the data pipeline built, and gsctl
// packages it only when the pipeline's manifest vouches for exactly those
// bytes. Pure.
package tzdatapkg

import (
	"crypto/sha256"
	"encoding/binary"
	"encoding/hex"
	"errors"
	"fmt"
	"regexp"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/pipeline"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

const (
	// PackageType is the target type of a TZDB package.
	PackageType = "tzdata"
	// PayloadFileName names the payload inside the .dmpkg.
	PayloadFileName = "tzdata.tzf"
	// PayloadSchemaVersion is the .tzf layout version (package:timezone 0.11).
	PayloadSchemaVersion = 1
	// Pipeline is the manifest's pipeline name.
	Pipeline = "data-pipelines.tzdata"
	// minEngineSchema: the payload does not depend on the profile schema;
	// the target schema needs a value of at least 1.
	minEngineSchema = 1
	locationHeader  = 32
)

// versionPattern is `<IANA release>` or `<IANA release>.<n>` for a rebuild of
// the same release with other bytes (REQ-DIST-003 forbids reusing a name).
var (
	versionPattern = regexp.MustCompile(`^(\d{4}[a-z]+)(?:\.[1-9]\d*)?$`)
	semverPattern  = regexp.MustCompile(`^\d+\.\d+\.\d+$`)
)

// ErrPayload is returned for bytes that are not a .tzf database.
var ErrPayload = errors.New("tzdata payload is not a .tzf database")

// ErrManifest is returned when the manifest does not vouch for the payload.
var ErrManifest = errors.New("tzdata manifest does not match")

// TzdbVersion returns the IANA release a target version names.
func TzdbVersion(version string) (string, error) {
	m := versionPattern.FindStringSubmatch(version)
	if m == nil {
		return "", fmt.Errorf("%w: version %q must be <IANA release>[.<n>], e.g. 2026e", profileset.ErrRelease, version)
	}
	return m[1], nil
}

// CountZones checks the .tzf framing and every location header's bounds and
// returns the number of zones. Values inside a location are the Dart
// reader's to judge (dm_civil_time ReadTzfDatabase).
func CountZones(payload []byte) (int, error) {
	zones := 0
	for offset := 0; offset < len(payload); {
		if len(payload)-offset < 8 {
			return 0, fmt.Errorf("%w: truncated chunk header at byte %d", ErrPayload, offset)
		}
		length := int(binary.BigEndian.Uint32(payload[offset:]))
		offset += 8
		if length%8 != 0 || length > len(payload)-offset {
			return 0, fmt.Errorf("%w: chunk of %d bytes at byte %d", ErrPayload, length, offset)
		}
		if err := checkLocation(payload[offset : offset+length]); err != nil {
			return 0, fmt.Errorf("%w: zone %d: %w", ErrPayload, zones, err)
		}
		offset += length
		zones++
	}
	if zones == 0 {
		return 0, fmt.Errorf("%w: no zones", ErrPayload)
	}
	return zones, nil
}

func checkLocation(chunk []byte) error {
	if len(chunk) < locationHeader {
		return errors.New("location header truncated")
	}
	word := func(i int) uint64 { return uint64(binary.BigEndian.Uint32(chunk[i*4:])) }
	sections := []struct {
		name     string
		at, size uint64
	}{
		{"name", word(0), word(1)},
		{"abbreviations", word(2), word(3)},
		{"zones", word(4), word(5) * 8},
		{"transitions", word(6), word(7) * 9},
	}
	for _, s := range sections {
		if s.at > uint64(len(chunk)) || s.size > uint64(len(chunk))-s.at {
			return fmt.Errorf("%s section outside its chunk", s.name)
		}
	}
	if word(1) == 0 || word(5) == 0 {
		return errors.New("no name or no zones")
	}
	return nil
}

// CheckBuild returns the zone count when manifest is the tzdata pipeline's
// manifest for release version and lists payload as its .tzf output with the
// same sha256 and zone count.
func CheckBuild(payload []byte, manifest pipeline.Manifest, version string) (int, error) {
	tzdb, err := TzdbVersion(version)
	if err != nil {
		return 0, err
	}
	zones, err := CountZones(payload)
	if err != nil {
		return 0, err
	}
	if manifest.SchemaVersion != 1 || manifest.Pipeline != Pipeline {
		return 0, fmt.Errorf("%w: pipeline %q schema %d, want %q schema 1", ErrManifest, manifest.Pipeline, manifest.SchemaVersion, Pipeline)
	}
	if got := manifest.Parameters["tzdbVersion"]; got != tzdb {
		return 0, fmt.Errorf("%w: built from TZDB %q, the version names %q", ErrManifest, got, tzdb)
	}
	sum := sha256.Sum256(payload)
	for _, out := range manifest.Outputs {
		if out.Path != PayloadFileName {
			continue
		}
		if out.SHA256 != hex.EncodeToString(sum[:]) || out.Records != int64(zones) {
			return 0, fmt.Errorf("%w: %s is sha256 %s with %d zones, the manifest says %s with %d",
				ErrManifest, PayloadFileName, hex.EncodeToString(sum[:]), zones, out.SHA256, out.Records)
		}
		return zones, nil
	}
	return 0, fmt.Errorf("%w: no %s output", ErrManifest, PayloadFileName)
}

// Target returns the target entry of a tzdata .dmpkg for r; minApp is the
// oldest app that reads the payload.
func Target(r profileset.Release, minApp string, container []byte) (string, tuf.Target, error) {
	if _, err := TzdbVersion(r.Version); err != nil {
		return "", tuf.Target{}, err
	}
	if err := r.Validate(); err != nil {
		return "", tuf.Target{}, err
	}
	if !semverPattern.MatchString(minApp) {
		return "", tuf.Target{}, fmt.Errorf("%w: min-app %q is not MAJOR.MINOR.PATCH", profileset.ErrRelease, minApp)
	}
	sum := sha256.Sum256(container)
	custom := tuf.TargetCustom{
		SchemaVersion: PayloadSchemaVersion,
		PayloadFormat: tuf.PayloadBin,
		Compat:        tuf.Compat{MinApp: minApp, MinEngineSchema: minEngineSchema},
		EffectiveFrom: r.EffectiveFrom,
		Priority:      r.Priority,
		ChangeNote:    r.ChangeNote,
	}
	if r.RollbackOf != "" {
		rollbackOf := r.RollbackOf
		custom.RollbackOf = &rollbackOf
	}
	return PackageType + "/" + r.Version, tuf.Target{Length: int64(len(container)), SHA256: hex.EncodeToString(sum[:]), Custom: custom}, nil
}
