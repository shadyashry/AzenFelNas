// Package fsrepo stores one channel of the distribution plane on disk, in
// the layout §9.1 gives the bucket, plus a staging area:
//
//	<dir>/metadata/{root,targets,snapshot,timestamp}.json
//	<dir>/packages/<type>/<version>/<sha256>.dmpkg
//	<dir>/staged/<type>/<version>.json   (built, not yet in targets.json)
//
// It implements the metadata, package and staging ports. Every access goes
// through os.Root, so no name can reach outside dir. S25 publishes the
// metadata and packages to R2.
package fsrepo

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"io/fs"
	"os"
	"path"
	"regexp"
	"slices"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

const (
	dirPerm  = 0o750
	filePerm = 0o600
)

var (
	typePattern    = regexp.MustCompile(`^[a-z_]+$`)
	versionPattern = regexp.MustCompile(`^[0-9A-Za-z.+-]+$`)
	shaPattern     = regexp.MustCompile(`^[a-f0-9]{64}$`)
)

// ErrBadName is returned for a target name or hash that cannot address a
// file in the layout.
var ErrBadName = errors.New("fsrepo: bad target name")

// Repo is one channel directory.
type Repo struct {
	Dir string
}

// ReadMetadata implements ports.MetadataReader.
func (r Repo) ReadMetadata(ctx context.Context, role trust.RoleName) ([]byte, error) {
	return r.read(ctx, path.Join("metadata", role.FileName()))
}

// WriteMetadata implements ports.MetadataWriter.
func (r Repo) WriteMetadata(ctx context.Context, role trust.RoleName, file []byte) error {
	return r.write(ctx, path.Join("metadata", role.FileName()), file)
}

// ReadPackage implements ports.PackageReader.
func (r Repo) ReadPackage(ctx context.Context, target, sha256 string) ([]byte, error) {
	p, err := packagePath(target, sha256)
	if err != nil {
		return nil, err
	}
	return r.read(ctx, p)
}

// WritePackage implements ports.PackageWriter. The path is the content
// address, so equal bytes land on the same file (REQ-DIST-003).
func (r Repo) WritePackage(ctx context.Context, target, sha256 string, container []byte) error {
	p, err := packagePath(target, sha256)
	if err != nil {
		return err
	}
	return r.write(ctx, p, container)
}

// StageTarget implements ports.TargetStager.
func (r Repo) StageTarget(ctx context.Context, name string, target tuf.Target) error {
	p, err := stagedPath(name)
	if err != nil {
		return err
	}
	data, err := json.Marshal(target)
	if err != nil {
		return fmt.Errorf("encode staged target: %w", err)
	}
	return r.write(ctx, p, data)
}

// StagedTargets implements ports.StagedTargets.
func (r Repo) StagedTargets(ctx context.Context) (map[string]tuf.Target, error) {
	root, err := r.open()
	if err != nil {
		return nil, err
	}
	defer root.Close() //nolint:errcheck // read-only use; nothing to flush
	files, err := fs.Glob(root.FS(), "staged/*/*.json")
	if err != nil {
		return nil, fmt.Errorf("list staged targets: %w", err)
	}
	staged := map[string]tuf.Target{}
	for _, f := range files {
		if err := ctx.Err(); err != nil {
			return nil, err
		}
		data, err := root.ReadFile(f)
		if err != nil {
			return nil, fmt.Errorf("read %s: %w", f, err)
		}
		var t tuf.Target
		if err := jsonx.DecodeStrict(data, &t); err != nil {
			return nil, fmt.Errorf("%s: %w", f, err)
		}
		rel := strings.TrimSuffix(strings.TrimPrefix(f, "staged/"), ".json")
		staged[rel] = t
	}
	return staged, nil
}

// ClearStaged implements ports.StagedTargets.
func (r Repo) ClearStaged(ctx context.Context, names []string) error {
	root, err := r.open()
	if err != nil {
		return err
	}
	defer root.Close() //nolint:errcheck // removals are already durable or reported
	for _, name := range slices.Sorted(slices.Values(names)) {
		if err := ctx.Err(); err != nil {
			return err
		}
		p, err := stagedPath(name)
		if err != nil {
			return err
		}
		if err := root.Remove(p); err != nil && !errors.Is(err, fs.ErrNotExist) {
			return fmt.Errorf("remove %s: %w", p, err)
		}
	}
	return nil
}

func (r Repo) open() (*os.Root, error) {
	if err := os.MkdirAll(r.Dir, dirPerm); err != nil {
		return nil, fmt.Errorf("create repository %s: %w", r.Dir, err)
	}
	root, err := os.OpenRoot(r.Dir)
	if err != nil {
		return nil, fmt.Errorf("open repository %s: %w", r.Dir, err)
	}
	return root, nil
}

func (r Repo) read(ctx context.Context, name string) ([]byte, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	root, err := os.OpenRoot(r.Dir)
	if errors.Is(err, fs.ErrNotExist) {
		return nil, fmt.Errorf("%s: %w", name, ports.ErrNotFound)
	}
	if err != nil {
		return nil, fmt.Errorf("open repository %s: %w", r.Dir, err)
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

// write replaces name atomically: a temporary file in the same directory,
// then a rename.
func (r Repo) write(ctx context.Context, name string, data []byte) error {
	if err := ctx.Err(); err != nil {
		return err
	}
	root, err := r.open()
	if err != nil {
		return err
	}
	defer root.Close() //nolint:errcheck // the rename below is the commit point
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

func splitTarget(name string) (string, string, error) {
	typ, version, ok := strings.Cut(name, "/")
	if !ok || !typePattern.MatchString(typ) || !versionPattern.MatchString(version) || strings.Trim(version, ".") == "" {
		return "", "", fmt.Errorf("%w: %q", ErrBadName, name)
	}
	return typ, version, nil
}

func packagePath(target, sha256 string) (string, error) {
	typ, version, err := splitTarget(target)
	if err != nil {
		return "", err
	}
	if !shaPattern.MatchString(sha256) {
		return "", fmt.Errorf("%w: sha256 %q", ErrBadName, sha256)
	}
	return path.Join("packages", typ, version, sha256+".dmpkg"), nil
}

func stagedPath(name string) (string, error) {
	typ, version, err := splitTarget(name)
	if err != nil {
		return "", err
	}
	return path.Join("staged", typ, version+".json"), nil
}
