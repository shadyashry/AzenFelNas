package app_test

import (
	"errors"
	"slices"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/app"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

func (w *world) publishTo(t *testing.T, bucket *testsupport.Bucket) (app.Published, error) {
	t.Helper()
	verify := app.VerifyRepository{Anchor: testsupport.Anchor{Anchor: w.ks.Anchor}, Reader: w.repo, Packages: w.repo, Clock: w.clock}
	return app.PublishChannel{Verify: verify, Reader: w.repo, Packages: w.repo, Store: bucket}.Run(t.Context(), profileset.ChannelDev)
}

func TestPublishCopiesAVerifiedChannelInSection91Layout_REQ_DIST_003_REQ_DIST_005(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	built := w.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()

	got, err := w.publishTo(t, bucket)
	if err != nil {
		t.Fatal(err)
	}

	packageKey := "dev/packages/prayer_profiles/2026.10.1/" + built.Target.SHA256 + ".dmpkg"
	if !slices.Equal(got.Packages, []string{built.Name}) || !slices.Equal(got.Roles, []trust.RoleName{trust.RoleRoot, trust.RoleTargets, trust.RoleSnapshot, trust.RoleTimestamp}) {
		t.Fatalf("published %+v", got)
	}
	want := map[string]string{
		packageKey:                    "public, max-age=31536000, immutable",
		"dev/metadata/root.json":      "public, max-age=3600",
		"dev/metadata/targets.json":   "public, max-age=3600",
		"dev/metadata/snapshot.json":  "public, max-age=3600",
		"dev/metadata/timestamp.json": "public, max-age=300",
	}
	if len(bucket.Objects) != len(want) {
		t.Fatalf("bucket holds %d objects, want %d", len(bucket.Objects), len(want))
	}
	for key, cache := range want {
		if bucket.CacheControl[key] != cache {
			t.Errorf("%s Cache-Control %q, want %q", key, bucket.CacheControl[key], cache)
		}
	}
}

func TestRepublishingUploadsOnlyWhatChanged_REQ_DIST_002(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	if _, err := w.publishTo(t, bucket); err != nil {
		t.Fatal(err)
	}

	again, err := w.publishTo(t, bucket)
	if err != nil || len(again.Packages) != 0 || len(again.Roles) != 0 {
		t.Fatalf("an unchanged channel republished %+v, %v", again, err)
	}
	if _, err := w.sign(t, trust.RoleTimestamp, app.SignRequest{}); err != nil {
		t.Fatal(err)
	}
	refreshed, err := w.publishTo(t, bucket)
	if err != nil || !slices.Equal(refreshed.Roles, []trust.RoleName{trust.RoleTimestamp}) {
		t.Fatalf("a timestamp refresh published %+v, %v", refreshed, err)
	}
}

func TestPublishRefusesOlderMetadataThanTheBucket_REQ_DIST_002(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	stale := testsupport.NewMemRepo()
	for role, file := range w.repo.Metadata {
		stale.Metadata[role] = append([]byte(nil), file...)
	}
	for key, data := range w.repo.Packages {
		stale.Packages[key] = data
	}
	w.publish(t, release("2026.10.2"))
	if _, err := w.publishTo(t, bucket); err != nil {
		t.Fatal(err)
	}

	w.repo = stale
	if _, err := w.publishTo(t, bucket); !errors.Is(err, trust.ErrSequenceRegression) {
		t.Fatalf("err = %v, want ErrSequenceRegression", err)
	}
}

func TestPublishRefusesAnUnverifiableChannelAndWritesNothing_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	w.repo.Metadata[trust.RoleTargets][40] ^= 0x01
	bucket := testsupport.NewBucket()

	if _, err := w.publishTo(t, bucket); trust.Code(err) == "" || len(bucket.Objects) != 0 {
		t.Fatalf("err = %v, %d objects written", err, len(bucket.Objects))
	}
}

func TestPublishRefusesAPackageKeyHoldingOtherBytes_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	built := w.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	bucket.Objects["dev/packages/prayer_profiles/2026.10.1/"+built.Target.SHA256+".dmpkg"] = []byte("other bytes")

	if _, err := w.publishTo(t, bucket); !errors.Is(err, trust.ErrImmutableTarget) {
		t.Fatalf("err = %v, want ErrImmutableTarget", err)
	}
}
