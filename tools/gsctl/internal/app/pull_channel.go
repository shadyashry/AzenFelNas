package app

import (
	"context"
	"errors"
	"fmt"
	"maps"
	"slices"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// ErrRepoNotEmpty is returned by PullChannel when the repository already
// holds metadata that differs from the published channel: pulling would
// discard signed work that was never published.
var ErrRepoNotEmpty = errors.New("repository holds other metadata than the published channel")

// ErrNeverPublished is returned by BucketChain when the channel has no
// published root.json.
var ErrNeverPublished = errors.New("channel was never published")

// BucketChain reads a published channel from the bucket and verifies it as
// a client would (Appendix C): the metadata chain against the trust anchor
// and every target's bytes. A channel without root.json is
// ErrNeverPublished; a missing file of a published one is ErrNotFound.
type BucketChain struct {
	Anchor ports.TrustAnchorSource
	Store  ports.ObjectStore
	Clock  ports.Clock
}

// PublishedChannel is a verified published channel: its metadata files and
// the package bytes of every target.
type PublishedChannel struct {
	Chain    trust.VerifiedChain
	Files    map[trust.RoleName][]byte
	Packages map[string][]byte
}

// Read verifies the published channel.
func (u BucketChain) Read(ctx context.Context, channel profileset.Channel) (PublishedChannel, error) {
	anchor, err := u.Anchor.LoadTrustAnchor(ctx)
	if err != nil {
		return PublishedChannel{}, fmt.Errorf("load trust anchor: %w", err)
	}
	out := PublishedChannel{Files: map[trust.RoleName][]byte{}, Packages: map[string][]byte{}}
	for _, role := range distribution.PublishOrder() {
		data, err := u.Store.GetObject(ctx, distribution.MetadataKey(string(channel), role))
		if role == trust.RoleRoot && errors.Is(err, ports.ErrNotFound) {
			return PublishedChannel{}, fmt.Errorf("%w: %s", ErrNeverPublished, channel)
		}
		if err != nil {
			return PublishedChannel{}, fmt.Errorf("read published %s/%s: %w", channel, role.FileName(), err)
		}
		out.Files[role] = data
	}
	files := trust.Files{
		Root: out.Files[trust.RoleRoot], Targets: out.Files[trust.RoleTargets],
		Snapshot: out.Files[trust.RoleSnapshot], Timestamp: out.Files[trust.RoleTimestamp],
	}
	if out.Chain, err = trust.VerifyChain(files, anchor, trust.Sequences{}, u.Clock.Now()); err != nil {
		return PublishedChannel{}, fmt.Errorf("published %s: %w", channel, err)
	}
	for _, name := range slices.Sorted(maps.Keys(out.Chain.Targets.Targets)) {
		target := out.Chain.Targets.Targets[name]
		key, err := distribution.PackageKey(string(channel), name, target.SHA256)
		if err != nil {
			return PublishedChannel{}, err
		}
		data, err := u.Store.GetObject(ctx, key)
		if err != nil {
			return PublishedChannel{}, fmt.Errorf("read published %s: %w", key, err)
		}
		if err := trust.VerifyTarget(name, target, data); err != nil {
			return PublishedChannel{}, err
		}
		out.Packages[name] = data
	}
	return out, nil
}

// PullChannel restores a channel repository from the bucket (§15 D85), so
// that the next release signs strictly higher sequences than the live
// channel (REQ-DIST-002) even on a fresh CI runner. The published channel
// is verified first; packages are written before metadata.
type PullChannel struct {
	Published BucketChain
	Reader    ports.MetadataReader
	Writer    ports.MetadataWriter
	Packages  ports.PackageWriter
}

// Pulled reports what a pull restored; Fresh means the channel was never
// published, so nothing was written and the first release starts at 1.
type Pulled struct {
	Fresh     bool
	Sequences trust.Sequences
	Targets   int
}

// Run pulls channel into the repository.
func (u PullChannel) Run(ctx context.Context, channel profileset.Channel) (Pulled, error) {
	published, err := u.Published.Read(ctx, channel)
	switch {
	case errors.Is(err, ErrNeverPublished) && !u.anyLocal(ctx):
		return Pulled{Fresh: true}, nil
	case err != nil:
		return Pulled{}, err
	}
	for _, role := range distribution.PublishOrder() {
		local, err := u.Reader.ReadMetadata(ctx, role)
		switch {
		case errors.Is(err, ports.ErrNotFound):
		case err != nil:
			return Pulled{}, fmt.Errorf("read %s: %w", role.FileName(), err)
		case string(local) != string(published.Files[role]):
			return Pulled{}, fmt.Errorf("%w: %s", ErrRepoNotEmpty, role.FileName())
		}
	}
	for name, data := range published.Packages {
		if err := u.Packages.WritePackage(ctx, name, published.Chain.Targets.Targets[name].SHA256, data); err != nil {
			return Pulled{}, fmt.Errorf("write %s: %w", name, err)
		}
	}
	for _, role := range distribution.PublishOrder() {
		if err := u.Writer.WriteMetadata(ctx, role, published.Files[role]); err != nil {
			return Pulled{}, fmt.Errorf("write %s: %w", role.FileName(), err)
		}
	}
	return Pulled{Sequences: published.Chain.Sequences, Targets: len(published.Packages)}, nil
}

// anyLocal reports whether the repository holds any metadata; a channel
// that is absent from the bucket must not hide a repository that is not.
func (u PullChannel) anyLocal(ctx context.Context) bool {
	for _, role := range distribution.PublishOrder() {
		if _, err := u.Reader.ReadMetadata(ctx, role); !errors.Is(err, ports.ErrNotFound) {
			return true
		}
	}
	return false
}
