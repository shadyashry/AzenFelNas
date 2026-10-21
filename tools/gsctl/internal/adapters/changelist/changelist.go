// Package changelist reads the paths a pull request changes from a file
// with one path per line, as `git diff --name-only base...head` writes it
// (ports.ChangedPaths).
package changelist

import (
	"context"
	"fmt"
	"os"
	"strings"
)

// File reads Path.
type File struct {
	Path string
}

// ChangedPaths implements ports.ChangedPaths: blank lines are skipped and
// backslashes become slashes.
func (f File) ChangedPaths(ctx context.Context) ([]string, error) {
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	data, err := os.ReadFile(f.Path)
	if err != nil {
		return nil, fmt.Errorf("read changed paths: %w", err)
	}
	var paths []string
	for line := range strings.Lines(string(data)) {
		if p := strings.TrimSpace(line); p != "" {
			paths = append(paths, strings.ReplaceAll(p, `\`, "/"))
		}
	}
	return paths, nil
}
