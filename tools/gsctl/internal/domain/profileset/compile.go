// Package profileset compiles prayer profiles into the `prayer_profiles`
// package payload (§9.5, §15 D52, D60) and holds the checks gsctl applies
// before it builds or signs one (§15 D61). Profile values are data, never
// read here for meaning (§0.2 rule 1). Pure.
package profileset

import (
	"bytes"
	"cmp"
	"encoding/json"
	"errors"
	"fmt"
	"path"
	"regexp"
	"slices"
	"strconv"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/profile"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// Package identity (§9.5, §15 D60).
const (
	// PackageType is the target type of a compiled profile set.
	PackageType = "prayer_profiles"
	// PayloadFileName names the payload inside the .dmpkg.
	PayloadFileName = "profiles.json"
	// PayloadSchemaVersion is the prayer_profile schema the payload holds.
	PayloadSchemaVersion = 1
)

// Appendix A patterns and the target schema's minApp pattern.
var (
	profileIDPattern = regexp.MustCompile(`^[a-z]{2}\.[a-z0-9_]+\.[a-z0-9_]+$|^engine\.default$`)
	versionPattern   = regexp.MustCompile(`^\d{4}\.\d{1,2}\.\d+$`)
	semverPattern    = regexp.MustCompile(`^(\d+)\.(\d+)\.(\d+)$`)
)

// ErrInvalid is wrapped by every ValidationError.
var ErrInvalid = errors.New("profile set invalid")

// Document is one profile as JSON, with its path relative to the profiles
// directory, slash-separated ("eg/eg.egas.standard.yaml").
type Document struct {
	Path string
	JSON []byte
}

// Problem is one reason a document or the set is refused.
type Problem struct {
	Path    string
	Message string
}

// ValidationError lists every problem found, not only the first.
type ValidationError struct {
	Problems []Problem
}

func (e *ValidationError) Error() string {
	lines := make([]string, 0, len(e.Problems))
	for _, p := range e.Problems {
		lines = append(lines, p.Path+": "+p.Message)
	}
	return fmt.Sprintf("%d problem(s): %s", len(e.Problems), strings.Join(lines, "; "))
}

// Unwrap makes errors.Is(err, ErrInvalid) hold.
func (e *ValidationError) Unwrap() error { return ErrInvalid }

// Set is a compiled, checked profile set.
type Set struct {
	// Profiles in payload order: by profileId, then version.
	Profiles []profile.PrayerProfile
	// Payload is profiles.json: the JCS-canonical array of the documents
	// as authored (§15 D60).
	Payload []byte
	// Compat is the strictest compatibility of the set (REQ-PKG-006).
	Compat tuf.Compat
}

type checked struct {
	doc     Document
	profile profile.PrayerProfile
}

// Compile checks docs for channel and builds the payload. A set with any
// problem is refused whole, with every problem listed.
func Compile(docs []Document, channel Channel) (Set, error) {
	var problems []Problem
	var ok []checked
	for _, doc := range docs {
		p, msgs := checkDocument(doc, channel)
		for _, m := range msgs {
			problems = append(problems, Problem{Path: doc.Path, Message: m})
		}
		if len(msgs) == 0 {
			ok = append(ok, checked{doc: doc, profile: p})
		}
	}
	problems = append(problems, checkSet(docs, ok)...)
	if len(problems) > 0 {
		return Set{}, &ValidationError{Problems: problems}
	}
	slices.SortFunc(ok, func(a, b checked) int {
		return cmp.Or(cmp.Compare(a.profile.ProfileID, b.profile.ProfileID), cmp.Compare(a.profile.Version, b.profile.Version))
	})
	return assemble(ok)
}

func checkSet(docs []Document, ok []checked) []Problem {
	if len(docs) == 0 {
		return []Problem{{Path: ".", Message: "no profiles"}}
	}
	var problems []Problem
	seen := map[string]string{}
	for _, c := range ok {
		key := c.profile.ProfileID + "@" + c.profile.Version
		if first, dup := seen[key]; dup {
			problems = append(problems, Problem{Path: c.doc.Path, Message: key + " is also defined in " + first})
			continue
		}
		seen[key] = c.doc.Path
	}
	return problems
}

func assemble(ok []checked) (Set, error) {
	var array bytes.Buffer
	array.WriteByte('[')
	set := Set{Compat: tuf.Compat{MinApp: "0.0.0", MinEngineSchema: 1}}
	for i, c := range ok {
		if i > 0 {
			array.WriteByte(',')
		}
		array.Write(c.doc.JSON)
		set.Profiles = append(set.Profiles, c.profile)
		if compareSemver(c.profile.Compatibility.MinAppVersion, set.Compat.MinApp) > 0 {
			set.Compat.MinApp = c.profile.Compatibility.MinAppVersion
		}
		set.Compat.MinEngineSchema = max(set.Compat.MinEngineSchema, c.profile.Compatibility.MinEngineSchema)
	}
	array.WriteByte(']')
	payload, err := jcs.Canonicalize(array.Bytes())
	if err != nil {
		return Set{}, fmt.Errorf("canonicalise payload: %w", err)
	}
	set.Payload = payload
	return set, nil
}

// checkDocument returns the decoded profile and the problems of one
// document: its shape (strict decode, closed enums), identity and path,
// the Appendix A governance gate (REQ-GOV-001), the Appendix E channel
// gate and the compatibility fields a target needs.
func checkDocument(doc Document, channel Channel) (profile.PrayerProfile, []string) {
	var p profile.PrayerProfile
	if err := json.Unmarshal(doc.JSON, &p); err != nil {
		return p, []string{"not a prayer_profile.v1 document: " + err.Error()}
	}
	var msgs []string
	if p.SchemaVersion != PayloadSchemaVersion {
		msgs = append(msgs, fmt.Sprintf("schemaVersion %d, want %d", p.SchemaVersion, PayloadSchemaVersion))
	}
	if !profileIDPattern.MatchString(p.ProfileID) {
		msgs = append(msgs, fmt.Sprintf("profileId %q does not match Appendix A", p.ProfileID))
	} else if want := expectedPath(p.ProfileID); doc.Path != want {
		msgs = append(msgs, fmt.Sprintf("profile %s belongs at %s", p.ProfileID, want))
	}
	if !versionPattern.MatchString(p.Version) {
		msgs = append(msgs, fmt.Sprintf("version %q does not match Appendix A", p.Version))
	}
	msgs = append(msgs, governance(p, channel)...)
	if p.Compatibility.MinEngineSchema < 1 {
		msgs = append(msgs, "compatibility.minEngineSchema must be at least 1")
	}
	if !semverPattern.MatchString(p.Compatibility.MinAppVersion) {
		msgs = append(msgs, fmt.Sprintf("compatibility.minAppVersion %q is not MAJOR.MINOR.PATCH", p.Compatibility.MinAppVersion))
	}
	return p, msgs
}

// governance applies the signing gates: APPROVED needs both approvals and a
// holdout report (Appendix A, REQ-GOV-001), beta/production refuse
// DRAFT_UNVERIFIED and CANDIDATE (Appendix E), and nearest rounding of an
// entry needs a rounding approval (Appendix A).
func governance(p profile.PrayerProfile, channel Channel) []string {
	var msgs []string
	switch p.Status {
	case profile.StatusApproved:
		if p.Approvals.Religious == nil || p.Approvals.Accuracy == nil || p.Evidence.HoldoutReport == nil {
			msgs = append(msgs, "APPROVED needs approvals.religious, approvals.accuracy and evidence.holdoutReport")
		}
	case profile.StatusDraftUnverified, profile.StatusCandidate:
		if channel.releasesToUsers() {
			msgs = append(msgs, fmt.Sprintf("%s loads on dev and lab only, not %s", p.Status, channel))
		}
	case profile.StatusRetired:
	}
	if nearestOnEntry(p) && !religiousScopeHas(p, "rounding") {
		msgs = append(msgs, `nearest rounding of an entry event needs "rounding" in approvals.religious.scope`)
	}
	return msgs
}

// nearestOnEntry reports nearest rounding on any event but Sunrise (the
// default included): it can show an entry before it has entered, so it
// needs a religious approval of rounding (§6.4, Appendix A, ADR-005). The
// app's ParsePrayerProfile applies the same rule (§15 D99).
func nearestOnEntry(p profile.PrayerProfile) bool {
	for event, mode := range p.Rounding {
		if mode == profile.RoundingNearest && event != "sunrise" {
			return true
		}
	}
	return false
}

func religiousScopeHas(p profile.PrayerProfile, item string) bool {
	return p.Approvals.Religious != nil && slices.Contains(p.Approvals.Religious.Scope, item)
}

// expectedPath is profiles/<iso2|engine>/<profileId>.yaml (profiles/README.md).
func expectedPath(profileID string) string {
	dir := "engine"
	if profileID != "engine.default" {
		dir = profileID[:2]
	}
	return path.Join(dir, profileID+".yaml")
}

// compareSemver orders two MAJOR.MINOR.PATCH versions numerically; a
// malformed one sorts first (checkDocument has already reported it).
func compareSemver(a, b string) int {
	pa, pb := semverPattern.FindStringSubmatch(a), semverPattern.FindStringSubmatch(b)
	if pa == nil || pb == nil {
		return cmp.Compare(len(pa), len(pb))
	}
	for i := 1; i <= 3; i++ {
		x, errX := strconv.Atoi(pa[i])
		y, errY := strconv.Atoi(pb[i])
		if errX != nil || errY != nil {
			return cmp.Compare(pa[i], pb[i])
		}
		if c := cmp.Compare(x, y); c != 0 {
			return c
		}
	}
	return 0
}
