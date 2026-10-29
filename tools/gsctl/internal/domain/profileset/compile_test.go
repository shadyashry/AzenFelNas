package profileset_test

import (
	"encoding/json"
	"errors"
	"os"
	"strings"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// base is the Dart-compiled engine.default seed (§15 D51), a valid
// DRAFT_UNVERIFIED prayer_profile.v1 document.
func base(t *testing.T) map[string]any {
	t.Helper()
	data, err := os.ReadFile("../../../../../packages/geo_salah_core/bench/profiles/engine.default.json")
	if err != nil {
		t.Fatal(err)
	}
	var doc map[string]any
	if err := json.Unmarshal(data, &doc); err != nil {
		t.Fatal(err)
	}
	return doc
}

func doc(t *testing.T, path string, v map[string]any) profileset.Document {
	t.Helper()
	data, err := json.Marshal(v)
	if err != nil {
		t.Fatal(err)
	}
	return profileset.Document{Path: path, JSON: data}
}

// country derives a country profile from the engine default; only identity
// and scope change, no rule value is written here (§0.2 rule 1).
func country(t *testing.T, id, cc, minApp string) profileset.Document {
	t.Helper()
	v := base(t)
	v["profileId"] = id
	v["scope"] = map[string]any{"countries": []any{strings.ToUpper(cc)}, "adminAreas": []any{}, "polygonsRef": nil}
	v["authority"] = map[string]any{"name": "test", "type": "GOVERNMENT"}
	v["compatibility"] = map[string]any{"minEngineSchema": 1, "minAppVersion": minApp}
	return doc(t, cc+"/"+id+".yaml", v)
}

func approved(t *testing.T, withApprovals bool) profileset.Document {
	t.Helper()
	v := base(t)
	v["status"] = "APPROVED"
	if withApprovals {
		v["approvals"] = map[string]any{
			"religious": map[string]any{"reviewer": "r", "qualification": "q", "date": "2026-10-01", "scope": []any{"rules"}},
			"accuracy":  map[string]any{"reviewer": "a", "date": "2026-10-01"},
		}
		ev := v["evidence"].(map[string]any) //nolint:forcetypeassert // test fixture shape is fixed
		ev["holdoutReport"] = "holdout-2026-10"
	}
	return doc(t, "engine/engine.default.yaml", v)
}

func TestCompileBuildsACanonicalSortedPayload(t *testing.T) {
	t.Parallel()
	docs := []profileset.Document{
		country(t, "sa.test.standard", "sa", "1.2.0"),
		doc(t, "engine/engine.default.yaml", base(t)),
		country(t, "eg.test.standard", "eg", "1.10.0"),
	}

	set, err := profileset.Compile(docs, profileset.ChannelDev)
	if err != nil {
		t.Fatal(err)
	}

	canonical, err := jcs.Canonicalize(set.Payload)
	if err != nil || string(canonical) != string(set.Payload) {
		t.Fatalf("payload is not canonical: %v", err)
	}
	var ids []string
	for _, p := range set.Profiles {
		ids = append(ids, p.ProfileID)
	}
	if strings.Join(ids, ",") != "eg.test.standard,engine.default,sa.test.standard" {
		t.Fatalf("order %v", ids)
	}
	if set.Compat != (tuf.Compat{MinApp: "1.10.0", MinEngineSchema: 1}) {
		t.Fatalf("compat %+v, want the strictest (numeric) minApp", set.Compat)
	}
}

func TestReleaseChannelsRefuseUnreviewedProfiles_AppendixE(t *testing.T) {
	t.Parallel()
	docs := []profileset.Document{doc(t, "engine/engine.default.yaml", base(t))}
	for _, ch := range []profileset.Channel{profileset.ChannelDev, profileset.ChannelLab} {
		if _, err := profileset.Compile(docs, ch); err != nil {
			t.Errorf("%s: %v", ch, err)
		}
	}
	for _, ch := range []profileset.Channel{profileset.ChannelBeta, profileset.ChannelProduction} {
		if _, err := profileset.Compile(docs, ch); !errors.Is(err, profileset.ErrInvalid) {
			t.Errorf("%s: err = %v, want ErrInvalid", ch, err)
		}
	}
}

func TestApprovedProfileNeedsBothApprovalsAndAHoldoutReport_REQ_GOV_001(t *testing.T) {
	t.Parallel()
	if _, err := profileset.Compile([]profileset.Document{approved(t, false)}, profileset.ChannelProduction); !errors.Is(err, profileset.ErrInvalid) {
		t.Fatalf("APPROVED without approvals: err = %v, want ErrInvalid", err)
	}
	if _, err := profileset.Compile([]profileset.Document{approved(t, true)}, profileset.ChannelProduction); err != nil {
		t.Fatalf("APPROVED with approvals and holdout: %v", err)
	}
}

func TestNearestRoundingOfAnEntryNeedsARoundingApproval_AppendixA(t *testing.T) {
	t.Parallel()
	nearest := func(scope []any) profileset.Document {
		v := base(t)
		v["rounding"] = map[string]any{"default": "ceil", "sunrise": "nearest", "maghrib": "nearest"}
		if scope != nil {
			v["approvals"] = map[string]any{
				"religious": map[string]any{"reviewer": "r", "qualification": "q", "date": "2026-10-01", "scope": scope},
				"accuracy":  nil,
			}
		}
		return doc(t, "engine/engine.default.yaml", v)
	}
	if _, err := profileset.Compile([]profileset.Document{nearest(nil)}, profileset.ChannelDev); !errors.Is(err, profileset.ErrInvalid) {
		t.Fatalf("nearest Maghrib without approval: err = %v, want ErrInvalid", err)
	}
	if _, err := profileset.Compile([]profileset.Document{nearest([]any{"rules"})}, profileset.ChannelDev); !errors.Is(err, profileset.ErrInvalid) {
		t.Fatalf("nearest Maghrib approved for rules only: err = %v, want ErrInvalid", err)
	}
	if _, err := profileset.Compile([]profileset.Document{nearest([]any{"rules", "rounding"})}, profileset.ChannelDev); err != nil {
		t.Fatalf("nearest Maghrib with a rounding approval: %v", err)
	}
}

func TestCompileListsEveryProblem(t *testing.T) {
	t.Parallel()
	unknownKey := base(t)
	unknownKey["comment"] = "not in Appendix A"
	badVersion := base(t)
	badVersion["version"] = "1.0"
	dup := country(t, "eg.test.standard", "eg", "1.0.0")
	docs := []profileset.Document{
		doc(t, "engine/engine.default.yaml", unknownKey),
		doc(t, "eg/engine.default.yaml", badVersion),
		dup, dup,
		{Path: "xx/broken.yaml", JSON: []byte(`{`)},
	}

	_, err := profileset.Compile(docs, profileset.ChannelDev)

	var invalid *profileset.ValidationError
	if !errors.As(err, &invalid) {
		t.Fatalf("err = %v, want a ValidationError", err)
	}
	want := []string{"not a prayer_profile.v1", "belongs at engine/engine.default.yaml", "version \"1.0\"", "not a prayer_profile.v1", "also defined in"}
	if len(invalid.Problems) != len(want) {
		t.Fatalf("problems %+v", invalid.Problems)
	}
	for i, w := range want {
		if !strings.Contains(invalid.Problems[i].Message, w) {
			t.Errorf("problem %d = %q, want it to mention %q", i, invalid.Problems[i].Message, w)
		}
	}
	if _, err := profileset.Compile(nil, profileset.ChannelDev); !errors.Is(err, profileset.ErrInvalid) {
		t.Fatalf("empty set: err = %v", err)
	}
}

func TestReleaseFieldsFollowTheTargetSchema(t *testing.T) {
	t.Parallel()
	set, err := profileset.Compile([]profileset.Document{doc(t, "engine/engine.default.yaml", base(t))}, profileset.ChannelDev)
	if err != nil {
		t.Fatal(err)
	}
	good := profileset.Release{Version: "2026.10.1", EffectiveFrom: "2026-11-01", Priority: tuf.PriorityNormal, ChangeNote: tuf.ChangeNote{Ar: "تحديث", En: "Update"}}
	name, target, err := set.Target(good, []byte("container"))
	if err != nil || name != "prayer_profiles/2026.10.1" || target.Length != 9 || target.Custom.RollbackOf != nil {
		t.Fatalf("Target = %s %+v, %v", name, target, err)
	}
	for label, mutate := range map[string]func(*profileset.Release){
		"version with a slash": func(r *profileset.Release) { r.Version = "a/b" },
		"impossible date":      func(r *profileset.Release) { r.EffectiveFrom = "2026-02-30" },
		"unknown priority":     func(r *profileset.Release) { r.Priority = "high" },
		"missing Arabic note":  func(r *profileset.Release) { r.ChangeNote.Ar = " " },
		"rollback of itself":   func(r *profileset.Release) { r.RollbackOf = r.Version },
	} {
		r := good
		mutate(&r)
		if _, _, err := set.Target(r, nil); !errors.Is(err, profileset.ErrRelease) {
			t.Errorf("%s: err = %v, want ErrRelease", label, err)
		}
	}
}
