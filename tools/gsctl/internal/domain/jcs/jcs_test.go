package jcs_test

import (
	"encoding/json"
	"errors"
	"os"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
)

type vectorFile struct {
	Vectors []struct {
		Name      string `json:"name"`
		Input     string `json:"input"`
		Canonical string `json:"canonical"`
	} `json:"vectors"`
}

// The vectors are shared with dm_core_types' CanonicalJson, so Go-signed
// metadata verifies in Dart (REQ-DIST-004).
func TestCanonicalizeMatchesSharedVectors_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	data, err := os.ReadFile("../../../testdata/jcs/vectors.json")
	if err != nil {
		t.Fatal(err)
	}
	var file vectorFile
	if err := json.Unmarshal(data, &file); err != nil {
		t.Fatal(err)
	}
	if len(file.Vectors) == 0 {
		t.Fatal("no vectors")
	}
	for _, v := range file.Vectors {
		t.Run(v.Name, func(t *testing.T) {
			t.Parallel()
			got, err := jcs.Canonicalize([]byte(v.Input))
			if err != nil {
				t.Fatalf("Canonicalize: %v", err)
			}
			if string(got) != v.Canonical {
				t.Fatalf("got  %s\nwant %s", got, v.Canonical)
			}
		})
	}
}

func TestCanonicalizeRejectsInputRFC8785CannotRepresent_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name  string
		input string
	}{
		{name: "duplicate member", input: `{"a":1,"a":2}`},
		{name: "number beyond the double range", input: `[1e400]`},
		{name: "invalid UTF-8", input: "\"\xff\""},
		{name: "trailing data", input: `{} {}`},
		{name: "truncated", input: `{"a":`},
		{name: "empty", input: ``},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			if _, err := jcs.Canonicalize([]byte(tc.input)); !errors.Is(err, jcs.ErrInvalidInput) {
				t.Fatalf("Canonicalize(%q) error = %v, want ErrInvalidInput", tc.input, err)
			}
		})
	}
}

func TestMarshalCanonicalisesAGoValue_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	got, err := jcs.Marshal(map[string]any{"b": "<&>", "a": 1.5e-7})
	if err != nil {
		t.Fatal(err)
	}
	if want := `{"a":1.5e-7,"b":"<&>"}`; string(got) != want {
		t.Fatalf("got %s, want %s", got, want)
	}
}
