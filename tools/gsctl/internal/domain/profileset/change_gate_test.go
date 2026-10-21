package profileset_test

import (
	"encoding/json"
	"strings"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
)

// shifted returns the engine default with one angle moved by one unit. The
// value only has to differ: the gate detects change, it never judges a
// value (§0.2 rule 1).
func shifted(t *testing.T, at func(map[string]any) map[string]any, key string) profileset.Document {
	t.Helper()
	v := base(t)
	rule := at(v)
	old, ok := rule[key].(float64)
	if !ok {
		t.Fatalf("no numeric %s", key)
	}
	rule[key] = old + 1
	return doc(t, "engine/engine.default.yaml", v)
}

func fajr(v map[string]any) map[string]any {
	return v["rules"].(map[string]any)["fajr"].(map[string]any) //nolint:forcetypeassert // fixed fixture shape
}

func withReferencePoint(t *testing.T, id, cc string, lat float64) profileset.Document {
	t.Helper()
	d := country(t, id, cc, "1.0.0")
	v := map[string]any{}
	if err := json.Unmarshal(d.JSON, &v); err != nil {
		t.Fatal(err)
	}
	v["referencePoints"] = []any{map[string]any{"area": strings.ToUpper(cc), "lat": lat, "lon": 31.0}}
	return doc(t, d.Path, v)
}

func TestNoAngleChangeTogetherWithTzOrCoordinateData(t *testing.T) {
	t.Parallel()
	engine := doc(t, "engine/engine.default.yaml", base(t))
	moved := shifted(t, fajr, "degrees")
	eg := withReferencePoint(t, "eg.test.standard", "eg", 30.0)
	egMoved := withReferencePoint(t, "eg.test.standard", "eg", 30.5)
	tests := []struct {
		name       string
		base, head []profileset.Document
		changed    []string
		refused    bool
	}{
		{
			name: "angle change alone", base: []profileset.Document{engine}, head: []profileset.Document{moved},
			changed: []string{"profiles/engine/engine.default.yaml"},
		},
		{
			name: "tz data alone", base: []profileset.Document{engine}, head: []profileset.Document{engine},
			changed: []string{"data-pipelines/src/dm_pipelines/tzdata.py"},
		},
		{
			name: "angle change with a tz pipeline", base: []profileset.Document{engine}, head: []profileset.Document{moved},
			changed: []string{"profiles/engine/engine.default.yaml", "data-pipelines/src/dm_pipelines/tzdata.py"}, refused: true,
		},
		{
			name: "angle change with benchmark coordinates", base: []profileset.Document{engine}, head: []profileset.Document{moved},
			changed: []string{"lab/benchmarks/cities.v1.json"}, refused: true,
		},
		{
			name: "angle change with a polygon layout", base: []profileset.Document{engine}, head: []profileset.Document{moved},
			changed: []string{"schemas/tz_polygons.v1.ksy"}, refused: true,
		},
		{
			name: "angle change with another profile's reference point", base: []profileset.Document{engine, eg},
			head: []profileset.Document{moved, egMoved}, refused: true,
		},
		{
			name: "a new profile brings no angle change", base: []profileset.Document{engine},
			head: []profileset.Document{engine, eg}, changed: []string{"lab/benchmarks/cities.v1.json"},
		},
		{
			name: "a lookalike path is not data", base: []profileset.Document{engine}, head: []profileset.Document{moved},
			changed: []string{"data-pipelines-notes.md", "schemas/tz_polygons.v1.ksy.md"},
		},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			problems := profileset.CheckChange(tc.base, tc.head, tc.changed)
			if refused := len(problems) > 0; refused != tc.refused {
				t.Fatalf("refused = %v (%v), want %v", refused, problems, tc.refused)
			}
		})
	}
}

func TestReformattedAnglesAreNoChange(t *testing.T) {
	t.Parallel()
	engine := doc(t, "engine/engine.default.yaml", base(t))
	reformatted := profileset.Document{Path: engine.Path, JSON: []byte(strings.Replace(string(engine.JSON), `"degrees":18`, `"degrees":18.0`, 1))}
	if string(reformatted.JSON) == string(engine.JSON) {
		t.Fatal("fixture did not change")
	}
	if p := profileset.CheckChange([]profileset.Document{engine}, []profileset.Document{reformatted}, []string{"data-pipelines/x"}); p != nil {
		t.Fatalf("18 and 18.0 counted as an angle change: %v", p)
	}
}

func TestRamadanAndHorizonAnglesCount(t *testing.T) {
	t.Parallel()
	engine := doc(t, "engine/engine.default.yaml", base(t))
	withRamadan := func(isha map[string]any) profileset.Document {
		v := base(t)
		v["adjustments"].(map[string]any)["ramadan"] = map[string]any{"isha": isha} //nolint:forcetypeassert // fixed fixture shape
		return doc(t, "engine/engine.default.yaml", v)
	}
	before := withRamadan(map[string]any{"type": "solarAltitude", "degrees": 18.0})
	after := withRamadan(map[string]any{"type": "solarAltitude", "degrees": 19.0})
	if p := profileset.CheckChange([]profileset.Document{before}, []profileset.Document{after}, []string{"packages/dm_civil_time/lib/x.dart"}); p == nil {
		t.Fatal("a Ramadan rule angle change was not seen")
	}
	horizon := base(t)
	horizon["rules"].(map[string]any)["sunrise"] = map[string]any{"type": "horizon", "refractionArcmin": 35.0} //nolint:forcetypeassert // fixed fixture shape
	if p := profileset.CheckChange([]profileset.Document{engine}, []profileset.Document{doc(t, engine.Path, horizon)}, []string{"apps/mobile/assets/packages/tzdata.dmpkg"}); p == nil {
		t.Fatal("a horizon refraction change was not seen")
	}
}
