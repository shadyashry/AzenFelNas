package app_test

import (
	"context"
	"encoding/json"
	"errors"
	"maps"
	"strings"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/yamlprofiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/app"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

var start = time.Date(2026, 10, 21, 12, 0, 0, 0, time.UTC)

// world is one channel with fakes at every port; the profiles are the
// committed seeds, read once as fixture data.
type world struct {
	ks       testsupport.KeySet
	repo     *testsupport.MemRepo
	ring     testsupport.Ring
	clock    testsupport.Clock
	profiles testsupport.Profiles
}

func newWorld(t *testing.T) *world {
	t.Helper()
	docs, err := yamlprofiles.Source{Dir: "../../../../profiles"}.LoadProfiles(context.Background())
	if err != nil {
		t.Fatal(err)
	}
	ks := testsupport.NewKeySet(t)
	return &world{
		ks: ks, repo: testsupport.NewMemRepo(), ring: testsupport.Ring{Signers: maps.Clone(ks.Signers)},
		clock: testsupport.Clock{T: start}, profiles: testsupport.Profiles{Docs: docs},
	}
}

func release(version string) profileset.Release {
	return profileset.Release{
		Version: version, EffectiveFrom: "2026-11-01", Priority: tuf.PriorityNormal,
		ChangeNote: tuf.ChangeNote{Ar: "ملاحظة", En: "Note"},
	}
}

func (w *world) build(t *testing.T, r profileset.Release) (app.Built, error) {
	t.Helper()
	return app.BuildProfilesPackage{Source: w.profiles, Packages: w.repo, Stager: w.repo}.
		Run(t.Context(), app.BuildRequest{Channel: profileset.ChannelDev, Release: r})
}

func (w *world) sign(t *testing.T, role trust.RoleName, req app.SignRequest) (app.SignedRole, error) {
	t.Helper()
	keys := testsupport.KeyConfig{Config: w.ks.Config}
	switch role {
	case trust.RoleRoot:
		return app.SignRoot{Keys: keys, Ring: w.ring, Reader: w.repo, Writer: w.repo, Clock: w.clock}.Run(t.Context(), req)
	case trust.RoleTargets:
		return app.SignTargets{Keys: keys, Ring: w.ring, Reader: w.repo, Writer: w.repo, Staged: w.repo, Clock: w.clock}.Run(t.Context(), req)
	case trust.RoleSnapshot:
		return app.SignSnapshot{Keys: keys, Ring: w.ring, Reader: w.repo, Writer: w.repo, Clock: w.clock}.Run(t.Context(), req)
	case trust.RoleTimestamp:
		return app.SignTimestamp{Keys: keys, Ring: w.ring, Reader: w.repo, Writer: w.repo, Clock: w.clock}.Run(t.Context(), req)
	}
	return app.SignedRole{}, nil
}

// publish builds version and signs every role but root.
func (w *world) publish(t *testing.T, r profileset.Release) app.Built {
	t.Helper()
	built, err := w.build(t, r)
	if err != nil {
		t.Fatal(err)
	}
	for _, role := range []trust.RoleName{trust.RoleTargets, trust.RoleSnapshot, trust.RoleTimestamp} {
		if _, err := w.sign(t, role, app.SignRequest{}); err != nil {
			t.Fatalf("sign %s: %v", role, err)
		}
	}
	return built
}

func (w *world) verify(t *testing.T, after trust.Sequences) (app.Verified, error) {
	t.Helper()
	return app.VerifyRepository{Anchor: testsupport.Anchor{Anchor: w.ks.Anchor}, Reader: w.repo, Packages: w.repo, Clock: w.clock}.
		Run(t.Context(), after)
}

func signRoot(t *testing.T, w *world) {
	t.Helper()
	if _, err := w.sign(t, trust.RoleRoot, app.SignRequest{}); err != nil {
		t.Fatal(err)
	}
}

func TestBuildSignVerifyRoundTrip_REQ_DIST_001_REQ_DIST_003_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)

	built := w.publish(t, release("2026.10.1"))
	got, err := w.verify(t, trust.Sequences{})
	if err != nil {
		t.Fatalf("verify: %v", err)
	}

	if built.Name != "prayer_profiles/2026.10.1" || built.Profiles != 4 {
		t.Fatalf("built %+v", built)
	}
	if len(got.Targets) != 1 || got.Chain.Sequences != (trust.Sequences{Timestamp: 1, Snapshot: 1, Targets: 1}) {
		t.Fatalf("verified %+v", got)
	}
	if len(w.repo.Staged) != 0 {
		t.Fatalf("staged targets left after signing: %v", w.repo.Staged)
	}
	root, err := trust.ParseEnvelope(w.repo.Metadata[trust.RoleRoot])
	if err != nil || len(root.Metadata.Signatures) != 3 {
		t.Fatalf("root signatures %d, %v", len(root.Metadata.Signatures), err)
	}
}

func TestSeedProfilesAreRefusedForProduction_REQ_GOV_001(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	_, err := app.BuildProfilesPackage{Source: w.profiles, Packages: w.repo, Stager: w.repo}.
		Run(t.Context(), app.BuildRequest{Channel: profileset.ChannelProduction, Release: release("2026.10.1")})
	if !errors.Is(err, profileset.ErrInvalid) || len(w.repo.Packages) != 0 || len(w.repo.Staged) != 0 {
		t.Fatalf("err = %v; %d packages, %d staged", err, len(w.repo.Packages), len(w.repo.Staged))
	}
}

func TestSigningARegressedSequenceIsRefused_REQ_DIST_002(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	for _, role := range trust.Roles() {
		if _, err := w.sign(t, role, app.SignRequest{Sequence: 1}); !errors.Is(err, trust.ErrSequenceRegression) {
			t.Errorf("%s at sequence 1 again: err = %v, want ErrSequenceRegression", role, err)
		}
	}
	signed, err := w.sign(t, trust.RoleTargets, app.SignRequest{Sequence: 7})
	if err != nil || signed.Sequence != 7 {
		t.Fatalf("a jump forward: %+v, %v", signed, err)
	}
}

// A rollback is a new manifest with a higher sequence pointing at the old
// content (ADR-009); a client holding the newer sequences accepts it.
func TestRollbackIsANewHigherSequence_REQ_DIST_002_REQ_PKG_005(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	v1 := w.publish(t, release("2026.10.1"))
	seed := w.profiles
	w.profiles = withChangedAuthorityName(t, seed)
	w.publish(t, release("2026.10.2"))
	trusted, err := w.verify(t, trust.Sequences{})
	if err != nil {
		t.Fatal(err)
	}

	w.profiles = seed
	rb := release("2026.10.3")
	rb.RollbackOf = "2026.10.2"
	v3 := w.publish(t, rb)
	got, err := w.verify(t, trusted.Chain.Sequences)
	if err != nil {
		t.Fatalf("the rollback manifest was refused: %v", err)
	}

	if v3.Target.SHA256 != v1.Target.SHA256 || v3.Target.Custom.RollbackOf == nil || *v3.Target.Custom.RollbackOf != "2026.10.2" {
		t.Fatalf("rollback target %+v, want v1's content with rollbackOf", v3.Target)
	}
	if len(got.Targets) != 3 {
		t.Fatalf("targets %v, want all three versions kept", got.Targets)
	}
	if _, err := w.verify(t, got.Chain.Sequences); !errors.Is(err, trust.ErrSequenceRegression) {
		t.Fatalf("replaying the same metadata: err = %v, want ErrSequenceRegression", err)
	}
}

func TestRepublishingAVersionWithOtherContentIsRefused_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	w.profiles = withChangedAuthorityName(t, w.profiles)
	if _, err := w.build(t, release("2026.10.1")); err != nil {
		t.Fatal(err)
	}
	if _, err := w.sign(t, trust.RoleTargets, app.SignRequest{}); !errors.Is(err, trust.ErrImmutableTarget) {
		t.Fatalf("err = %v, want ErrImmutableTarget", err)
	}
}

func TestVerifyDetectsATamperedPackage_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	built := w.publish(t, release("2026.10.1"))
	key := built.Name + "@" + built.Target.SHA256
	w.repo.Packages[key][len(w.repo.Packages[key])/2] ^= 0x01

	if _, err := w.verify(t, trust.Sequences{}); trust.Code(err) != "PKG_HASH_MISMATCH" {
		t.Fatalf("err = %v, want PKG_HASH_MISMATCH", err)
	}
}

func TestSigningNeedsTheThresholdOfMatchingKeys_REQ_DIST_001(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	delete(w.ring.Signers, "root-2")
	delete(w.ring.Signers, "root-3")
	if _, err := w.sign(t, trust.RoleRoot, app.SignRequest{}); !errors.Is(err, trust.ErrInsufficientKeys) {
		t.Fatalf("one root key: err = %v, want ErrInsufficientKeys", err)
	}
	w.ring.Signers["root-2"] = w.ks.Signers["targets-1"]
	w.ring.Signers["root-3"] = w.ks.Signers["root-3"]
	if _, err := w.sign(t, trust.RoleRoot, app.SignRequest{}); !errors.Is(err, trust.ErrKeyMismatch) {
		t.Fatalf("a wrong private key: err = %v, want ErrKeyMismatch", err)
	}
	if _, err := w.sign(t, trust.RoleTargets, app.SignRequest{}); err == nil || !strings.Contains(err.Error(), "sign the root role") {
		t.Fatalf("targets before root: err = %v", err)
	}
}

func TestKeyConfigThatDriftedFromTheSignedRootIsRefused(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	other := testsupport.NewKeySet(t)
	w.ks.Config.Roles[trust.RoleSnapshot] = other.Config.Roles[trust.RoleSnapshot]
	w.ring.Signers["snapshot-1"] = other.Signers["snapshot-1"]
	if _, err := w.build(t, release("2026.10.1")); err != nil {
		t.Fatal(err)
	}
	if _, err := w.sign(t, trust.RoleTargets, app.SignRequest{}); err != nil {
		t.Fatal(err)
	}
	if _, err := w.sign(t, trust.RoleSnapshot, app.SignRequest{}); !errors.Is(err, trust.ErrKeyMismatch) {
		t.Fatalf("err = %v, want ErrKeyMismatch", err)
	}
}

func TestTimestampLifetimeIsCappedAtSevenDays(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	if _, err := w.sign(t, trust.RoleTimestamp, app.SignRequest{Lifetime: 8 * 24 * time.Hour}); !errors.Is(err, trust.ErrTimestampExpiry) {
		t.Fatalf("err = %v, want ErrTimestampExpiry", err)
	}
}

// withChangedAuthorityName changes a display string of one seed, which
// changes the payload without touching any religious value.
func withChangedAuthorityName(t *testing.T, p testsupport.Profiles) testsupport.Profiles {
	t.Helper()
	out := testsupport.Profiles{Docs: append([]profileset.Document(nil), p.Docs...)}
	var doc map[string]any
	if err := json.Unmarshal(out.Docs[0].JSON, &doc); err != nil {
		t.Fatal(err)
	}
	doc["authority"] = map[string]any{"name": "renamed for the test", "type": "GOVERNMENT"}
	data, err := json.Marshal(doc)
	if err != nil {
		t.Fatal(err)
	}
	out.Docs[0].JSON = data
	return out
}
