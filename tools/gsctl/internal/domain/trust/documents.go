package trust

import (
	"fmt"
	"maps"
	"slices"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// Appendix C thresholds (REQ-DIST-001): three root keys with threshold 2;
// threshold 1 for every other role.
const (
	rootKeyCount  = 3
	rootThreshold = 2
)

// NextSequence returns the sequence to sign after previous (0 when the role
// was never signed). requested 0 means previous + 1; anything not strictly
// greater than previous is ErrSequenceRegression (REQ-DIST-002).
func NextSequence(previous, requested int) (int, error) {
	if requested == 0 {
		return previous + 1, nil
	}
	if requested <= previous {
		return 0, fmt.Errorf("%w: requested %d, previous %d", ErrSequenceRegression, requested, previous)
	}
	return requested, nil
}

// NewRoot builds a root document from config (REQ-DIST-001).
func NewRoot(version int, expires time.Time, config KeyConfig) (tuf.Root, error) {
	root := tuf.Root{Version: version, Expires: FormatExpires(expires), Keys: map[string]tuf.Key{}}
	roles := map[RoleName]*tuf.Role{
		RoleRoot: &root.Roles.Root, RoleTargets: &root.Roles.Targets,
		RoleSnapshot: &root.Roles.Snapshot, RoleTimestamp: &root.Roles.Timestamp,
	}
	for _, name := range Roles() {
		rk, ok := config.Roles[name]
		if !ok {
			return tuf.Root{}, fmt.Errorf("%w: key config has no %s role", ErrMalformed, name)
		}
		ids := make([]string, 0, len(rk.Keys))
		for _, k := range rk.Keys {
			root.Keys[k.Key.ID()] = tuf.Key{Scheme: tuf.KeySchemeEd25519, Public: k.Key.Hex()}
			ids = append(ids, k.Key.ID())
		}
		slices.Sort(ids)
		*roles[name] = tuf.Role{KeyIDs: ids, Threshold: rk.Threshold}
	}
	if err := CheckRoot(root); err != nil {
		return tuf.Root{}, err
	}
	return root, nil
}

// CheckRoot enforces the structural rules of a root document: the
// Appendix C thresholds, distinct key ids, every role key listed in keys,
// and every key's id derived from its public bytes (§15 D17).
func CheckRoot(root tuf.Root) error {
	if root.Version < 1 {
		return fmt.Errorf("%w: root version %d", ErrMalformed, root.Version)
	}
	for id, k := range root.Keys {
		pub, err := ParsePublicKeyHex(k.Public)
		if err != nil {
			return err
		}
		if pub.ID() != id {
			return fmt.Errorf("%w: key %s is listed under keyId %s", ErrMalformed, pub.ID(), id)
		}
	}
	for _, name := range Roles() {
		role := RoleOf(root, name)
		wantThreshold, wantKeys := 1, 0
		if name == RoleRoot {
			wantThreshold, wantKeys = rootThreshold, rootKeyCount
		}
		if role.Threshold != wantThreshold || (wantKeys > 0 && len(role.KeyIDs) != wantKeys) || len(role.KeyIDs) < role.Threshold {
			return fmt.Errorf("%w: %s role has %d key(s) with threshold %d (Appendix C)", ErrMalformed, name, len(role.KeyIDs), role.Threshold)
		}
		seen := map[string]bool{}
		for _, id := range role.KeyIDs {
			if seen[id] {
				return fmt.Errorf("%w: %s role lists key %s twice", ErrMalformed, name, id)
			}
			seen[id] = true
			if _, ok := root.Keys[id]; !ok {
				return fmt.Errorf("%w: %s role key %s is not in root keys", ErrMalformed, name, id)
			}
		}
	}
	return nil
}

// RoleOf returns the role entry of name in root.
func RoleOf(root tuf.Root, name RoleName) tuf.Role {
	switch name {
	case RoleRoot:
		return root.Roles.Root
	case RoleTargets:
		return root.Roles.Targets
	case RoleSnapshot:
		return root.Roles.Snapshot
	case RoleTimestamp:
		return root.Roles.Timestamp
	default:
		return tuf.Role{}
	}
}

// RootKeys returns the public keys a root document lists.
func RootKeys(root tuf.Root) ([]PublicKey, error) {
	keys := make([]PublicKey, 0, len(root.Keys))
	for _, id := range slices.Sorted(maps.Keys(root.Keys)) {
		pub, err := ParsePublicKeyHex(root.Keys[id].Public)
		if err != nil {
			return nil, err
		}
		keys = append(keys, pub)
	}
	return keys, nil
}

// NextTargets adds staged to previous (nil when targets was never signed).
// A name already published keeps its content: staging it again with the
// same length and SHA-256 is a no-op, with other content it is
// ErrImmutableTarget (REQ-DIST-003).
func NextTargets(previous *tuf.Targets, staged map[string]tuf.Target, sequence int, expires time.Time) (tuf.Targets, error) {
	next := tuf.Targets{Sequence: sequence, Expires: FormatExpires(expires), Targets: map[string]tuf.Target{}}
	if previous != nil {
		maps.Copy(next.Targets, previous.Targets)
	}
	for _, name := range slices.Sorted(maps.Keys(staged)) {
		t := staged[name]
		if old, ok := next.Targets[name]; ok && (old.SHA256 != t.SHA256 || old.Length != t.Length) {
			return tuf.Targets{}, fmt.Errorf("%w: %s is published as %s, staged as %s", ErrImmutableTarget, name, old.SHA256, t.SHA256)
		}
		next.Targets[name] = t
	}
	return next, nil
}

// NewSnapshot pins the targets file: its sequence and SHA-256 (§15 D59).
func NewSnapshot(sequence int, expires time.Time, targetsFile Envelope) (tuf.Snapshot, error) {
	targets, ok := targetsFile.Metadata.Signed.Variant.(tuf.Targets)
	if !ok {
		return tuf.Snapshot{}, fmt.Errorf("%w: targets.json holds a %T", ErrMalformed, targetsFile.Metadata.Signed.Variant)
	}
	return tuf.Snapshot{
		Sequence: sequence, Expires: FormatExpires(expires),
		Meta: tuf.SnapshotMeta{TargetsJSON: tuf.MetaRef{Version: targets.Sequence, SHA256: targetsFile.SHA256}},
	}, nil
}

// NewTimestamp pins the snapshot file. It may expire at most 7 days after
// now (§9.1), otherwise ErrTimestampExpiry.
func NewTimestamp(sequence int, now, expires time.Time, snapshotFile Envelope) (tuf.Timestamp, error) {
	if expires.Sub(now) > MaxTimestampLifetime {
		return tuf.Timestamp{}, fmt.Errorf("%w: expires %s", ErrTimestampExpiry, FormatExpires(expires))
	}
	snapshot, ok := snapshotFile.Metadata.Signed.Variant.(tuf.Snapshot)
	if !ok {
		return tuf.Timestamp{}, fmt.Errorf("%w: snapshot.json holds a %T", ErrMalformed, snapshotFile.Metadata.Signed.Variant)
	}
	return tuf.Timestamp{
		Sequence: sequence, Expires: FormatExpires(expires),
		Meta: tuf.TimestampMeta{SnapshotJSON: tuf.MetaRef{Version: snapshot.Sequence, SHA256: snapshotFile.SHA256}},
	}, nil
}
