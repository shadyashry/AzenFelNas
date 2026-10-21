package app

import (
	"context"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// SignTimestamp pins the current snapshot.json in a new timestamp.json,
// valid for at most 7 days (§9.1).
type SignTimestamp struct {
	Keys   ports.KeyConfigSource
	Ring   ports.KeyRing
	Reader ports.MetadataReader
	Writer ports.MetadataWriter
	Clock  ports.Clock
}

// Run signs and writes timestamp.json.
func (u SignTimestamp) Run(ctx context.Context, req SignRequest) (SignedRole, error) {
	keys, err := signedRoleKeys(ctx, u.Keys, u.Reader, trust.RoleTimestamp)
	if err != nil {
		return SignedRole{}, err
	}
	snapshotFile, err := readEnvelope(ctx, u.Reader, trust.RoleSnapshot)
	if err != nil {
		return SignedRole{}, err
	}
	prev, _, err := previous[tuf.Timestamp](ctx, u.Reader, trust.RoleTimestamp)
	if err != nil {
		return SignedRole{}, err
	}
	sequence, err := trust.NextSequence(prev.Sequence, req.Sequence)
	if err != nil {
		return SignedRole{}, err
	}
	now := u.Clock.Now()
	expires, err := req.expires(trust.RoleTimestamp, now)
	if err != nil {
		return SignedRole{}, err
	}
	doc, err := trust.NewTimestamp(sequence, now, expires, snapshotFile)
	if err != nil {
		return SignedRole{}, err
	}
	signers, err := signersFor(ctx, u.Ring, trust.RoleTimestamp, keys)
	if err != nil {
		return SignedRole{}, err
	}
	env, err := write(ctx, u.Writer, trust.RoleTimestamp, doc, signers)
	if err != nil {
		return SignedRole{}, err
	}
	return SignedRole{Role: trust.RoleTimestamp, Sequence: sequence, Expires: doc.Expires, Signatures: len(env.Metadata.Signatures)}, nil
}
