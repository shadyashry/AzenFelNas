package app

import (
	"context"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// SignRoot builds root.json from the key config and signs it with the root
// keys this environment holds, at least the threshold (REQ-DIST-001). A
// rotation also needs the previous root's threshold (Appendix C); that
// ceremony is S27's, so S09 signs with the configured root keys only.
type SignRoot struct {
	Keys   ports.KeyConfigSource
	Ring   ports.KeyRing
	Reader ports.MetadataReader
	Writer ports.MetadataWriter
	Clock  ports.Clock
}

// Run signs and writes root.json.
func (u SignRoot) Run(ctx context.Context, req SignRequest) (SignedRole, error) {
	config, err := u.Keys.LoadKeyConfig(ctx)
	if err != nil {
		return SignedRole{}, fmt.Errorf("load key config: %w", err)
	}
	prev, found, err := previous[tuf.Root](ctx, u.Reader, trust.RoleRoot)
	if err != nil {
		return SignedRole{}, err
	}
	prevVersion := 0
	if found {
		prevVersion = prev.Version
	}
	version, err := trust.NextSequence(prevVersion, req.Sequence)
	if err != nil {
		return SignedRole{}, err
	}
	now := u.Clock.Now()
	expires, err := req.expires(trust.RoleRoot, now)
	if err != nil {
		return SignedRole{}, err
	}
	root, err := trust.NewRoot(version, expires, config)
	if err != nil {
		return SignedRole{}, err
	}
	signers, err := signersFor(ctx, u.Ring, trust.RoleRoot, config.Roles[trust.RoleRoot])
	if err != nil {
		return SignedRole{}, err
	}
	env, err := write(ctx, u.Writer, trust.RoleRoot, root, signers)
	if err != nil {
		return SignedRole{}, err
	}
	return SignedRole{Role: trust.RoleRoot, Sequence: version, Expires: root.Expires, Signatures: len(env.Metadata.Signatures)}, nil
}
