// Package adapters_test runs the shared port contracts against every real
// adapter and its in-memory fake (REQ-TEST-004, §17.7).
package adapters_test

import (
	"errors"
	"path/filepath"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/fsrepo"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/keyfiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/pemkeys"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/sysclock"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/yamlprofiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/testsupport"
)

func TestRepositoryContract_REQ_TEST_004(t *testing.T) {
	t.Run("fsrepo", func(t *testing.T) {
		testsupport.RepositoryContract(t, func(t *testing.T) testsupport.Repository {
			return fsrepo.Repo{Dir: t.TempDir()}
		})
	})
	t.Run("in-memory fake", func(t *testing.T) {
		testsupport.RepositoryContract(t, func(*testing.T) testsupport.Repository { return testsupport.NewMemRepo() })
	})
}

func TestKeyRingContract_REQ_TEST_004(t *testing.T) {
	ks := testsupport.NewKeySet(t)
	t.Run("pemkeys.Dir", func(t *testing.T) {
		testsupport.KeyRingContract(t, ks, func(t *testing.T) ports.KeyRing {
			dir := t.TempDir()
			ks.WritePrivate(t, dir, "targets-1")
			return pemkeys.Dir{Dir: dir}
		})
	})
	t.Run("pemkeys.Env", func(t *testing.T) {
		testsupport.KeyRingContract(t, ks, func(t *testing.T) ports.KeyRing {
			vars := map[string]string{"DM_DEV_TARGETS_KEY_1": ks.Base64PEM(t, "targets-1")}
			return pemkeys.Env{Prefix: "DM_DEV_", Lookup: func(k string) (string, bool) { v, ok := vars[k]; return v, ok }}
		})
	})
	t.Run("in-memory fake", func(t *testing.T) {
		testsupport.KeyRingContract(t, ks, func(*testing.T) ports.KeyRing {
			return testsupport.Ring{Signers: map[string]trust.Signer{"targets-1": ks.Signers["targets-1"]}}
		})
	})
}

func TestKeyMaterialContract_REQ_TEST_004(t *testing.T) {
	ks := testsupport.NewKeySet(t)
	t.Run("keyfiles", func(t *testing.T) {
		dir := t.TempDir()
		ks.WritePublic(t, dir)
		testsupport.KeyMaterialContract(t, ks, keyfiles.KeyConfig{Dir: dir}, keyfiles.TrustAnchor{File: filepath.Join(dir, "root-keys.json")})
	})
	t.Run("in-memory fakes", func(t *testing.T) {
		testsupport.KeyMaterialContract(t, ks, testsupport.KeyConfig{Config: ks.Config}, testsupport.Anchor{Anchor: ks.Anchor})
	})
}

func TestProfileSourceContract_REQ_TEST_004(t *testing.T) {
	source := yamlprofiles.Source{Dir: filepath.Join("..", "..", "..", "..", "profiles")}
	t.Run("yamlprofiles", func(t *testing.T) { testsupport.ProfileSourceContract(t, source) })
	t.Run("in-memory fake", func(t *testing.T) {
		docs, err := source.LoadProfiles(t.Context())
		if err != nil {
			t.Fatal(err)
		}
		testsupport.ProfileSourceContract(t, testsupport.Profiles{Docs: docs})
	})
}

func TestClockContract_REQ_TEST_004(t *testing.T) {
	t.Run("sysclock", func(t *testing.T) { testsupport.ClockContract(t, sysclock.Clock{}) })
	t.Run("fixed fake", func(t *testing.T) {
		testsupport.ClockContract(t, testsupport.Clock{T: time.Date(2026, 10, 22, 0, 0, 0, 0, time.UTC)})
	})
}

func TestFsrepoRefusesNamesOutsideTheLayout(t *testing.T) {
	t.Parallel()
	r := fsrepo.Repo{Dir: t.TempDir()}
	const sha = "0000000000000000000000000000000000000000000000000000000000000001"
	for _, name := range []string{"../x/1", "prayer_profiles/..", "prayer_profiles", "Prayer/1", "prayer_profiles/a/b"} {
		if err := r.WritePackage(t.Context(), name, sha, nil); !errors.Is(err, fsrepo.ErrBadName) {
			t.Errorf("WritePackage(%q) err = %v, want ErrBadName", name, err)
		}
	}
	if err := r.WritePackage(t.Context(), "prayer_profiles/1", "../../etc", nil); !errors.Is(err, fsrepo.ErrBadName) {
		t.Errorf("bad sha: err = %v", err)
	}
}

func TestPEMKeysRefuseNonEd25519OrMalformedKeys(t *testing.T) {
	t.Parallel()
	vars := map[string]string{"DM_DEV_ROOT_KEY_1": "not base64!", "DM_DEV_ROOT_KEY_2": "bm90IGEgcGVt"}
	ring := pemkeys.Env{Prefix: "DM_DEV_", Lookup: func(k string) (string, bool) { v, ok := vars[k]; return v, ok }}
	for _, name := range []string{"root-1", "root-2", "root", "../root-1"} {
		if _, err := ring.Signer(t.Context(), name); !errors.Is(err, pemkeys.ErrBadKey) {
			t.Errorf("Signer(%q) err = %v, want ErrBadKey", name, err)
		}
	}
}
