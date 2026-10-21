package app

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"maps"
	"slices"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/dmpkg"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/jcs"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/profile"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// VerifyRepository checks a channel as a client would (Appendix C): the
// metadata chain against the trusted root keys and sequences, then every
// target's bytes and, for the package types gsctl builds, the payload.
type VerifyRepository struct {
	Anchor   ports.TrustAnchorSource
	Reader   ports.MetadataReader
	Packages ports.PackageReader
	Clock    ports.Clock
}

// Verified is the outcome of a successful verification.
type Verified struct {
	Chain   trust.VerifiedChain
	Targets []string
}

// Run verifies the channel; after holds the sequences already trusted (0:
// none), which every role must exceed (REQ-PKG-005).
func (u VerifyRepository) Run(ctx context.Context, after trust.Sequences) (Verified, error) {
	anchor, err := u.Anchor.LoadTrustAnchor(ctx)
	if err != nil {
		return Verified{}, fmt.Errorf("load trust anchor: %w", err)
	}
	var files trust.Files
	for _, f := range []struct {
		role trust.RoleName
		dst  *[]byte
	}{
		{trust.RoleRoot, &files.Root},
		{trust.RoleTimestamp, &files.Timestamp},
		{trust.RoleSnapshot, &files.Snapshot},
		{trust.RoleTargets, &files.Targets},
	} {
		if *f.dst, err = u.Reader.ReadMetadata(ctx, f.role); err != nil {
			return Verified{}, fmt.Errorf("read %s: %w", f.role.FileName(), err)
		}
	}
	chain, err := trust.VerifyChain(files, anchor, after, u.Clock.Now())
	if err != nil {
		return Verified{}, err
	}
	names := slices.Sorted(maps.Keys(chain.Targets.Targets))
	for _, name := range names {
		if err := u.verifyTarget(ctx, name, chain.Targets.Targets[name]); err != nil {
			return Verified{}, err
		}
	}
	return Verified{Chain: chain, Targets: names}, nil
}

func (u VerifyRepository) verifyTarget(ctx context.Context, name string, target tuf.Target) error {
	container, err := u.Packages.ReadPackage(ctx, name, target.SHA256)
	if err != nil {
		return fmt.Errorf("read %s: %w", name, err)
	}
	if err := trust.VerifyTarget(name, target, container); err != nil {
		return err
	}
	if !strings.HasPrefix(name, profileset.PackageType+"/") {
		return nil // a package type gsctl does not build yet: bytes only
	}
	return verifyProfilesPayload(name, target, container)
}

// verifyProfilesPayload checks a prayer_profiles payload against §15 D60:
// profiles.json, JCS-canonical, an array of prayer_profile.v1 documents.
func verifyProfilesPayload(name string, target tuf.Target, container []byte) error {
	fileName, payload, err := dmpkg.Unpack(container)
	if err != nil {
		return fmt.Errorf("%w: %s: %w", trust.ErrMalformed, name, err)
	}
	if fileName != profileset.PayloadFileName || target.Custom.PayloadFormat != tuf.PayloadJSON ||
		target.Custom.SchemaVersion != profileset.PayloadSchemaVersion {
		return fmt.Errorf("%w: %s holds %q schema %d", trust.ErrMalformed, name, fileName, target.Custom.SchemaVersion)
	}
	canonical, err := jcs.Canonicalize(payload)
	if err != nil || !bytes.Equal(canonical, payload) {
		return fmt.Errorf("%w: %s payload is not canonical JSON", trust.ErrMalformed, name)
	}
	var profiles []profile.PrayerProfile
	if err := json.Unmarshal(payload, &profiles); err != nil {
		return fmt.Errorf("%w: %s payload: %w", trust.ErrMalformed, name, err)
	}
	if len(profiles) == 0 {
		return fmt.Errorf("%w: %s payload has no profile", trust.ErrMalformed, name)
	}
	return nil
}
