// Package fixturetest round-trips schemas/fixtures through the Go wire
// models (ADR-023). Test-only support code.
package fixturetest

import (
	"encoding/json"
	"errors"
	"os"
	"path/filepath"
	"reflect"
	"slices"
	"testing"
)

// errNoRepoRoot is returned when no ancestor directory contains schemas/.
var errNoRepoRoot = errors.New("fixturetest: no ancestor directory contains schemas/")

// ValidFixtures returns the paths of schemas/fixtures/<schema>/valid/*.json,
// sorted, failing the test when there are none.
func ValidFixtures(t *testing.T, schema string) []string {
	t.Helper()
	root, err := repoRoot()
	if err != nil {
		t.Fatal(err)
	}
	files, err := filepath.Glob(filepath.Join(root, "schemas", "fixtures", schema, "valid", "*.json"))
	if err != nil {
		t.Fatalf("glob fixtures: %v", err)
	}
	if len(files) == 0 {
		t.Fatalf("no valid fixtures for %s", schema)
	}
	slices.Sort(files)
	return files
}

// RoundTrip decodes every valid fixture of schema into a T, encodes it again
// and fails unless the JSON is unchanged.
func RoundTrip[T any](t *testing.T, schema string) {
	t.Helper()
	for _, path := range ValidFixtures(t, schema) {
		t.Run(filepath.Base(path), func(t *testing.T) {
			original, err := os.ReadFile(path) //nolint:gosec // test fixture path built from a glob of the repo's own files
			if err != nil {
				t.Fatalf("read fixture: %v", err)
			}
			var model T
			if err := json.Unmarshal(original, &model); err != nil {
				t.Fatalf("decode: %v", err)
			}
			encoded, err := json.Marshal(model)
			if err != nil {
				t.Fatalf("encode: %v", err)
			}
			var want, got any
			if err := json.Unmarshal(original, &want); err != nil {
				t.Fatalf("decode original: %v", err)
			}
			if err := json.Unmarshal(encoded, &got); err != nil {
				t.Fatalf("decode re-encoded: %v", err)
			}
			if !reflect.DeepEqual(want, got) {
				t.Fatalf("round-trip changed the JSON\nwant: %s\ngot:  %s", original, encoded)
			}
		})
	}
}

// InvalidFixtures returns the paths of schemas/fixtures/<schema>/invalid/*.json, sorted.
func InvalidFixtures(t *testing.T, schema string) []string {
	t.Helper()
	files, err := filepath.Glob(filepath.Join(RepoRoot(t), "schemas", "fixtures", schema, "invalid", "*.json"))
	if err != nil {
		t.Fatalf("glob fixtures: %v", err)
	}
	slices.Sort(files)
	return files
}

// RepoRoot returns the repository root (the nearest ancestor holding schemas/).
func RepoRoot(t *testing.T) string {
	t.Helper()
	root, err := repoRoot()
	if err != nil {
		t.Fatal(err)
	}
	return root
}

// InvalidFixture returns the bytes of schemas/fixtures/<schema>/invalid/<name>.
func InvalidFixture(t *testing.T, schema, name string) []byte {
	t.Helper()
	root, err := repoRoot()
	if err != nil {
		t.Fatal(err)
	}
	data, err := os.ReadFile(filepath.Join(root, "schemas", "fixtures", schema, "invalid", name)) //nolint:gosec // repo fixture
	if err != nil {
		t.Fatalf("read invalid fixture: %v", err)
	}
	return data
}

func repoRoot() (string, error) {
	dir, err := os.Getwd()
	if err != nil {
		return "", err
	}
	for {
		if info, err := os.Stat(filepath.Join(dir, "schemas")); err == nil && info.IsDir() {
			return dir, nil
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return "", errNoRepoRoot
		}
		dir = parent
	}
}
