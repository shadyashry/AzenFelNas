package app

import (
	"context"
	"fmt"
	"maps"
	"slices"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// SignTargets adds the staged targets to targets.json under a new sequence
// and signs it (REQ-DIST-002, REQ-DIST-003). Published targets are kept;
// a published name never changes content.
type SignTargets struct {
	Keys   ports.KeyConfigSource
	Ring   ports.KeyRing
	Reader ports.MetadataReader
	Writer ports.MetadataWriter
	Staged ports.StagedTargets
	Clock  ports.Clock
}

// Run signs and writes targets.json, then clears the staged targets.
func (u SignTargets) Run(ctx context.Context, req SignRequest) (SignedRole, error) {
	keys, err := signedRoleKeys(ctx, u.Keys, u.Reader, trust.RoleTargets)
	if err != nil {
		return SignedRole{}, err
	}
	prev, found, err := previous[tuf.Targets](ctx, u.Reader, trust.RoleTargets)
	if err != nil {
		return SignedRole{}, err
	}
	var prevDoc *tuf.Targets
	if found {
		prevDoc = &prev
	}
	sequence, err := trust.NextSequence(prev.Sequence, req.Sequence)
	if err != nil {
		return SignedRole{}, err
	}
	staged, err := u.Staged.StagedTargets(ctx)
	if err != nil {
		return SignedRole{}, fmt.Errorf("read staged targets: %w", err)
	}
	expires, err := req.expires(trust.RoleTargets, u.Clock.Now())
	if err != nil {
		return SignedRole{}, err
	}
	doc, err := trust.NextTargets(prevDoc, staged, sequence, expires)
	if err != nil {
		return SignedRole{}, err
	}
	signers, err := signersFor(ctx, u.Ring, trust.RoleTargets, keys)
	if err != nil {
		return SignedRole{}, err
	}
	env, err := write(ctx, u.Writer, trust.RoleTargets, doc, signers)
	if err != nil {
		return SignedRole{}, err
	}
	if err := u.Staged.ClearStaged(ctx, slices.Sorted(maps.Keys(staged))); err != nil {
		return SignedRole{}, fmt.Errorf("clear staged targets: %w", err)
	}
	return SignedRole{Role: trust.RoleTargets, Sequence: sequence, Expires: doc.Expires, Signatures: len(env.Metadata.Signatures)}, nil
}
