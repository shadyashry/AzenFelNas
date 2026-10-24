// Package localbucket is the distribution bucket on the local disk
// (§15 D65): ports.ObjectStore over a directory, plus a read-only HTTP
// handler that serves it the way the CDN serves R2 (§9.1). Objects live at
// <Dir>/<key>; each object's Cache-Control lives at
// <Dir>/.cache-control/<key>. S25 replaces it with an R2 adapter behind the
// same port.
package localbucket

import (
	"context"
	"errors"
	"fmt"
	"io/fs"
	"net/http"
	"os"
	"path"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/cdnstandin"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

const (
	dirPerm  = 0o750
	filePerm = 0o600
	// headerDir holds the Cache-Control sidecars.
	headerDir = ".cache-control"
)

// ErrBadKey is returned for a key that is not a relative slash path of
// plain names.
var ErrBadKey = ports.ErrBadKey

// Bucket is a directory used as a bucket.
type Bucket struct {
	Dir string
}

// GetObject implements ports.ObjectStore.
func (b Bucket) GetObject(ctx context.Context, key string) ([]byte, error) {
	if err := checkKey(key); err != nil {
		return nil, err
	}
	return b.read(ctx, key)
}

// PutObject implements ports.ObjectStore, atomically: a temporary file,
// then a rename; the Cache-Control sidecar is written first.
func (b Bucket) PutObject(ctx context.Context, key string, data []byte, cacheControl string) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	if err := checkKey(key); err != nil {
		return err
	}
	if err := os.MkdirAll(b.Dir, dirPerm); err != nil {
		return fmt.Errorf("create bucket %s: %w", b.Dir, err)
	}
	root, err := os.OpenRoot(b.Dir)
	if err != nil {
		return fmt.Errorf("open bucket: %w", err)
	}
	defer root.Close() //nolint:errcheck // the renames below are the commit points
	if err := writeAtomic(root, path.Join(headerDir, key), []byte(cacheControl)); err != nil {
		return err
	}
	return writeAtomic(root, key, data)
}

// CacheControl returns an object's Cache-Control, "" when it has none.
func (b Bucket) CacheControl(ctx context.Context, key string) (string, error) {
	if err := checkKey(key); err != nil {
		return "", err
	}
	data, err := b.read(ctx, path.Join(headerDir, key))
	if errors.Is(err, ports.ErrNotFound) {
		return "", nil
	}
	return strings.TrimSpace(string(data)), err
}

// read reads name, a key already checked by the caller (or its sidecar).
func (b Bucket) read(ctx context.Context, name string) ([]byte, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	root, err := os.OpenRoot(b.Dir)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("%s: %w", name, ports.ErrNotFound)
	}
	if err != nil {
		return nil, fmt.Errorf("open bucket: %w", err)
	}
	defer root.Close() //nolint:errcheck // read-only use; nothing to flush
	data, err := root.ReadFile(name)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("%s: %w", name, ports.ErrNotFound)
	}
	if err != nil {
		return nil, fmt.Errorf("read %s: %w", name, err)
	}
	return data, nil
}

func writeAtomic(root *os.Root, name string, data []byte) error {
	if err := root.MkdirAll(path.Dir(name), dirPerm); err != nil {
		return fmt.Errorf("create %s: %w", path.Dir(name), err)
	}
	tmp := name + ".tmp"
	if err := root.WriteFile(tmp, data, filePerm); err != nil {
		return fmt.Errorf("write %s: %w", tmp, err)
	}
	if err := root.Rename(tmp, name); err != nil {
		return fmt.Errorf("rename %s: %w", tmp, err)
	}
	return nil
}

// checkKey accepts relative slash paths of names that are not "." or "..",
// do not start with a dot and hold no backslash.
func checkKey(key string) error {
	if err := distribution.CheckKey(key); err != nil {
		return fmt.Errorf("localbucket: %w", err)
	}
	return nil
}

// Handler serves the bucket read-only through the CDN stand-in.
func (b Bucket) Handler() http.Handler { return cdnstandin.Handler(b) }
