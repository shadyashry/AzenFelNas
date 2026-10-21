// Package pemkeys provides ports.KeyRing over PKCS#8 PEM Ed25519 private
// keys, the form the dev keys were generated in (S01 OpenSSL). Private keys
// never touch the repository (ADR-009, §25, REQ-SEC-030): Dir reads a
// gitignored directory, Env reads base64 PEMs from CI secrets.
package pemkeys

import (
	"context"
	"crypto"
	"crypto/ed25519"
	"crypto/x509"
	"encoding/base64"
	"encoding/pem"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// ErrBadKey is returned for key material that is not a PKCS#8 Ed25519 key.
var ErrBadKey = errors.New("pemkeys: not a PKCS#8 Ed25519 private key")

// Dir reads <Dir>/<name>.pem.
type Dir struct {
	Dir string
}

// Signer implements ports.KeyRing.
func (d Dir) Signer(ctx context.Context, name string) (trust.Signer, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	if err := checkName(name); err != nil {
		return nil, err
	}
	root, err := os.OpenRoot(d.Dir)
	if err != nil {
		return nil, fmt.Errorf("open key directory: %w", err)
	}
	defer root.Close() //nolint:errcheck // read-only use; nothing to flush
	data, err := root.ReadFile(name + ".pem")
	if errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("key %s: %w", name, ports.ErrNotFound)
	}
	if err != nil {
		return nil, fmt.Errorf("read key %s: %w", name, err)
	}
	return parse(name, data)
}

// Env reads the base64 of a PEM from the variable Prefix + ROLE + "_KEY_" +
// N for a key named "<role>-<N>"; with Prefix "DM_DEV_", root-1 is
// DM_DEV_ROOT_KEY_1 (tools/gsctl/keys/dev/README.md).
type Env struct {
	Prefix string
	Lookup func(string) (string, bool)
}

// Signer implements ports.KeyRing.
func (e Env) Signer(ctx context.Context, name string) (trust.Signer, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	if err := checkName(name); err != nil {
		return nil, err
	}
	variable, err := e.variable(name)
	if err != nil {
		return nil, err
	}
	value, ok := e.Lookup(variable)
	if !ok || value == "" {
		return nil, fmt.Errorf("key %s (%s): %w", name, variable, ports.ErrNotFound)
	}
	data, err := base64.StdEncoding.DecodeString(strings.TrimSpace(value))
	if err != nil {
		return nil, fmt.Errorf("%w: %s is not base64", ErrBadKey, variable)
	}
	return parse(name, data)
}

// Variable is the environment variable that holds the named key.
func (e Env) variable(name string) (string, error) {
	role, n, ok := strings.Cut(name, "-")
	if !ok || role == "" || n == "" || strings.Contains(n, "-") {
		return "", fmt.Errorf("%w: key name %q is not <role>-<n>", ErrBadKey, name)
	}
	return e.Prefix + strings.ToUpper(role) + "_KEY_" + strings.ToUpper(n), nil
}

func checkName(name string) error {
	if name == "" || strings.ContainsAny(name, `/\.`) {
		return fmt.Errorf("%w: key name %q", ErrBadKey, name)
	}
	return nil
}

func parse(name string, data []byte) (trust.Signer, error) {
	block, _ := pem.Decode(data)
	if block == nil || block.Type != "PRIVATE KEY" {
		return nil, fmt.Errorf("%w: %s", ErrBadKey, name)
	}
	key, err := x509.ParsePKCS8PrivateKey(block.Bytes)
	if err != nil {
		return nil, fmt.Errorf("%w: %s: %w", ErrBadKey, name, err)
	}
	priv, ok := key.(ed25519.PrivateKey)
	if !ok {
		return nil, fmt.Errorf("%w: %s holds a %T", ErrBadKey, name, key)
	}
	pubBytes, ok := priv.Public().(ed25519.PublicKey)
	if !ok {
		return nil, fmt.Errorf("%w: %s", ErrBadKey, name)
	}
	pub, err := trust.NewPublicKey(pubBytes)
	if err != nil {
		return nil, err
	}
	return signer{priv: priv, pub: pub}, nil
}

type signer struct {
	priv ed25519.PrivateKey
	pub  trust.PublicKey
}

func (s signer) PublicKey() trust.PublicKey { return s.pub }

func (s signer) Sign(message []byte) ([]byte, error) {
	sig, err := s.priv.Sign(nil, message, crypto.Hash(0))
	if err != nil {
		return nil, fmt.Errorf("ed25519 sign: %w", err)
	}
	return sig, nil
}
