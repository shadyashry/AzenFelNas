// Package testsupport generates ephemeral keys and in-memory port fakes
// for gsctl tests. Test-only support code: no key it makes is ever written
// to the repository (REQ-SEC-030).
package testsupport

import (
	"context"
	"crypto/ed25519"
	"crypto/rand"
	"crypto/x509"
	"encoding/base64"
	"encoding/json"
	"encoding/pem"
	"os"
	"path/filepath"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
)

// RoleKeyNames are the key names of a channel's key set (§15 D62).
var RoleKeyNames = map[trust.RoleName][]string{
	trust.RoleRoot:      {"root-1", "root-2", "root-3"},
	trust.RoleTargets:   {"targets-1"},
	trust.RoleSnapshot:  {"snapshot-1"},
	trust.RoleTimestamp: {"timestamp-1"},
}

// KeySet is a freshly generated key set with Appendix C thresholds.
type KeySet struct {
	Config  trust.KeyConfig
	Anchor  trust.Anchor
	Signers map[string]trust.Signer
	private map[string]ed25519.PrivateKey
}

// NewKeySet generates the six keys of RoleKeyNames.
func NewKeySet(t *testing.T) KeySet {
	t.Helper()
	ks := KeySet{
		Config:  trust.KeyConfig{Roles: map[trust.RoleName]trust.RoleKeys{}},
		Signers: map[string]trust.Signer{},
		private: map[string]ed25519.PrivateKey{},
	}
	for _, role := range trust.Roles() {
		rk := trust.RoleKeys{Threshold: 1}
		if role == trust.RoleRoot {
			rk.Threshold = 2
		}
		for _, name := range RoleKeyNames[role] {
			pub, priv, err := ed25519.GenerateKey(rand.Reader)
			if err != nil {
				t.Fatal(err)
			}
			key, err := trust.NewPublicKey(pub)
			if err != nil {
				t.Fatal(err)
			}
			ks.private[name] = priv
			ks.Signers[name] = Signer{Priv: priv, Pub: key}
			rk.Keys = append(rk.Keys, trust.NamedKey{Name: name, Key: key})
			if role == trust.RoleRoot {
				ks.Anchor.Keys = append(ks.Anchor.Keys, key)
			}
		}
		ks.Config.Roles[role] = rk
	}
	ks.Anchor.Threshold = 2
	return ks
}

// SignersOf returns the signers of role's keys.
func (k KeySet) SignersOf(role trust.RoleName) []trust.Signer {
	var out []trust.Signer
	for _, name := range RoleKeyNames[role] {
		out = append(out, k.Signers[name])
	}
	return out
}

// WritePublic writes roles.json, <name>.pub.hex and root-keys.json to dir,
// in the committed key-set layout.
func (k KeySet) WritePublic(t *testing.T, dir string) {
	t.Helper()
	roles := map[string]any{}
	var anchorKeys []map[string]string
	for _, role := range trust.Roles() {
		rk := k.Config.Roles[role]
		var names []string
		for _, nk := range rk.Keys {
			names = append(names, nk.Name)
			writeFile(t, filepath.Join(dir, nk.Name+".pub.hex"), []byte(nk.Key.Hex()+"\n"))
			if role == trust.RoleRoot {
				anchorKeys = append(anchorKeys, map[string]string{"name": nk.Name, "keyId": nk.Key.ID(), "public": nk.Key.Hex()})
			}
		}
		roles[string(role)] = map[string]any{"threshold": rk.Threshold, "keys": names}
	}
	writeJSON(t, filepath.Join(dir, "roles.json"), map[string]any{"description": "test key set", "roles": roles})
	writeJSON(t, filepath.Join(dir, "root-keys.json"), map[string]any{"scheme": "ed25519", "threshold": 2, "keys": anchorKeys})
}

// WritePrivate writes <name>.pem (PKCS#8) for names into dir.
func (k KeySet) WritePrivate(t *testing.T, dir string, names ...string) {
	t.Helper()
	for _, name := range names {
		writeFile(t, filepath.Join(dir, name+".pem"), k.PEM(t, name))
	}
}

// PEM returns the PKCS#8 PEM of the named private key.
func (k KeySet) PEM(t *testing.T, name string) []byte {
	t.Helper()
	der, err := x509.MarshalPKCS8PrivateKey(k.private[name])
	if err != nil {
		t.Fatal(err)
	}
	return pem.EncodeToMemory(&pem.Block{Type: "PRIVATE KEY", Bytes: der})
}

// Base64PEM is the CI-secret form of the named key.
func (k KeySet) Base64PEM(t *testing.T, name string) string {
	t.Helper()
	return base64.StdEncoding.EncodeToString(k.PEM(t, name))
}

// Signer signs with an in-memory key.
type Signer struct {
	Priv ed25519.PrivateKey
	Pub  trust.PublicKey
}

// PublicKey implements trust.Signer.
func (s Signer) PublicKey() trust.PublicKey { return s.Pub }

// Sign implements trust.Signer.
func (s Signer) Sign(_ context.Context, message []byte) ([]byte, error) {
	return ed25519.Sign(s.Priv, message), nil
}

func writeJSON(t *testing.T, path string, v any) {
	t.Helper()
	data, err := json.MarshalIndent(v, "", "  ")
	if err != nil {
		t.Fatal(err)
	}
	writeFile(t, path, append(data, '\n'))
}

func writeFile(t *testing.T, path string, data []byte) {
	t.Helper()
	if err := os.MkdirAll(filepath.Dir(path), 0o750); err != nil {
		t.Fatal(err)
	}
	if err := os.WriteFile(path, data, 0o600); err != nil {
		t.Fatal(err)
	}
}
