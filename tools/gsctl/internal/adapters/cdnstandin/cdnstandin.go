// Package cdnstandin serves a distribution bucket read-only over HTTP, as
// the CDN serves R2 (§9.1): `gsctl serve` puts it in front of the local
// bucket or of an S3-compatible one (§15 D65, D85).
package cdnstandin

import (
	"bytes"
	"context"
	"errors"
	"net/http"
	"strings"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// Store is what the stand-in reads: an object and the Cache-Control it was
// stored with ("" when none). A key the store cannot address is
// ports.ErrBadKey, an absent one ports.ErrNotFound; both answer 404.
type Store interface {
	GetObject(ctx context.Context, key string) ([]byte, error)
	CacheControl(ctx context.Context, key string) (string, error)
}

// Handler serves store read-only, as the CDN serves R2 (§9.1): GET and
// HEAD only, each object with its stored Cache-Control (REQ-DIST-005), JSON
// metadata as application/json and packages as opaque bytes (never with a
// Content-Encoding, so a client hashes exactly what was signed). There are
// no directory listings and no request logging (REQ-DIST-006).
func Handler(b Store) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			w.Header().Set("Allow", "GET, HEAD")
			http.Error(w, "method not allowed", http.StatusMethodNotAllowed)
			return
		}
		key := strings.TrimPrefix(r.URL.Path, "/")
		data, err := b.GetObject(r.Context(), key)
		switch {
		case errors.Is(err, ports.ErrNotFound), errors.Is(err, ports.ErrBadKey):
			http.NotFound(w, r)
			return
		case err != nil:
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		cacheControl, err := b.CacheControl(r.Context(), key)
		if err != nil {
			http.Error(w, "internal error", http.StatusInternalServerError)
			return
		}
		h := w.Header()
		if cacheControl != "" {
			h.Set("Cache-Control", cacheControl)
		}
		h.Set("X-Content-Type-Options", "nosniff")
		if strings.HasSuffix(key, ".json") {
			h.Set("Content-Type", "application/json")
		} else {
			h.Set("Content-Type", "application/octet-stream")
		}
		http.ServeContent(w, r, "", time.Time{}, bytes.NewReader(data))
	})
}
