package testsupport

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"slices"
	"strings"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// Repository is every port a channel repository implements.
type Repository interface {
	ports.MetadataReader
	ports.MetadataWriter
	ports.PackageReader
	ports.PackageWriter
	ports.TargetStager
	ports.StagedTargets
}

// RepositoryContract is the port contract of a channel repository
// (REQ-TEST-004): absent items are ports.ErrNotFound, writes replace,
// packages are addressed by target and SHA-256, staging round-trips and
// clearing is idempotent. newRepo returns an empty repository.
func RepositoryContract(t *testing.T, newRepo func(t *testing.T) Repository) {
	t.Helper()
	ctx := context.Background()
	const sha = "0000000000000000000000000000000000000000000000000000000000000001"
	t.Run("absent metadata and packages are ErrNotFound", func(t *testing.T) {
		r := newRepo(t)
		if _, err := r.ReadMetadata(ctx, trust.RoleTargets); !errors.Is(err, ports.ErrNotFound) {
			t.Fatalf("ReadMetadata err = %v", err)
		}
		if _, err := r.ReadPackage(ctx, "prayer_profiles/1", sha); !errors.Is(err, ports.ErrNotFound) {
			t.Fatalf("ReadPackage err = %v", err)
		}
	})
	t.Run("metadata writes replace", func(t *testing.T) {
		r := newRepo(t)
		for _, content := range []string{"first", "second"} {
			if err := r.WriteMetadata(ctx, trust.RoleSnapshot, []byte(content)); err != nil {
				t.Fatal(err)
			}
		}
		got, err := r.ReadMetadata(ctx, trust.RoleSnapshot)
		if err != nil || string(got) != "second" {
			t.Fatalf("ReadMetadata = %q, %v", got, err)
		}
	})
	t.Run("packages are content addressed", func(t *testing.T) {
		r := newRepo(t)
		if err := r.WritePackage(ctx, "prayer_profiles/1", sha, []byte("pkg")); err != nil {
			t.Fatal(err)
		}
		if err := r.WritePackage(ctx, "prayer_profiles/1", sha, []byte("pkg")); err != nil {
			t.Fatalf("writing the same package twice: %v", err)
		}
		got, err := r.ReadPackage(ctx, "prayer_profiles/1", sha)
		if err != nil || !bytes.Equal(got, []byte("pkg")) {
			t.Fatalf("ReadPackage = %q, %v", got, err)
		}
		if _, err := r.ReadPackage(ctx, "prayer_profiles/2", sha); !errors.Is(err, ports.ErrNotFound) {
			t.Fatalf("other version: err = %v", err)
		}
	})
	t.Run("staging round-trips and clears", func(t *testing.T) {
		r := newRepo(t)
		target := tuf.Target{Length: 3, SHA256: sha, Custom: tuf.TargetCustom{
			SchemaVersion: 1, PayloadFormat: tuf.PayloadJSON, Compat: tuf.Compat{MinApp: "1.0.0", MinEngineSchema: 1},
			EffectiveFrom: "2026-11-01", Priority: tuf.PriorityNormal, ChangeNote: tuf.ChangeNote{Ar: "ع", En: "e"},
		}}
		if err := r.StageTarget(ctx, "prayer_profiles/1.0+b", target); err != nil {
			t.Fatal(err)
		}
		staged, err := r.StagedTargets(ctx)
		if err != nil || len(staged) != 1 || staged["prayer_profiles/1.0+b"].SHA256 != sha {
			t.Fatalf("StagedTargets = %+v, %v", staged, err)
		}
		for range 2 {
			if err := r.ClearStaged(ctx, []string{"prayer_profiles/1.0+b"}); err != nil {
				t.Fatalf("ClearStaged: %v", err)
			}
		}
		if staged, err := r.StagedTargets(ctx); err != nil || len(staged) != 0 {
			t.Fatalf("after clear: %+v, %v", staged, err)
		}
	})
}

// KeyRingContract is the port contract of a key ring (REQ-TEST-004): a held
// key signs verifiably, an absent one is ports.ErrNotFound. newRing returns
// a ring holding exactly ks's "targets-1".
func KeyRingContract(t *testing.T, ks KeySet, newRing func(t *testing.T) ports.KeyRing) {
	t.Helper()
	ctx := context.Background()
	t.Run("a held key signs verifiably", func(t *testing.T) {
		s, err := newRing(t).Signer(ctx, "targets-1")
		if err != nil {
			t.Fatal(err)
		}
		want := ks.Signers["targets-1"].PublicKey()
		sig, err := s.Sign(ctx, []byte("m"))
		if err != nil || !s.PublicKey().Equal(want) || !want.Verify([]byte("m"), sig) {
			t.Fatalf("signature does not verify: %v", err)
		}
	})
	t.Run("an absent key is ErrNotFound", func(t *testing.T) {
		if _, err := newRing(t).Signer(ctx, "snapshot-1"); !errors.Is(err, ports.ErrNotFound) {
			t.Fatalf("err = %v", err)
		}
	})
}

// KeyMaterialContract is the port contract of the public key sources
// (REQ-TEST-004): the key config and the trust anchor describe exactly ks.
func KeyMaterialContract(t *testing.T, ks KeySet, config ports.KeyConfigSource, anchor ports.TrustAnchorSource) {
	t.Helper()
	ctx := context.Background()
	got, err := config.LoadKeyConfig(ctx)
	if err != nil {
		t.Fatalf("LoadKeyConfig: %v", err)
	}
	for _, role := range trust.Roles() {
		want, have := ks.Config.Roles[role], got.Roles[role]
		if want.Threshold != have.Threshold || len(want.Keys) != len(have.Keys) {
			t.Fatalf("%s: got %+v, want %+v", role, have, want)
		}
		for i := range want.Keys {
			if want.Keys[i].Name != have.Keys[i].Name || !want.Keys[i].Key.Equal(have.Keys[i].Key) {
				t.Fatalf("%s key %d: got %s, want %s", role, i, have.Keys[i].Name, want.Keys[i].Name)
			}
		}
	}
	a, err := anchor.LoadTrustAnchor(ctx)
	if err != nil {
		t.Fatalf("LoadTrustAnchor: %v", err)
	}
	if a.Threshold != ks.Anchor.Threshold || len(a.Keys) != len(ks.Anchor.Keys) {
		t.Fatalf("anchor %+v, want %+v", a, ks.Anchor)
	}
	for i := range a.Keys {
		if !a.Keys[i].Equal(ks.Anchor.Keys[i]) {
			t.Fatalf("anchor key %d differs", i)
		}
	}
}

// ProfileSourceContract is the port contract of a profile source
// (REQ-TEST-004): documents are JSON objects with slash-separated relative
// paths, in path order.
func ProfileSourceContract(t *testing.T, source ports.ProfileSource) {
	t.Helper()
	docs, err := source.LoadProfiles(context.Background())
	if err != nil {
		t.Fatalf("LoadProfiles: %v", err)
	}
	if len(docs) == 0 {
		t.Fatal("no documents")
	}
	for i, d := range docs {
		if i > 0 && docs[i-1].Path >= d.Path {
			t.Fatalf("paths out of order: %s before %s", docs[i-1].Path, d.Path)
		}
		if strings.Contains(d.Path, `\`) || strings.HasPrefix(d.Path, "/") || !json.Valid(d.JSON) || !bytes.HasPrefix(d.JSON, []byte("{")) {
			t.Fatalf("document %s is not a JSON object at a relative slash path", d.Path)
		}
	}
}

// ClockContract is the port contract of a clock (REQ-TEST-004): UTC and
// after the Unix epoch.
func ClockContract(t *testing.T, clock ports.Clock) {
	t.Helper()
	now := clock.Now()
	if now.Location() != time.UTC || now.Unix() <= 0 {
		t.Fatalf("Now() = %v, want a UTC instant after 1970", now)
	}
}

// ChangedPathsContract is the port contract of a changed-path list
// (REQ-TEST-004): want, in order, slash-separated, with no blank entry.
func ChangedPathsContract(t *testing.T, source ports.ChangedPaths, want []string) {
	t.Helper()
	got, err := source.ChangedPaths(context.Background())
	if err != nil {
		t.Fatalf("ChangedPaths: %v", err)
	}
	if !slices.Equal(got, want) {
		t.Fatalf("got %q, want %q", got, want)
	}
}

// ObjectStoreContract is the port contract of the distribution bucket
// (REQ-TEST-004): an absent key is ErrNotFound and a put replaces. newStore
// returns an empty bucket.
func ObjectStoreContract(t *testing.T, newStore func(t *testing.T) ports.ObjectStore) {
	t.Helper()
	ctx := context.Background()
	t.Run("an absent key is ErrNotFound", func(t *testing.T) {
		if _, err := newStore(t).GetObject(ctx, "dev/metadata/timestamp.json"); !errors.Is(err, ports.ErrNotFound) {
			t.Fatalf("err = %v", err)
		}
	})
	t.Run("a put replaces the object", func(t *testing.T) {
		s := newStore(t)
		for _, content := range []string{"first", "second"} {
			if err := s.PutObject(ctx, "dev/metadata/timestamp.json", []byte(content), "public, max-age=300"); err != nil {
				t.Fatal(err)
			}
		}
		got, err := s.GetObject(ctx, "dev/metadata/timestamp.json")
		if err != nil || string(got) != "second" {
			t.Fatalf("GetObject = %q, %v", got, err)
		}
	})
}
