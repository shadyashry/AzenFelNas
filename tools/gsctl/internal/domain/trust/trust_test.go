package trust_test

import (
	"bytes"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"errors"
	"os"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

var now = time.Date(2026, 10, 21, 12, 0, 0, 0, time.UTC)

const day = 24 * time.Hour

var packageBytes = []byte("a .dmpkg stand-in")

// chain signs a complete channel at sequence seq for every role, the root
// with exactly its threshold of keys so that every byte of every file is
// load-bearing.
func chain(t *testing.T, ks testsupport.KeySet, seq int) trust.Files {
	t.Helper()
	root, err := trust.NewRoot(1, now.Add(365*day), ks.Config)
	if err != nil {
		t.Fatal(err)
	}
	rootFile := signFile(t, root, ks.SignersOf(trust.RoleRoot)[:2])
	target := tuf.Target{Length: int64(len(packageBytes)), SHA256: shaHex(packageBytes), Custom: custom()}
	targets, err := trust.NextTargets(nil, map[string]tuf.Target{"prayer_profiles/2026.10.1": target}, seq, now.Add(90*day))
	if err != nil {
		t.Fatal(err)
	}
	targetsFile := signFile(t, targets, ks.SignersOf(trust.RoleTargets))
	snapshot, err := trust.NewSnapshot(seq, now.Add(30*day), parse(t, targetsFile))
	if err != nil {
		t.Fatal(err)
	}
	snapshotFile := signFile(t, snapshot, ks.SignersOf(trust.RoleSnapshot))
	timestamp, err := trust.NewTimestamp(seq, now, now.Add(7*day), parse(t, snapshotFile))
	if err != nil {
		t.Fatal(err)
	}
	return trust.Files{Root: rootFile, Targets: targetsFile, Snapshot: snapshotFile, Timestamp: signFile(t, timestamp, ks.SignersOf(trust.RoleTimestamp))}
}

func custom() tuf.TargetCustom {
	return tuf.TargetCustom{
		SchemaVersion: 1, PayloadFormat: tuf.PayloadJSON, Compat: tuf.Compat{MinApp: "1.0.0", MinEngineSchema: 1},
		EffectiveFrom: "2026-11-01", Priority: tuf.PriorityNormal, ChangeNote: tuf.ChangeNote{Ar: "تحديث", En: "Update"},
	}
}

func signFile(t *testing.T, doc tuf.SignedVariant, signers []trust.Signer) []byte {
	t.Helper()
	m, err := trust.Sign(tuf.Signed{Variant: doc}, signers)
	if err != nil {
		t.Fatal(err)
	}
	file, err := trust.EncodeFile(m)
	if err != nil {
		t.Fatal(err)
	}
	return file
}

func parse(t *testing.T, file []byte) trust.Envelope {
	t.Helper()
	env, err := trust.ParseEnvelope(file)
	if err != nil {
		t.Fatal(err)
	}
	return env
}

func shaHex(b []byte) string {
	sum := sha256.Sum256(b)
	return hex.EncodeToString(sum[:])
}

func TestSignThenVerifyRoundTrips_REQ_DIST_001_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 3)

	got, err := trust.VerifyChain(files, ks.Anchor, trust.Sequences{}, now)
	if err != nil {
		t.Fatalf("VerifyChain: %v", err)
	}
	if got.Sequences != (trust.Sequences{Timestamp: 3, Snapshot: 3, Targets: 3}) || len(got.Warnings) != 0 {
		t.Fatalf("got sequences %+v, warnings %v", got.Sequences, got.Warnings)
	}
	target := got.Targets.Targets["prayer_profiles/2026.10.1"]
	if err := trust.VerifyTarget("prayer_profiles/2026.10.1", target, packageBytes); err != nil {
		t.Fatalf("VerifyTarget: %v", err)
	}
}

// Every single-bit change anywhere in any metadata file fails verification
// with an Appendix J code: inside `signed` the signature breaks, in a
// signature the threshold is missed, elsewhere the JSON or the shape breaks.
func TestAnyTamperedByteFailsVerification_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 1)
	for _, f := range []struct {
		role trust.RoleName
		file *[]byte
	}{
		{trust.RoleRoot, &files.Root},
		{trust.RoleTargets, &files.Targets},
		{trust.RoleSnapshot, &files.Snapshot},
		{trust.RoleTimestamp, &files.Timestamp},
	} {
		t.Run(string(f.role), func(t *testing.T) {
			t.Parallel()
			original := *f.file
			for i := range original {
				tampered := files
				changed := bytes.Clone(original)
				changed[i] ^= 0x01
				switch f.role {
				case trust.RoleRoot:
					tampered.Root = changed
				case trust.RoleTargets:
					tampered.Targets = changed
				case trust.RoleSnapshot:
					tampered.Snapshot = changed
				case trust.RoleTimestamp:
					tampered.Timestamp = changed
				}
				_, err := trust.VerifyChain(tampered, ks.Anchor, trust.Sequences{}, now)
				if err == nil || trust.Code(err) == "" {
					t.Fatalf("byte %d (%q) of %s flipped: err = %v, want a PKG_* failure", i, original[i], f.role.FileName(), err)
				}
			}
		})
	}
}

func TestReformattedTargetsKeepsSignatureButBreaksTheSnapshotPin_REQ_DIST_004(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 1)
	var compact bytes.Buffer
	if err := json.Compact(&compact, files.Targets); err != nil {
		t.Fatal(err)
	}
	files.Targets = compact.Bytes()

	_, err := trust.VerifyChain(files, ks.Anchor, trust.Sequences{}, now)
	if !errors.Is(err, trust.ErrHashMismatch) || trust.Code(err) != "PKG_HASH_MISMATCH" {
		t.Fatalf("err = %v, want PKG_HASH_MISMATCH", err)
	}
}

func TestVerifyChainRejectsSequenceRegression_REQ_PKG_005(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 5)
	tests := []struct {
		name  string
		after trust.Sequences
	}{
		{name: "timestamp replayed", after: trust.Sequences{Timestamp: 5}},
		{name: "timestamp rolled back", after: trust.Sequences{Timestamp: 6}},
		{name: "snapshot replayed", after: trust.Sequences{Snapshot: 5}},
		{name: "targets rolled back", after: trust.Sequences{Targets: 9}},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			_, err := trust.VerifyChain(files, ks.Anchor, tc.after, now)
			if !errors.Is(err, trust.ErrSequenceRegression) || trust.Code(err) != "PKG_SEQUENCE_REGRESSION" {
				t.Fatalf("err = %v, want PKG_SEQUENCE_REGRESSION", err)
			}
		})
	}
	if _, err := trust.VerifyChain(files, ks.Anchor, trust.Sequences{Timestamp: 4, Snapshot: 4, Targets: 4}, now); err != nil {
		t.Fatalf("strictly greater sequences refused: %v", err)
	}
}

func TestNextSequenceIsStrictlyMonotonic_REQ_DIST_002(t *testing.T) {
	t.Parallel()
	tests := []struct {
		previous, requested, want int
		wantErr                   bool
	}{
		{previous: 0, requested: 0, want: 1},
		{previous: 4, requested: 0, want: 5},
		{previous: 4, requested: 9, want: 9},
		{previous: 4, requested: 4, wantErr: true},
		{previous: 4, requested: 3, wantErr: true},
	}
	for _, tc := range tests {
		got, err := trust.NextSequence(tc.previous, tc.requested)
		if tc.wantErr != errors.Is(err, trust.ErrSequenceRegression) || got != tc.want {
			t.Errorf("NextSequence(%d, %d) = %d, %v", tc.previous, tc.requested, got, err)
		}
	}
}

func TestRootNeedsTheAnchorThreshold_REQ_DIST_001(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 1)
	root, err := trust.NewRoot(1, now.Add(day), ks.Config)
	if err != nil {
		t.Fatal(err)
	}
	one := ks.SignersOf(trust.RoleRoot)[:1]
	tests := []struct {
		name    string
		signers []trust.Signer
	}{
		{name: "one root key", signers: one},
		{name: "one root key twice", signers: append(one, one...)},
		{name: "targets and snapshot keys", signers: append(ks.SignersOf(trust.RoleTargets), ks.SignersOf(trust.RoleSnapshot)...)},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			tampered := files
			tampered.Root = signFile(t, root, tc.signers)
			_, err := trust.VerifyChain(tampered, ks.Anchor, trust.Sequences{}, now)
			if !errors.Is(err, trust.ErrSignature) {
				t.Fatalf("err = %v, want ErrSignature", err)
			}
		})
	}
}

func TestRootStructureFollowsAppendixC_REQ_DIST_001(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	mutate := map[string]func(*trust.KeyConfig){
		"root threshold 1": func(c *trust.KeyConfig) {
			rk := c.Roles[trust.RoleRoot]
			rk.Threshold = 1
			c.Roles[trust.RoleRoot] = rk
		},
		"two root keys": func(c *trust.KeyConfig) {
			rk := c.Roles[trust.RoleRoot]
			rk.Keys = rk.Keys[:2]
			c.Roles[trust.RoleRoot] = rk
		},
		"targets threshold 2": func(c *trust.KeyConfig) {
			rk := c.Roles[trust.RoleTargets]
			rk.Threshold = 2
			c.Roles[trust.RoleTargets] = rk
		},
		"no timestamp role": func(c *trust.KeyConfig) { delete(c.Roles, trust.RoleTimestamp) },
	}
	for name, m := range mutate {
		t.Run(name, func(t *testing.T) {
			t.Parallel()
			config := trust.KeyConfig{Roles: map[trust.RoleName]trust.RoleKeys{}}
			for r, rk := range ks.Config.Roles {
				config.Roles[r] = trust.RoleKeys{Threshold: rk.Threshold, Keys: append([]trust.NamedKey(nil), rk.Keys...)}
			}
			m(&config)
			if _, err := trust.NewRoot(1, now, config); !errors.Is(err, trust.ErrMalformed) {
				t.Fatalf("NewRoot err = %v, want ErrMalformed", err)
			}
		})
	}
}

func TestPublishedTargetsAreImmutable_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	published := tuf.Targets{Sequence: 1, Targets: map[string]tuf.Target{
		"prayer_profiles/1": {Length: 3, SHA256: shaHex([]byte("old")), Custom: custom()},
	}}
	same := map[string]tuf.Target{"prayer_profiles/1": published.Targets["prayer_profiles/1"]}
	if _, err := trust.NextTargets(&published, same, 2, now); err != nil {
		t.Fatalf("re-staging identical content: %v", err)
	}
	changed := map[string]tuf.Target{"prayer_profiles/1": {Length: 3, SHA256: shaHex([]byte("new")), Custom: custom()}}
	if _, err := trust.NextTargets(&published, changed, 2, now); !errors.Is(err, trust.ErrImmutableTarget) {
		t.Fatalf("err = %v, want ErrImmutableTarget", err)
	}
	next, err := trust.NextTargets(&published, map[string]tuf.Target{"prayer_profiles/2": changed["prayer_profiles/1"]}, 2, now)
	if err != nil || len(next.Targets) != 2 {
		t.Fatalf("adding a version: %v, %d targets", err, len(next.Targets))
	}
}

func TestVerifyTargetRejectsAnyChangedPackageByte_REQ_DIST_003(t *testing.T) {
	t.Parallel()
	target := tuf.Target{Length: int64(len(packageBytes)), SHA256: shaHex(packageBytes)}
	for i := range packageBytes {
		changed := bytes.Clone(packageBytes)
		changed[i] ^= 0x80
		if err := trust.VerifyTarget("t/1", target, changed); trust.Code(err) != "PKG_HASH_MISMATCH" {
			t.Fatalf("byte %d: err = %v", i, err)
		}
	}
	if err := trust.VerifyTarget("t/1", target, append(bytes.Clone(packageBytes), 0)); trust.Code(err) != "PKG_HASH_MISMATCH" {
		t.Fatalf("appended byte: err = %v", err)
	}
}

func TestTimestampLivesAtMostSevenDays(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 1)
	if _, err := trust.NewTimestamp(2, now, now.Add(7*day+time.Second), parse(t, files.Snapshot)); !errors.Is(err, trust.ErrTimestampExpiry) {
		t.Fatalf("err = %v, want ErrTimestampExpiry", err)
	}
}

func TestExpiredMetadataWarnsButVerifies_REQ_PKG_002(t *testing.T) {
	t.Parallel()
	ks := testsupport.NewKeySet(t)
	files := chain(t, ks, 1)
	got, err := trust.VerifyChain(files, ks.Anchor, trust.Sequences{}, now.Add(8*day))
	if err != nil {
		t.Fatalf("VerifyChain: %v", err)
	}
	if len(got.Warnings) != 1 || got.Warnings[0].Role != trust.RoleTimestamp {
		t.Fatalf("warnings = %+v, want the timestamp only", got.Warnings)
	}
}

// The committed dev trust anchor obeys §15 D17.
func TestDevRootKeyIDsAreSHA256OfThePublicKey(t *testing.T) {
	t.Parallel()
	data, err := os.ReadFile("../../../keys/dev/root-keys.json")
	if err != nil {
		t.Fatal(err)
	}
	var file struct {
		Keys []struct {
			KeyID  string `json:"keyId"`
			Public string `json:"public"`
		} `json:"keys"`
	}
	if err := json.Unmarshal(data, &file); err != nil {
		t.Fatal(err)
	}
	for _, k := range file.Keys {
		pub, err := trust.ParsePublicKeyHex(k.Public)
		if err != nil || pub.ID() != k.KeyID {
			t.Fatalf("key %s: id %s, err %v", k.Public, pub.ID(), err)
		}
	}
}
