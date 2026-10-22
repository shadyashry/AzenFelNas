package profileset

import (
	"crypto/sha256"
	"encoding/hex"
	"errors"
	"fmt"
	"regexp"
	"strings"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// targetVersionPattern is the tuf_metadata.v1 target-name version part.
var targetVersionPattern = regexp.MustCompile(`^[0-9A-Za-z.+-]+$`)

// ErrRelease is returned for release fields the target schema refuses.
var ErrRelease = errors.New("invalid release")

// Release is what the release manager states about a package; nothing in
// it is derived from profile values (REQ-GOV-004: one effectiveFrom).
type Release struct {
	Version       string
	EffectiveFrom string
	Priority      tuf.Priority
	ChangeNote    tuf.ChangeNote
	// RollbackOf names the version this one rolls back (REQ-DIST-002);
	// empty when it is not a rollback.
	RollbackOf string
}

// TargetName is "<packageType>/<version>", the key in targets.json.
func TargetName(version string) string { return PackageType + "/" + version }

// Target returns the target entry of a .dmpkg built from s for r.
func (s Set) Target(r Release, container []byte) (string, tuf.Target, error) {
	if err := r.Validate(); err != nil {
		return "", tuf.Target{}, err
	}
	sum := sha256.Sum256(container)
	custom := tuf.TargetCustom{
		SchemaVersion: PayloadSchemaVersion,
		PayloadFormat: tuf.PayloadJSON,
		Compat:        s.Compat,
		EffectiveFrom: r.EffectiveFrom,
		Priority:      r.Priority,
		ChangeNote:    r.ChangeNote,
	}
	if r.RollbackOf != "" {
		rollbackOf := r.RollbackOf
		custom.RollbackOf = &rollbackOf
	}
	return TargetName(r.Version), tuf.Target{Length: int64(len(container)), SHA256: hex.EncodeToString(sum[:]), Custom: custom}, nil
}

// Validate refuses release fields the target schema would refuse; every
// package type shares it.
func (r Release) Validate() error {
	var msgs []string
	if !targetVersionPattern.MatchString(r.Version) {
		msgs = append(msgs, fmt.Sprintf("version %q must match %s", r.Version, targetVersionPattern))
	}
	if r.RollbackOf != "" && (!targetVersionPattern.MatchString(r.RollbackOf) || r.RollbackOf == r.Version) {
		msgs = append(msgs, fmt.Sprintf("rollback-of %q must be another version", r.RollbackOf))
	}
	if _, err := time.Parse(time.DateOnly, r.EffectiveFrom); err != nil {
		msgs = append(msgs, fmt.Sprintf("effective-from %q is not a YYYY-MM-DD date", r.EffectiveFrom))
	}
	switch r.Priority {
	case tuf.PriorityNormal, tuf.PriorityUrgent:
	default:
		msgs = append(msgs, fmt.Sprintf("priority %q must be normal or urgent", r.Priority))
	}
	if strings.TrimSpace(r.ChangeNote.Ar) == "" || strings.TrimSpace(r.ChangeNote.En) == "" {
		msgs = append(msgs, "change notes in Arabic and English are both required")
	}
	if len(msgs) > 0 {
		return fmt.Errorf("%w: %s", ErrRelease, strings.Join(msgs, "; "))
	}
	return nil
}
