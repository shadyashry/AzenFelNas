package trust

import (
	"crypto/sha256"
	"encoding/hex"
	"fmt"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// Files are the four metadata files of one channel, as read.
type Files struct {
	Root, Timestamp, Snapshot, Targets []byte
}

// Sequences are per-role sequences. As the trusted state of a verifier, 0
// means "nothing trusted yet" and imposes no bound.
type Sequences struct {
	Timestamp, Snapshot, Targets int
}

// FreshnessWarning reports an expired role: the client keeps calculating
// and shows FRESHNESS_UNVERIFIED (REQ-PKG-002, Appendix J
// PKG_EXPIRED_WARNING); it is never a failure.
type FreshnessWarning struct {
	Role    RoleName
	Expires time.Time
}

// VerifiedChain is the outcome of a successful chain check.
type VerifiedChain struct {
	Root      tuf.Root
	Targets   tuf.Targets
	Sequences Sequences
	Warnings  []FreshnessWarning
}

// VerifyChain checks one channel's metadata bottom-up against anchor
// (Appendix C): root against the anchor's threshold, then timestamp,
// snapshot and targets against the root's roles, each file against the
// SHA-256 and sequence its parent pins, and each sequence strictly after
// the trusted one in after (REQ-DIST-001..004, REQ-PKG-005). Expiry before
// now yields a warning, never a failure (REQ-PKG-002).
func VerifyChain(files Files, anchor Anchor, after Sequences, now time.Time) (VerifiedChain, error) {
	root, err := verifyRoot(files.Root, anchor)
	if err != nil {
		return VerifiedChain{}, err
	}
	keys, err := RootKeys(root)
	if err != nil {
		return VerifiedChain{}, err
	}
	timestamp, _, err := verifyRole[tuf.Timestamp](RoleTimestamp, files.Timestamp, root, keys)
	if err != nil {
		return VerifiedChain{}, err
	}
	snapshot, snapshotEnv, err := verifyRole[tuf.Snapshot](RoleSnapshot, files.Snapshot, root, keys)
	if err != nil {
		return VerifiedChain{}, err
	}
	if err := checkPinned(RoleSnapshot, snapshotEnv, snapshot.Sequence, timestamp.Meta.SnapshotJSON); err != nil {
		return VerifiedChain{}, err
	}
	targets, targetsEnv, err := verifyRole[tuf.Targets](RoleTargets, files.Targets, root, keys)
	if err != nil {
		return VerifiedChain{}, err
	}
	if err := checkPinned(RoleTargets, targetsEnv, targets.Sequence, snapshot.Meta.TargetsJSON); err != nil {
		return VerifiedChain{}, err
	}
	seq := Sequences{Timestamp: timestamp.Sequence, Snapshot: snapshot.Sequence, Targets: targets.Sequence}
	if err := checkAfter(seq, after); err != nil {
		return VerifiedChain{}, err
	}
	warnings, err := freshness(now, []roleExpiry{
		{RoleRoot, root.Expires},
		{RoleTimestamp, timestamp.Expires},
		{RoleSnapshot, snapshot.Expires},
		{RoleTargets, targets.Expires},
	})
	if err != nil {
		return VerifiedChain{}, err
	}
	return VerifiedChain{Root: root, Targets: targets, Sequences: seq, Warnings: warnings}, nil
}

// VerifyTarget checks a package's bytes against its target entry
// (REQ-DIST-003).
func VerifyTarget(name string, target tuf.Target, data []byte) error {
	sum := sha256.Sum256(data)
	if int64(len(data)) != target.Length || hex.EncodeToString(sum[:]) != target.SHA256 {
		return fmt.Errorf("%w: %s", ErrHashMismatch, name)
	}
	return nil
}

func verifyRoot(file []byte, anchor Anchor) (tuf.Root, error) {
	env, err := ParseEnvelope(file)
	if err != nil {
		return tuf.Root{}, fmt.Errorf("root.json: %w", err)
	}
	root, ok := env.Metadata.Signed.Variant.(tuf.Root)
	if !ok {
		return tuf.Root{}, fmt.Errorf("%w: root.json holds a %T", ErrMalformed, env.Metadata.Signed.Variant)
	}
	if err := CheckRoot(root); err != nil {
		return tuf.Root{}, fmt.Errorf("root.json: %w", err)
	}
	ids := make([]string, 0, len(anchor.Keys))
	for _, k := range anchor.Keys {
		ids = append(ids, k.ID())
	}
	if err := env.VerifyThreshold("root (trusted anchor)", anchor.Keys, ids, anchor.Threshold); err != nil {
		return tuf.Root{}, fmt.Errorf("root.json: %w", err)
	}
	return root, nil
}

func verifyRole[V tuf.SignedVariant](name RoleName, file []byte, root tuf.Root, keys []PublicKey) (V, Envelope, error) {
	var zero V
	env, err := ParseEnvelope(file)
	if err != nil {
		return zero, Envelope{}, fmt.Errorf("%s: %w", name.FileName(), err)
	}
	doc, ok := env.Metadata.Signed.Variant.(V)
	if !ok {
		return zero, Envelope{}, fmt.Errorf("%w: %s holds a %T", ErrMalformed, name.FileName(), env.Metadata.Signed.Variant)
	}
	role := RoleOf(root, name)
	if err := env.VerifyThreshold(string(name), keys, role.KeyIDs, role.Threshold); err != nil {
		return zero, Envelope{}, fmt.Errorf("%s: %w", name.FileName(), err)
	}
	return doc, env, nil
}

func checkPinned(name RoleName, env Envelope, sequence int, pin tuf.MetaRef) error {
	if env.SHA256 != pin.SHA256 {
		return fmt.Errorf("%w: %s has SHA-256 %s, its parent pins %s", ErrHashMismatch, name.FileName(), env.SHA256, pin.SHA256)
	}
	if sequence != pin.Version {
		return fmt.Errorf("%w: %s has sequence %d, its parent pins %d", ErrHashMismatch, name.FileName(), sequence, pin.Version)
	}
	return nil
}

func checkAfter(got, trusted Sequences) error {
	for _, c := range []struct {
		name         RoleName
		got, trusted int
	}{
		{RoleTimestamp, got.Timestamp, trusted.Timestamp},
		{RoleSnapshot, got.Snapshot, trusted.Snapshot},
		{RoleTargets, got.Targets, trusted.Targets},
	} {
		if c.got < 1 {
			return fmt.Errorf("%w: %s sequence %d", ErrMalformed, c.name, c.got)
		}
		if c.trusted > 0 && c.got <= c.trusted {
			return fmt.Errorf("%w: %s sequence %d is not after the trusted %d", ErrSequenceRegression, c.name, c.got, c.trusted)
		}
	}
	return nil
}

type roleExpiry struct {
	role    RoleName
	expires string
}

func freshness(now time.Time, roles []roleExpiry) ([]FreshnessWarning, error) {
	var warnings []FreshnessWarning
	for _, r := range roles {
		expires, err := ParseExpires(r.expires)
		if err != nil {
			return nil, fmt.Errorf("%s: %w", r.role.FileName(), err)
		}
		if !now.Before(expires) {
			warnings = append(warnings, FreshnessWarning{Role: r.role, Expires: expires})
		}
	}
	return warnings, nil
}
