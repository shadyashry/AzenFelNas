package dmpkg_test

import (
	"bytes"
	"errors"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/dmpkg"
)

func TestPackIsDeterministicAndRoundTrips_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	payload := []byte(`[{"profileId":"engine.default"}]`)

	first, err := dmpkg.Pack("profiles.json", payload)
	if err != nil {
		t.Fatal(err)
	}
	second, err := dmpkg.Pack("profiles.json", payload)
	if err != nil {
		t.Fatal(err)
	}
	if !bytes.Equal(first, second) {
		t.Fatal("packing the same payload twice gave different bytes, so a rebuild changes the content address")
	}
	name, got, err := dmpkg.Unpack(first)
	if err != nil || name != "profiles.json" || !bytes.Equal(got, payload) {
		t.Fatalf("Unpack = %q %q %v", name, got, err)
	}
}

func TestUnpackRefusesAnythingButOneGzipMember(t *testing.T) {
	t.Parallel()
	one, err := dmpkg.Pack("a.json", []byte("{}"))
	if err != nil {
		t.Fatal(err)
	}
	if _, _, err := dmpkg.Unpack(append(bytes.Clone(one), one...)); !errors.Is(err, dmpkg.ErrNotSingle) {
		t.Fatalf("two members: err = %v", err)
	}
	if _, _, err := dmpkg.Unpack([]byte("not gzip")); err == nil {
		t.Fatal("not gzip: no error")
	}
}
