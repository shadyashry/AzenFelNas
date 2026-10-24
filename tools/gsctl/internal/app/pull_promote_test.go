package app_test

import (
	"errors"
	"maps"
	"slices"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/app"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

func (w *world) publishAs(t *testing.T, bucket *testsupport.Bucket, channel profileset.Channel) {
	t.Helper()
	verify := app.VerifyRepository{Anchor: testsupport.Anchor{Anchor: w.ks.Anchor}, Reader: w.repo, Packages: w.repo, Clock: w.clock}
	if _, err := (app.PublishChannel{Verify: verify, Reader: w.repo, Packages: w.repo, Store: bucket}).Run(t.Context(), channel); err != nil {
		t.Fatal(err)
	}
}

func (w *world) bucketChain(bucket *testsupport.Bucket) app.BucketChain {
	return app.BucketChain{Anchor: testsupport.Anchor{Anchor: w.ks.Anchor}, Store: bucket, Clock: w.clock}
}

// fresh is a second channel repository (a fresh CI runner) under the same
// keys.
func (w *world) fresh() *world {
	return &world{ks: w.ks, repo: testsupport.NewMemRepo(), ring: w.ring, clock: w.clock, profiles: w.profiles}
}

func (w *world) pullFrom(t *testing.T, bucket *testsupport.Bucket, channel profileset.Channel) (app.Pulled, error) {
	t.Helper()
	return app.PullChannel{Published: w.bucketChain(bucket), Reader: w.repo, Writer: w.repo, Packages: w.repo}.Run(t.Context(), channel)
}

func TestReleaseOnAFreshRunnerContinuesTheLiveSequences_REQ_DIST_002(t *testing.T) {
	t.Parallel()
	first := newWorld(t)
	signRoot(t, first)
	first.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	first.publishAs(t, bucket, profileset.ChannelLab)

	runner := first.fresh()
	pulled, err := runner.pullFrom(t, bucket, profileset.ChannelLab)
	if err != nil {
		t.Fatal(err)
	}
	built := runner.publish(t, release("2026.10.2"))
	runner.publishAs(t, bucket, profileset.ChannelLab)

	if pulled.Fresh || pulled.Targets != 1 || pulled.Sequences != (trust.Sequences{Timestamp: 1, Snapshot: 1, Targets: 1}) {
		t.Fatalf("pulled %+v", pulled)
	}
	live, err := runner.bucketChain(bucket).Read(t.Context(), profileset.ChannelLab)
	if err != nil {
		t.Fatal(err)
	}
	if live.Chain.Sequences != (trust.Sequences{Timestamp: 2, Snapshot: 2, Targets: 2}) {
		t.Fatalf("live sequences %+v, want 2/2/2", live.Chain.Sequences)
	}
	if _, ok := live.Packages[built.Name]; !ok || len(live.Packages) != 2 {
		t.Fatalf("live targets %v, want both releases", slices.Sorted(maps.Keys(live.Packages)))
	}
}

func TestPullOfANeverPublishedChannelIsFreshAndWritesNothing(t *testing.T) {
	t.Parallel()
	w := newWorld(t)

	pulled, err := w.pullFrom(t, testsupport.NewBucket(), profileset.ChannelLab)

	if err != nil || !pulled.Fresh {
		t.Fatalf("pulled %+v, %v", pulled, err)
	}
	if _, err := w.repo.ReadMetadata(t.Context(), trust.RoleRoot); err == nil {
		t.Fatal("a fresh pull wrote root.json")
	}
}

func TestPullRefusesToDiscardUnpublishedSignedWork(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	w.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	w.publishAs(t, bucket, profileset.ChannelLab)
	if _, err := w.sign(t, trust.RoleTimestamp, app.SignRequest{}); err != nil {
		t.Fatal(err)
	}

	if _, err := w.pullFrom(t, bucket, profileset.ChannelLab); !errors.Is(err, app.ErrRepoNotEmpty) {
		t.Fatalf("err = %v, want ErrRepoNotEmpty", err)
	}
	if _, err := w.fresh().pullFrom(t, testsupport.NewBucket(), profileset.ChannelLab); err != nil {
		t.Fatalf("an empty repository and channel: %v", err)
	}
	if _, err := w.pullFrom(t, testsupport.NewBucket(), profileset.ChannelLab); !errors.Is(err, app.ErrNeverPublished) {
		t.Fatalf("a signed repository against an empty channel: err = %v, want ErrNeverPublished", err)
	}
}

func TestPullRefusesATamperedPublishedPackage_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	w := newWorld(t)
	signRoot(t, w)
	built := w.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	w.publishAs(t, bucket, profileset.ChannelLab)
	key, err := distribution.PackageKey("lab", built.Name, built.Target.SHA256)
	if err != nil {
		t.Fatal(err)
	}
	bucket.Objects[key] = append([]byte{0}, bucket.Objects[key]...)

	if _, err := w.fresh().pullFrom(t, bucket, profileset.ChannelLab); err == nil {
		t.Fatal("a tampered package was pulled")
	}
}

func TestPromoteStagesTheReviewedTargetsUnchanged_REQ_DIST_003_REQ_GOV_004(t *testing.T) {
	t.Parallel()
	dev := newWorld(t)
	signRoot(t, dev)
	built := dev.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	dev.publishAs(t, bucket, profileset.ChannelDev)
	lab := dev.fresh()
	signRoot(t, lab)

	staged, err := app.PromoteChannel{Source: lab.bucketChain(bucket), Packages: lab.repo, Stager: lab.repo}.Run(t.Context(),
		app.Promotion{From: profileset.ChannelDev, To: profileset.ChannelLab, Sequence: 1})
	if err != nil {
		t.Fatal(err)
	}
	for _, role := range []trust.RoleName{trust.RoleTargets, trust.RoleSnapshot, trust.RoleTimestamp} {
		if _, err := lab.sign(t, role, app.SignRequest{}); err != nil {
			t.Fatal(err)
		}
	}
	lab.publishAs(t, bucket, profileset.ChannelLab)

	if !slices.Equal(staged, []string{built.Name}) {
		t.Fatalf("staged %v", staged)
	}
	live, err := lab.bucketChain(bucket).Read(t.Context(), profileset.ChannelLab)
	if err != nil {
		t.Fatal(err)
	}
	if got := live.Chain.Targets.Targets[built.Name]; got.SHA256 != built.Target.SHA256 || got.Custom.EffectiveFrom != built.Target.Custom.EffectiveFrom {
		t.Fatalf("promoted target %+v, built %+v", got, built.Target)
	}
}

func TestPromoteRefusesAnUnreviewedSequenceOrASkippedChannel(t *testing.T) {
	t.Parallel()
	dev := newWorld(t)
	signRoot(t, dev)
	dev.publish(t, release("2026.10.1"))
	bucket := testsupport.NewBucket()
	dev.publishAs(t, bucket, profileset.ChannelDev)
	lab := dev.fresh()
	promote := app.PromoteChannel{Source: lab.bucketChain(bucket), Packages: lab.repo, Stager: lab.repo}

	tests := []struct {
		p    app.Promotion
		want error
	}{
		{app.Promotion{From: profileset.ChannelDev, To: profileset.ChannelLab, Sequence: 2}, app.ErrSequenceMismatch},
		{app.Promotion{From: profileset.ChannelDev, To: profileset.ChannelBeta, Sequence: 1}, distribution.ErrPromotion},
		{app.Promotion{From: profileset.ChannelLab, To: profileset.ChannelDev, Sequence: 1}, distribution.ErrPromotion},
		{app.Promotion{From: profileset.ChannelLab, To: profileset.ChannelBeta, Sequence: 1}, app.ErrNeverPublished},
	}
	for _, tc := range tests {
		if _, err := promote.Run(t.Context(), tc.p); !errors.Is(err, tc.want) {
			t.Errorf("%+v: err = %v, want %v", tc.p, err, tc.want)
		}
	}
	if staged, err := lab.repo.StagedTargets(t.Context()); err != nil || len(staged) != 0 {
		t.Fatalf("a refused promotion staged %v, %v", staged, err)
	}
}
