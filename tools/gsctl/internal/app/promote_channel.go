package app

import (
	"context"
	"errors"
	"fmt"
	"maps"
	"slices"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// ErrSequenceMismatch is returned by PromoteChannel when the source
// channel's targets sequence is not the one the release manager reviewed.
var ErrSequenceMismatch = errors.New("source targets sequence differs from the reviewed one")

// PromoteChannel stages the exact targets of a published channel into the
// repository of the channel above it (§9.2 `gsctl promote --from --to
// --sequence N`). The source is verified as a client would; its targets
// sequence must equal the reviewed one, so nothing published after the
// review is promoted. Each target keeps its bytes, hash and custom fields
// (one effectiveFrom for all users, REQ-GOV-004); the packages are written
// under the same content address (REQ-DIST-003). Signing and publishing the
// destination are the usual sign and publish steps.
type PromoteChannel struct {
	Source   BucketChain
	Packages ports.PackageWriter
	Stager   ports.TargetStager
}

// Promotion names a promotion and the reviewed source targets sequence.
type Promotion struct {
	From, To profileset.Channel
	Sequence int
}

// Run stages the promotion and returns the staged target names.
func (u PromoteChannel) Run(ctx context.Context, p Promotion) ([]string, error) {
	if err := distribution.CheckPromotion(p.From, p.To); err != nil {
		return nil, err
	}
	published, err := u.Source.Read(ctx, p.From)
	if err != nil {
		return nil, err
	}
	if got := published.Chain.Sequences.Targets; got != p.Sequence {
		return nil, fmt.Errorf("%w: %s targets is sequence %d, reviewed %d", ErrSequenceMismatch, p.From, got, p.Sequence)
	}
	names := slices.Sorted(maps.Keys(published.Packages))
	for _, name := range names {
		target := published.Chain.Targets.Targets[name]
		if err := u.Packages.WritePackage(ctx, name, target.SHA256, published.Packages[name]); err != nil {
			return nil, fmt.Errorf("write %s: %w", name, err)
		}
		if err := u.Stager.StageTarget(ctx, name, target); err != nil {
			return nil, fmt.Errorf("stage %s: %w", name, err)
		}
	}
	return names, nil
}
