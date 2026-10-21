package profileset

import (
	"bytes"
	"encoding/json"
	"fmt"
	"maps"
	"slices"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
)

// TzCoordinateDataPaths are the repository paths holding time-zone or
// coordinate data (§9.5, Appendix H): the pipelines that build tzdata,
// tz_polygons, country_polygons and the gazetteer, their layouts, the pinned
// TZDB, the bundled seed packages and the benchmark city coordinates. A
// path ending in "/" covers its subtree (§15 D64).
var TzCoordinateDataPaths = []string{
	"data-pipelines/",
	"packages/dm_civil_time/",
	"apps/mobile/assets/packages/",
	"lab/benchmarks/",
	"schemas/tz_polygons.v1.ksy",
	"schemas/country_polygons.v1.ksy",
	"schemas/gazetteer_package.v1.schema.json",
}

// angleKeys are the members of a rule that are angles: the solarAltitude
// depression and the horizon refraction and semidiameter (§6.5, ADR-003).
var angleKeys = []string{"degrees", "refractionArcmin", "semidiameterArcmin"}

// CheckChange applies the §9.2 prohibited practice "no angle change in a
// PR that also touches tz/coordinate data". base and head are the profile
// documents before and after the PR; changedPaths are the repository paths
// it changes. A profile present on both sides changes an angle when any
// angle of its rules or Ramadan rules differs; it touches coordinate data
// when its referencePoints differ. Added and removed profiles change no
// existing angle. Returns nil when the PR may proceed.
func CheckChange(base, head []Document, changedPaths []string) []Problem {
	before, after := byProfileID(base), byProfileID(head)
	var angleChanges, coordinateChanges []string
	for _, id := range slices.Sorted(maps.Keys(after)) {
		old, ok := before[id]
		if !ok {
			continue
		}
		if old.angles != after[id].angles {
			angleChanges = append(angleChanges, id)
		}
		if old.referencePoints != after[id].referencePoints {
			coordinateChanges = append(coordinateChanges, id+" referencePoints")
		}
	}
	for _, p := range changedPaths {
		if isTzCoordinateData(p) {
			coordinateChanges = append(coordinateChanges, p)
		}
	}
	if len(angleChanges) == 0 || len(coordinateChanges) == 0 {
		return nil
	}
	return []Problem{{
		Path:    ".",
		Message: fmt.Sprintf("angles change in %s while tz/coordinate data changes in %s; split them into separate PRs (§9.2)", strings.Join(angleChanges, ", "), strings.Join(coordinateChanges, ", ")),
	}}
}

type gateView struct {
	angles          string
	referencePoints string
}

// byProfileID reduces each document to its canonical angles and reference
// points. A document that cannot be read keeps the raw text, so any edit to
// it counts as a change on both counts; Compile reports why it is invalid.
func byProfileID(docs []Document) map[string]gateView {
	out := map[string]gateView{}
	for _, d := range docs {
		var v struct {
			ProfileID       string                     `json:"profileId"`
			Rules           map[string]json.RawMessage `json:"rules"`
			ReferencePoints json.RawMessage            `json:"referencePoints"`
			Adjustments     struct {
				Ramadan map[string]json.RawMessage `json:"ramadan"`
			} `json:"adjustments"`
		}
		if err := json.Unmarshal(d.JSON, &v); err != nil || v.ProfileID == "" {
			out[d.Path] = gateView{angles: string(d.JSON), referencePoints: string(d.JSON)}
			continue
		}
		out[v.ProfileID] = gateView{
			angles:          anglesOf("rules", v.Rules) + anglesOf("adjustments.ramadan", v.Adjustments.Ramadan),
			referencePoints: canonical(v.ReferencePoints),
		}
	}
	return out
}

// anglesOf lists "<prefix>.<event>.<key>=<canonical value>" for every angle
// member of the rules, sorted, so that formatting never counts as a change.
func anglesOf(prefix string, rules map[string]json.RawMessage) string {
	var lines []string
	for _, event := range slices.Sorted(maps.Keys(rules)) {
		var members map[string]json.RawMessage
		if err := json.Unmarshal(rules[event], &members); err != nil {
			continue // null (no Imsak) or not an object: no angle
		}
		for _, key := range angleKeys {
			if raw, ok := members[key]; ok {
				lines = append(lines, prefix+"."+event+"."+key+"="+canonical(raw))
			}
		}
	}
	return strings.Join(lines, "\n") + "\n"
}

func canonical(raw json.RawMessage) string {
	if len(bytes.TrimSpace(raw)) == 0 {
		return ""
	}
	c, err := jcs.Canonicalize(raw)
	if err != nil {
		return string(raw)
	}
	return string(c)
}

func isTzCoordinateData(path string) bool {
	for _, p := range TzCoordinateDataPaths {
		if path == p || (strings.HasSuffix(p, "/") && strings.HasPrefix(path, p)) {
			return true
		}
	}
	return false
}
