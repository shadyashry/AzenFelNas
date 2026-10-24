package distribution_test

import (
	"context"
	"errors"
	"slices"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

func TestBucketKeysAndCachePolicyFollowSection91_REQ_DIST_005(t *testing.T) {
	t.Parallel()
	if got := distribution.MetadataKey("dev", trust.RoleTimestamp); got != "dev/metadata/timestamp.json" {
		t.Errorf("MetadataKey = %s", got)
	}
	key, err := distribution.PackageKey("lab", "prayer_profiles/2026.10.1", "ab")
	if err != nil || key != "lab/packages/prayer_profiles/2026.10.1/ab.dmpkg" {
		t.Errorf("PackageKey = %s, %v", key, err)
	}
	if _, err := distribution.PackageKey("lab", "no-slash", "ab"); err == nil {
		t.Error("a target name without a type was accepted")
	}
	if distribution.CacheControl(trust.RoleTimestamp) != "public, max-age=300" ||
		distribution.CacheControl(trust.RoleSnapshot) != "public, max-age=3600" ||
		distribution.CachePackage != "public, max-age=31536000, immutable" {
		t.Error("cache policy differs from §9.1")
	}
}

// files signs one channel at sequence seq for every role; root at version rootVersion.
func files(t *testing.T, ks testsupport.KeySet, rootVersion, seq int) map[trust.RoleName][]byte {
	t.Helper()
	now := time.Date(2026, 10, 22, 0, 0, 0, 0, time.UTC)
	sign := func(doc tuf.SignedVariant, role trust.RoleName) []byte {
		m, err := trust.Sign(context.Background(), tuf.Signed{Variant: doc}, ks.SignersOf(role))
		if err != nil {
			t.Fatal(err)
		}
		f, err := trust.EncodeFile(m)
		if err != nil {
			t.Fatal(err)
		}
		return f
	}
	root, err := trust.NewRoot(rootVersion, now.Add(time.Hour), ks.Config)
	if err != nil {
		t.Fatal(err)
	}
	out := map[trust.RoleName][]byte{trust.RoleRoot: sign(root, trust.RoleRoot)}
	targets := tuf.Targets{Sequence: seq, Expires: trust.FormatExpires(now.Add(time.Hour)), Targets: map[string]tuf.Target{}}
	out[trust.RoleTargets] = sign(targets, trust.RoleTargets)
	env, err := trust.ParseEnvelope(out[trust.RoleTargets])
	if err != nil {
		t.Fatal(err)
	}
	snapshot, err := trust.NewSnapshot(seq, now.Add(time.Hour), env)
	if err != nil {
		t.Fatal(err)
	}
	out[trust.RoleSnapshot] = sign(snapshot, trust.RoleSnapshot)
	if env, err = trust.ParseEnvelope(out[trust.RoleSnapshot]); err != nil {
		t.Fatal(err)
	}
	timestamp, err := trust.NewTimestamp(seq, now, now.Add(time.Hour), env)
	if err != nil {
		t.Fatal(err)
	}
	out[trust.RoleTimestamp] = sign(timestamp, trust.RoleTimestamp)
	return out
}

func TestPlanMetadataUploadsOnlyNewerChangedRoles_REQ_DIST_002(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	v1, v2 := files(t, ks, 1, 1), files(t, ks, 1, 2)

	first, err := distribution.PlanMetadata(v1, map[trust.RoleName][]byte{})
	if err != nil || !slices.Equal(first, distribution.PublishOrder()) {
		t.Fatalf("first publish = %v, %v; want every role", first, err)
	}
	same, err := distribution.PlanMetadata(v1, v1)
	if err != nil || len(same) != 0 {
		t.Fatalf("republishing identical files = %v, %v; want nothing", same, err)
	}
	onlyTimestamp := map[trust.RoleName][]byte{
		trust.RoleRoot: v1[trust.RoleRoot], trust.RoleTargets: v1[trust.RoleTargets],
		trust.RoleSnapshot: v1[trust.RoleSnapshot], trust.RoleTimestamp: v2[trust.RoleTimestamp],
	}
	if got, err := distribution.PlanMetadata(onlyTimestamp, v1); err != nil || !slices.Equal(got, []trust.RoleName{trust.RoleTimestamp}) {
		t.Fatalf("timestamp refresh = %v, %v", got, err)
	}
	if _, err := distribution.PlanMetadata(v1, v2); !errors.Is(err, trust.ErrSequenceRegression) {
		t.Fatalf("publishing older metadata: err = %v, want ErrSequenceRegression", err)
	}
	resigned := files(t, testsupport.NewKeySet(t), 1, 3)
	if _, err := distribution.PlanMetadata(resigned, v2); !errors.Is(err, trust.ErrSequenceRegression) {
		t.Fatalf("a different root at the same version: err = %v, want ErrSequenceRegression", err)
	}
}
