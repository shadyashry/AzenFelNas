package yamlprofiles_test

import (
	"context"
	"os"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/yamlprofiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
)

const repoRoot = "../../../../../"

func TestLoadsEverySeedProfileInPathOrder(t *testing.T) {
	t.Parallel()
	docs, err := yamlprofiles.Source{Dir: repoRoot + "profiles"}.LoadProfiles(context.Background())
	if err != nil {
		t.Fatal(err)
	}
	want := []string{"ae/ae.awqaf.standard.yaml", "eg/eg.egas.standard.yaml", "engine/engine.default.yaml", "sa/sa.ummalqura.standard.yaml"}
	if len(docs) != len(want) {
		t.Fatalf("got %d documents, want %d", len(docs), len(want))
	}
	for i, d := range docs {
		if d.Path != want[i] {
			t.Errorf("doc %d path %s, want %s", i, d.Path, want[i])
		}
	}
}

// Go and Dart read the same YAML as the same JSON: gsctl's compile of the
// engine default equals the copy geo_salah_profiles compiles for the bench
// (§15 D51), compared in canonical form.
func TestYAMLReadsAsTheSameJSONAsTheDartTool(t *testing.T) {
	t.Parallel()
	yamlBytes, err := os.ReadFile(repoRoot + "profiles/engine/engine.default.yaml")
	if err != nil {
		t.Fatal(err)
	}
	dartJSON, err := os.ReadFile(repoRoot + "packages/geo_salah_core/bench/profiles/engine.default.json")
	if err != nil {
		t.Fatal(err)
	}
	goJSON, err := yamlprofiles.ToJSON(yamlBytes)
	if err != nil {
		t.Fatal(err)
	}
	a, errA := jcs.Canonicalize(goJSON)
	b, errB := jcs.Canonicalize(dartJSON)
	if errA != nil || errB != nil || string(a) != string(b) {
		t.Fatalf("Go and Dart compiles differ (%v, %v)\ngo:   %s\ndart: %s", errA, errB, a, b)
	}
}

func TestToJSONKeepsScalarsAsAuthored(t *testing.T) {
	t.Parallel()
	got, err := yamlprofiles.ToJSON([]byte("a: 19.5\nb: -0.8333\nc: 2026-11-01\nd: \"18\"\ne: null\nf: true\ng: [1, {h: x}]\n"))
	if err != nil {
		t.Fatal(err)
	}
	if want := `{"a":19.5,"b":-0.8333,"c":"2026-11-01","d":"18","e":null,"f":true,"g":[1,{"h":"x"}]}`; string(got) != want {
		t.Fatalf("got %s\nwant %s", got, want)
	}
}

func TestToJSONRefusesYAMLThatIsNotPlainJSONData(t *testing.T) {
	t.Parallel()
	tests := map[string]string{
		"anchor and alias": "a: &x 1\nb: *x\n",
		"merge key":        "a: {x: 1}\nb:\n  <<: {x: 1}\n",
		"duplicate key":    "a: 1\na: 2\n",
		"hex integer":      "a: 0x1F\n",
		"infinity":         "a: .inf\n",
		"non-string key":   "1: a\n",
		"custom tag":       "a: !thing 1\n",
		"two documents":    "a: 1\n---\nb: 2\n",
		"empty":            "",
	}
	for name, input := range tests {
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			if _, err := yamlprofiles.ToJSON([]byte(input)); err == nil {
				t.Fatalf("ToJSON(%q) succeeded", input)
			}
		})
	}
}
