// Package ports declares the narrow interfaces the gsctl use cases
// (internal/app) consume; adapters (internal/adapters) implement them and
// main wires them (§17.1 I and D, §17.5). Every I/O method takes a
// context first.
package ports

import (
	"context"
	"errors"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// ErrNotFound is wrapped by an adapter when the item asked for does not
// exist (a role never signed, a key not provided).
var ErrNotFound = errors.New("not found")

// ProfileSource lists the profile documents to compile, as JSON.
type ProfileSource interface {
	LoadProfiles(ctx context.Context) ([]profileset.Document, error)
}

// MetadataReader reads a role's metadata file; ErrNotFound when the role
// was never signed.
type MetadataReader interface {
	ReadMetadata(ctx context.Context, role trust.RoleName) ([]byte, error)
}

// MetadataWriter replaces a role's metadata file atomically.
type MetadataWriter interface {
	WriteMetadata(ctx context.Context, role trust.RoleName, file []byte) error
}

// PackageReader reads a published package by target name and SHA-256.
type PackageReader interface {
	ReadPackage(ctx context.Context, target, sha256 string) ([]byte, error)
}

// PackageWriter stores a package under its content address (REQ-DIST-003).
// Storing the same bytes twice is a no-op.
type PackageWriter interface {
	WritePackage(ctx context.Context, target, sha256 string, container []byte) error
}

// TargetStager records a built target until the targets role is signed.
type TargetStager interface {
	StageTarget(ctx context.Context, name string, target tuf.Target) error
}

// StagedTargets lists and clears the staged targets.
type StagedTargets interface {
	StagedTargets(ctx context.Context) (map[string]tuf.Target, error)
	ClearStaged(ctx context.Context, names []string) error
}

// KeyConfigSource loads which public keys sign which role.
type KeyConfigSource interface {
	LoadKeyConfig(ctx context.Context) (trust.KeyConfig, error)
}

// KeyRing provides the signer of a named key; ErrNotFound when this
// environment does not hold that private key.
type KeyRing interface {
	Signer(ctx context.Context, name string) (trust.Signer, error)
}

// TrustAnchorSource loads the root keys a verifier already trusts.
type TrustAnchorSource interface {
	LoadTrustAnchor(ctx context.Context) (trust.Anchor, error)
}

// Clock reads the current time; injected so use cases stay deterministic
// under test.
type Clock interface {
	Now() time.Time
}
