// Package keyfiles reads the committed public key material of a key set
// (tools/gsctl/keys/<set>/, §15 D17, D62): roles.json assigns named keys to
// roles, <name>.pub.hex holds each raw public key, and root-keys.json is
// the trust anchor a client embeds. No private key is ever read here.
package keyfiles

import (
	"context"
	"errors"
	"fmt"
	"os"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"
)

// ErrInconsistent is returned when a key file contradicts another.
var ErrInconsistent = errors.New("keyfiles: inconsistent key material")

// rolesFile is roles.json.
type rolesFile struct {
	Description string                  `json:"description"`
	Roles       map[string]roleKeysFile `json:"roles"`
}

type roleKeysFile struct {
	Threshold int      `json:"threshold"`
	Keys      []string `json:"keys"`
}

// KeyConfig implements ports.KeyConfigSource from Dir/roles.json and the
// Dir/<name>.pub.hex files.
type KeyConfig struct {
	Dir string
}

// LoadKeyConfig implements ports.KeyConfigSource.
func (k KeyConfig) LoadKeyConfig(ctx context.Context) (trust.KeyConfig, error) {
	if err := ctx.Err(); err != nil {
		return trust.KeyConfig{}, err
	}
	root, err := os.OpenRoot(k.Dir)
	if err != nil {
		return trust.KeyConfig{}, fmt.Errorf("open key directory: %w", err)
	}
	defer root.Close() //nolint:errcheck // read-only use; nothing to flush
	data, err := root.ReadFile("roles.json")
	if err != nil {
		return trust.KeyConfig{}, fmt.Errorf("read roles.json: %w", err)
	}
	var file rolesFile
	if err := jsonx.DecodeStrict(data, &file); err != nil {
		return trust.KeyConfig{}, fmt.Errorf("roles.json: %w", err)
	}
	config := trust.KeyConfig{Roles: map[trust.RoleName]trust.RoleKeys{}}
	for name, rk := range file.Roles {
		role, err := trust.ParseRoleName(name)
		if err != nil {
			return trust.KeyConfig{}, fmt.Errorf("roles.json: %w", err)
		}
		keys := trust.RoleKeys{Threshold: rk.Threshold}
		for _, keyName := range rk.Keys {
			pub, err := readPublicKey(root, keyName)
			if err != nil {
				return trust.KeyConfig{}, err
			}
			keys.Keys = append(keys.Keys, trust.NamedKey{Name: keyName, Key: pub})
		}
		config.Roles[role] = keys
	}
	return config, nil
}

func readPublicKey(root *os.Root, name string) (trust.PublicKey, error) {
	if name == "" || strings.ContainsAny(name, `/\.`) {
		return trust.PublicKey{}, fmt.Errorf("%w: key name %q", ErrInconsistent, name)
	}
	data, err := root.ReadFile(name + ".pub.hex")
	if err != nil {
		return trust.PublicKey{}, fmt.Errorf("read %s.pub.hex: %w", name, err)
	}
	pub, err := trust.ParsePublicKeyHex(strings.TrimSpace(string(data)))
	if err != nil {
		return trust.PublicKey{}, fmt.Errorf("%s.pub.hex: %w", name, err)
	}
	return pub, nil
}

// anchorFile is root-keys.json (S01).
type anchorFile struct {
	Scheme    string `json:"scheme"`
	Threshold int    `json:"threshold"`
	Keys      []struct {
		Name   string `json:"name"`
		KeyID  string `json:"keyId"`
		Public string `json:"public"`
	} `json:"keys"`
}

// TrustAnchor implements ports.TrustAnchorSource from a root-keys.json file.
type TrustAnchor struct {
	File string
}

// LoadTrustAnchor implements ports.TrustAnchorSource. Every keyId must be
// the SHA-256 of its public key (§15 D17).
func (t TrustAnchor) LoadTrustAnchor(ctx context.Context) (trust.Anchor, error) {
	if err := ctx.Err(); err != nil {
		return trust.Anchor{}, err
	}
	data, err := os.ReadFile(t.File)
	if err != nil {
		return trust.Anchor{}, fmt.Errorf("read trust anchor: %w", err)
	}
	var file anchorFile
	if err := jsonx.DecodeStrict(data, &file); err != nil {
		return trust.Anchor{}, fmt.Errorf("%s: %w", t.File, err)
	}
	if file.Scheme != "ed25519" || file.Threshold < 1 || len(file.Keys) < file.Threshold {
		return trust.Anchor{}, fmt.Errorf("%w: %s: scheme %q, %d key(s), threshold %d", ErrInconsistent, t.File, file.Scheme, len(file.Keys), file.Threshold)
	}
	anchor := trust.Anchor{Threshold: file.Threshold}
	for _, k := range file.Keys {
		pub, err := trust.ParsePublicKeyHex(k.Public)
		if err != nil {
			return trust.Anchor{}, fmt.Errorf("%s: %s: %w", t.File, k.Name, err)
		}
		if pub.ID() != k.KeyID {
			return trust.Anchor{}, fmt.Errorf("%w: %s: %s has keyId %s, its key hashes to %s", ErrInconsistent, t.File, k.Name, k.KeyID, pub.ID())
		}
		anchor.Keys = append(anchor.Keys, pub)
	}
	return anchor, nil
}
