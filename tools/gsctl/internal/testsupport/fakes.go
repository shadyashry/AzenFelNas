package testsupport

import (
	"context"
	"fmt"
	"maps"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// MemRepo is an in-memory channel repository implementing the metadata,
// package and staging ports with the fsrepo contract. Not safe for
// concurrent use.
type MemRepo struct {
	Metadata map[trust.RoleName][]byte
	Packages map[string][]byte // "<target>@<sha256>"
	Staged   map[string]tuf.Target
}

// NewMemRepo returns an empty repository.
func NewMemRepo() *MemRepo {
	return &MemRepo{Metadata: map[trust.RoleName][]byte{}, Packages: map[string][]byte{}, Staged: map[string]tuf.Target{}}
}

// ReadMetadata implements ports.MetadataReader.
func (m *MemRepo) ReadMetadata(_ context.Context, role trust.RoleName) ([]byte, error) {
	data, ok := m.Metadata[role]
	if !ok {
		return nil, fmt.Errorf("%s: %w", role.FileName(), ports.ErrNotFound)
	}
	return append([]byte(nil), data...), nil
}

// WriteMetadata implements ports.MetadataWriter.
func (m *MemRepo) WriteMetadata(_ context.Context, role trust.RoleName, file []byte) error {
	m.Metadata[role] = append([]byte(nil), file...)
	return nil
}

// ReadPackage implements ports.PackageReader.
func (m *MemRepo) ReadPackage(_ context.Context, target, sha256 string) ([]byte, error) {
	data, ok := m.Packages[target+"@"+sha256]
	if !ok {
		return nil, fmt.Errorf("%s: %w", target, ports.ErrNotFound)
	}
	return append([]byte(nil), data...), nil
}

// WritePackage implements ports.PackageWriter.
func (m *MemRepo) WritePackage(_ context.Context, target, sha256 string, container []byte) error {
	m.Packages[target+"@"+sha256] = append([]byte(nil), container...)
	return nil
}

// StageTarget implements ports.TargetStager.
func (m *MemRepo) StageTarget(_ context.Context, name string, target tuf.Target) error {
	m.Staged[name] = target
	return nil
}

// StagedTargets implements ports.StagedTargets.
func (m *MemRepo) StagedTargets(context.Context) (map[string]tuf.Target, error) {
	return maps.Clone(m.Staged), nil
}

// ClearStaged implements ports.StagedTargets.
func (m *MemRepo) ClearStaged(_ context.Context, names []string) error {
	for _, n := range names {
		delete(m.Staged, n)
	}
	return nil
}

// Clock is a fixed ports.Clock.
type Clock struct{ T time.Time }

// Now implements ports.Clock.
func (c Clock) Now() time.Time { return c.T }

// KeyConfig is a fixed ports.KeyConfigSource.
type KeyConfig struct{ Config trust.KeyConfig }

// LoadKeyConfig implements ports.KeyConfigSource.
func (k KeyConfig) LoadKeyConfig(context.Context) (trust.KeyConfig, error) { return k.Config, nil }

// Ring is a ports.KeyRing over the signers it holds.
type Ring struct{ Signers map[string]trust.Signer }

// Signer implements ports.KeyRing.
func (r Ring) Signer(_ context.Context, name string) (trust.Signer, error) {
	s, ok := r.Signers[name]
	if !ok {
		return nil, fmt.Errorf("key %s: %w", name, ports.ErrNotFound)
	}
	return s, nil
}

// Anchor is a fixed ports.TrustAnchorSource.
type Anchor struct{ Anchor trust.Anchor }

// LoadTrustAnchor implements ports.TrustAnchorSource.
func (a Anchor) LoadTrustAnchor(context.Context) (trust.Anchor, error) { return a.Anchor, nil }

// Profiles is a fixed ports.ProfileSource.
type Profiles struct{ Docs []profileset.Document }

// LoadProfiles implements ports.ProfileSource.
func (p Profiles) LoadProfiles(context.Context) ([]profileset.Document, error) { return p.Docs, nil }
