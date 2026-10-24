package validate_test

import (
	"bytes"
	"errors"
	"os"
	"path/filepath"
	"testing"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/fixturetest"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

func newValidator(t *testing.T) *validate.Validator {
	t.Helper()
	v, err := validate.New()
	if err != nil {
		t.Fatalf("compile schemas: %v", err)
	}
	return v
}

func TestEmbeddedSchemasMatchRepository(t *testing.T) {
	t.Parallel()
	root := fixturetest.RepoRoot(t)
	for _, s := range validate.All {
		want, err := os.ReadFile(filepath.Join(root, "schemas", validate.FileName(s))) //nolint:gosec // repo schema
		if err != nil {
			t.Fatalf("read %s: %v", s, err)
		}
		got, err := validate.Embedded(s)
		if err != nil {
			t.Fatal(err)
		}
		if !bytes.Equal(want, got) {
			t.Errorf("%s: embedded copy differs from schemas/; run go generate ./internal/schema/validate", s)
		}
	}
}

func TestREQAPI005ValidFixturesPass(t *testing.T) {
	t.Parallel()
	v := newValidator(t)
	for _, s := range validate.All {
		for _, path := range fixturetest.ValidFixtures(t, string(s)) {
			body, err := os.ReadFile(path) //nolint:gosec // repo fixture
			if err != nil {
				t.Fatal(err)
			}
			if err := v.Validate(s, body); err != nil {
				t.Errorf("%s: %v", path, err)
			}
		}
	}
}

func TestREQAPI005InvalidFixturesAreRejected(t *testing.T) {
	t.Parallel()
	v := newValidator(t)
	for _, s := range validate.All {
		for _, path := range fixturetest.InvalidFixtures(t, string(s)) {
			body, err := os.ReadFile(path) //nolint:gosec // repo fixture
			if err != nil {
				t.Fatal(err)
			}
			if err := v.Validate(s, body); !errors.Is(err, validate.ErrInvalid) {
				t.Errorf("%s was accepted (err = %v)", path, err)
			}
		}
	}
}

func TestREQAPI005RejectsTrailingDataAndNonJSON(t *testing.T) {
	t.Parallel()
	v := newValidator(t)
	for _, body := range []string{`{"receiptId":"0b4f8c9e-2d1a-4c3b-9e8f-7a6b5c4d3e2f"} {}`, `not json`, ``} {
		if err := v.Validate(validate.CorrectionReceipt, []byte(body)); !errors.Is(err, validate.ErrInvalid) {
			t.Errorf("%q was accepted", body)
		}
	}
}
