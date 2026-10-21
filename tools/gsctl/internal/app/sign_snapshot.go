package app

import (
	"context"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// SignSnapshot pins the current targets.json in a new snapshot.json.
type SignSnapshot struct {
	Keys   ports.KeyConfigSource
	Ring   ports.KeyRing
	Reader ports.MetadataReader
	Writer ports.MetadataWriter
	Clock  ports.Clock
}

// Run signs and writes snapshot.json.
func (u SignSnapshot) Run(ctx context.Context, req SignRequest) (SignedRole, error) {
	keys, err := signedRoleKeys(ctx, u.Keys, u.Reader, trust.RoleSnapshot)
	if err != nil {
		return SignedRole{}, err
	}
	targetsFile, err := readEnvelope(ctx, u.Reader, trust.RoleTargets)
	if err != nil {
		return SignedRole{}, err
	}
	prev, _, err := previous[tuf.Snapshot](ctx, u.Reader, trust.RoleSnapshot)
	if err != nil {
		return SignedRole{}, err
	}
	sequence, err := trust.NextSequence(prev.Sequence, req.Sequence)
	if err != nil {
		return SignedRole{}, err
	}
	expires, err := req.expires(trust.RoleSnapshot, u.Clock.Now())
	if err != nil {
		return SignedRole{}, err
	}
	doc, err := trust.NewSnapshot(sequence, expires, targetsFile)
	if err != nil {
		return SignedRole{}, err
	}
	signers, err := signersFor(ctx, u.Ring, trust.RoleSnapshot, keys)
	if err != nil {
		return SignedRole{}, err
	}
	env, err := write(ctx, u.Writer, trust.RoleSnapshot, doc, signers)
	if err != nil {
		return SignedRole{}, err
	}
	return SignedRole{Role: trust.RoleSnapshot, Sequence: sequence, Expires: doc.Expires, Signatures: len(env.Metadata.Signatures)}, nil
}
