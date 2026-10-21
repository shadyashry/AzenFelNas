package app

import (
	"context"
	"errors"
	"fmt"
	"slices"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// SignRequest is shared by the four signing use cases.
type SignRequest struct {
	// Sequence to sign (the version, for root); 0 means previous + 1. A
	// value not after the previous one is refused (REQ-DIST-002).
	Sequence int
	// Lifetime until expiry; 0 means the role's default (§15 D59).
	Lifetime time.Duration
}

// SignedRole describes a metadata file just written.
type SignedRole struct {
	Role       trust.RoleName
	Sequence   int
	Expires    string
	Signatures int
}

func (r SignRequest) expires(role trust.RoleName, now time.Time) (time.Time, error) {
	lifetime := r.Lifetime
	if lifetime == 0 {
		lifetime = role.DefaultLifetime()
	}
	if lifetime < time.Second {
		return time.Time{}, fmt.Errorf("lifetime %s is too short", lifetime)
	}
	return now.Add(lifetime), nil
}

// signersFor returns a signer for every key of the role that the key ring
// holds. Each private key must match its configured public key; fewer
// signers than the threshold is trust.ErrInsufficientKeys.
func signersFor(ctx context.Context, ring ports.KeyRing, role trust.RoleName, keys trust.RoleKeys) ([]trust.Signer, error) {
	var signers []trust.Signer
	for _, k := range keys.Keys {
		s, err := ring.Signer(ctx, k.Name)
		if errors.Is(err, ports.ErrNotFound) {
			continue
		}
		if err != nil {
			return nil, fmt.Errorf("load key %s: %w", k.Name, err)
		}
		if !s.PublicKey().Equal(k.Key) {
			return nil, fmt.Errorf("%w: private key %s does not match its public key %s", trust.ErrKeyMismatch, k.Name, k.Key.ID())
		}
		signers = append(signers, s)
	}
	if len(signers) < keys.Threshold {
		return nil, fmt.Errorf("%w: %s has %d of %d required key(s) available", trust.ErrInsufficientKeys, role, len(signers), keys.Threshold)
	}
	return signers, nil
}

// roleKeys returns the configured keys of role.
func roleKeys(ctx context.Context, source ports.KeyConfigSource, role trust.RoleName) (trust.RoleKeys, error) {
	config, err := source.LoadKeyConfig(ctx)
	if err != nil {
		return trust.RoleKeys{}, fmt.Errorf("load key config: %w", err)
	}
	keys, ok := config.Roles[role]
	if !ok {
		return trust.RoleKeys{}, fmt.Errorf("%w: key config has no %s role", trust.ErrMalformed, role)
	}
	return keys, nil
}

// signedRoleKeys returns the configured keys of a non-root role after
// checking they are exactly the keys the signed root names for it, so a
// configuration change cannot sign what clients would reject.
func signedRoleKeys(ctx context.Context, source ports.KeyConfigSource, reader ports.MetadataReader, role trust.RoleName) (trust.RoleKeys, error) {
	keys, err := roleKeys(ctx, source, role)
	if err != nil {
		return trust.RoleKeys{}, err
	}
	rootEnv, err := readEnvelope(ctx, reader, trust.RoleRoot)
	if errors.Is(err, ports.ErrNotFound) {
		return trust.RoleKeys{}, fmt.Errorf("sign the root role before %s: %w", role, err)
	}
	if err != nil {
		return trust.RoleKeys{}, err
	}
	root, ok := rootEnv.Metadata.Signed.Variant.(tuf.Root)
	if !ok {
		return trust.RoleKeys{}, fmt.Errorf("%w: root.json holds a %T", trust.ErrMalformed, rootEnv.Metadata.Signed.Variant)
	}
	signedRole := trust.RoleOf(root, role)
	ids := make([]string, 0, len(keys.Keys))
	for _, k := range keys.Keys {
		ids = append(ids, k.Key.ID())
	}
	slices.Sort(ids)
	if !slices.Equal(ids, slices.Sorted(slices.Values(signedRole.KeyIDs))) || keys.Threshold != signedRole.Threshold {
		return trust.RoleKeys{}, fmt.Errorf("%w: the %s keys in the key config differ from the signed root; re-sign root first", trust.ErrKeyMismatch, role)
	}
	return keys, nil
}

// readEnvelope reads and decodes a role's file (signatures unchecked: the
// signer's own repository). ErrNotFound passes through.
func readEnvelope(ctx context.Context, reader ports.MetadataReader, role trust.RoleName) (trust.Envelope, error) {
	file, err := reader.ReadMetadata(ctx, role)
	if err != nil {
		return trust.Envelope{}, fmt.Errorf("read %s: %w", role.FileName(), err)
	}
	env, err := trust.ParseEnvelope(file)
	if err != nil {
		return trust.Envelope{}, fmt.Errorf("%s: %w", role.FileName(), err)
	}
	return env, nil
}

// previous returns the role's current document, or ok false when the role
// was never signed.
func previous[V tuf.SignedVariant](ctx context.Context, reader ports.MetadataReader, role trust.RoleName) (V, bool, error) {
	var zero V
	env, err := readEnvelope(ctx, reader, role)
	if errors.Is(err, ports.ErrNotFound) {
		return zero, false, nil
	}
	if err != nil {
		return zero, false, err
	}
	doc, ok := env.Metadata.Signed.Variant.(V)
	if !ok {
		return zero, false, fmt.Errorf("%w: %s holds a %T", trust.ErrMalformed, role.FileName(), env.Metadata.Signed.Variant)
	}
	return doc, true, nil
}

// write signs doc and writes the role's file.
func write(ctx context.Context, writer ports.MetadataWriter, role trust.RoleName, doc tuf.SignedVariant, signers []trust.Signer) (trust.Envelope, error) {
	m, err := trust.Sign(tuf.Signed{Variant: doc}, signers)
	if err != nil {
		return trust.Envelope{}, err
	}
	file, err := trust.EncodeFile(m)
	if err != nil {
		return trust.Envelope{}, err
	}
	if err := writer.WriteMetadata(ctx, role, file); err != nil {
		return trust.Envelope{}, fmt.Errorf("write %s: %w", role.FileName(), err)
	}
	return trust.ParseEnvelope(file)
}
