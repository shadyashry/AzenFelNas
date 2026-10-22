package app

import (
	"bytes"
	"context"
	"errors"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// PublishChannel copies a signed channel repository into the distribution
// bucket (§9.1, ADR-009). It first verifies the repository as a client
// would; then it uploads every package not yet in the bucket, refusing one
// whose key holds other bytes (REQ-DIST-003), and finally the metadata
// files that changed, each strictly newer than the published one
// (REQ-DIST-002), in distribution.PublishOrder, with the §9.1 cache policy
// (REQ-DIST-005).
type PublishChannel struct {
	Verify   VerifyRepository
	Reader   ports.MetadataReader
	Packages ports.PackageReader
	Store    ports.ObjectStore
}

// Published reports what a publish wrote.
type Published struct {
	Packages []string
	Roles    []trust.RoleName
}

// Run publishes the repository as channel.
func (u PublishChannel) Run(ctx context.Context, channel profileset.Channel) (Published, error) {
	verified, err := u.Verify.Run(ctx, trust.Sequences{})
	if err != nil {
		return Published{}, fmt.Errorf("verify before publishing: %w", err)
	}
	local, published := map[trust.RoleName][]byte{}, map[trust.RoleName][]byte{}
	for _, role := range distribution.PublishOrder() {
		if local[role], err = u.Reader.ReadMetadata(ctx, role); err != nil {
			return Published{}, fmt.Errorf("read %s: %w", role.FileName(), err)
		}
		remote, err := u.Store.GetObject(ctx, distribution.MetadataKey(string(channel), role))
		switch {
		case err == nil:
			published[role] = remote
		case !errors.Is(err, ports.ErrNotFound):
			return Published{}, fmt.Errorf("read published %s: %w", role.FileName(), err)
		}
	}
	roles, err := distribution.PlanMetadata(local, published)
	if err != nil {
		return Published{}, err
	}
	var out Published
	for _, name := range verified.Targets {
		uploaded, err := u.publishPackage(ctx, channel, name, verified.Chain.Targets.Targets[name].SHA256)
		if err != nil {
			return Published{}, err
		}
		if uploaded {
			out.Packages = append(out.Packages, name)
		}
	}
	for _, role := range roles {
		if err := u.Store.PutObject(ctx, distribution.MetadataKey(string(channel), role), local[role], distribution.CacheControl(role)); err != nil {
			return Published{}, fmt.Errorf("upload %s: %w", role.FileName(), err)
		}
	}
	out.Roles = roles
	return out, nil
}

// publishPackage uploads one package unless the bucket already holds it.
func (u PublishChannel) publishPackage(ctx context.Context, channel profileset.Channel, name, sha256 string) (bool, error) {
	key, err := distribution.PackageKey(string(channel), name, sha256)
	if err != nil {
		return false, err
	}
	data, err := u.Packages.ReadPackage(ctx, name, sha256)
	if err != nil {
		return false, fmt.Errorf("read %s: %w", name, err)
	}
	existing, err := u.Store.GetObject(ctx, key)
	switch {
	case err == nil && bytes.Equal(existing, data):
		return false, nil
	case err == nil:
		return false, fmt.Errorf("%w: %s holds other bytes", trust.ErrImmutableTarget, key)
	case !errors.Is(err, ports.ErrNotFound):
		return false, fmt.Errorf("read published %s: %w", key, err)
	}
	if err := u.Store.PutObject(ctx, key, data, distribution.CachePackage); err != nil {
		return false, fmt.Errorf("upload %s: %w", key, err)
	}
	return true, nil
}
