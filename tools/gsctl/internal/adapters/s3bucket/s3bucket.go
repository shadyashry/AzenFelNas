// Package s3bucket is the distribution bucket (§9.1) on an S3-compatible
// object store: Cloudflare R2 in every environment (ADR-022), MinIO in the
// adapter tests (§15 D85). It implements ports.ObjectStore and the CDN
// stand-in's Store, so `gsctl publish`, `pull`, `promote` and `serve` work
// against R2 exactly as against the local bucket.
package s3bucket

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"io"
	"net"
	"net/http"
	"strings"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/distribution"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// MaxObjectBytes bounds what GetObject reads: ten times the largest §9.5
// payload, so a wrong key can never exhaust memory.
const MaxObjectBytes = 64 << 20

// Region is the region R2 expects in every SigV4 signature.
const Region = "auto"

var (
	// ErrConfig is returned for an incomplete or unsafe configuration.
	ErrConfig = errors.New("s3bucket: bad configuration")
	// ErrTooLarge is returned for an object above MaxObjectBytes.
	ErrTooLarge = errors.New("s3bucket: object too large")
)

// Config locates the bucket. Endpoint is host[:port] without a scheme
// (`<account>.r2.cloudflarestorage.com`); Prefix, when set, is prepended to
// every key. Insecure (plain HTTP) is accepted for a loopback endpoint only.
type Config struct {
	Endpoint        string
	Bucket          string
	Prefix          string
	AccessKeyID     string
	SecretAccessKey string
	Insecure        bool
}

// Bucket is one S3 bucket.
type Bucket struct {
	client *minio.Client
	bucket string
	prefix string
}

// New checks cfg and builds the client; it does not contact the endpoint.
func New(cfg Config) (Bucket, error) {
	switch {
	case cfg.Endpoint == "" || strings.Contains(cfg.Endpoint, "/"):
		return Bucket{}, fmt.Errorf("%w: endpoint %q must be host[:port]", ErrConfig, cfg.Endpoint)
	case cfg.Bucket == "":
		return Bucket{}, fmt.Errorf("%w: no bucket", ErrConfig)
	case cfg.AccessKeyID == "" || cfg.SecretAccessKey == "":
		return Bucket{}, fmt.Errorf("%w: credentials missing", ErrConfig)
	case cfg.Insecure && !isLoopback(cfg.Endpoint):
		return Bucket{}, fmt.Errorf("%w: plain HTTP only to a loopback endpoint", ErrConfig)
	}
	prefix := strings.Trim(cfg.Prefix, "/")
	if prefix != "" {
		if err := distribution.CheckKey(prefix); err != nil {
			return Bucket{}, fmt.Errorf("%w: prefix: %w", ErrConfig, err)
		}
		prefix += "/"
	}
	client, err := minio.New(cfg.Endpoint, &minio.Options{
		Creds:        credentials.NewStaticV4(cfg.AccessKeyID, cfg.SecretAccessKey, ""),
		Secure:       !cfg.Insecure,
		Region:       Region,
		BucketLookup: minio.BucketLookupPath,
	})
	if err != nil {
		return Bucket{}, fmt.Errorf("%w: %w", ErrConfig, err)
	}
	return Bucket{client: client, bucket: cfg.Bucket, prefix: prefix}, nil
}

// GetObject implements ports.ObjectStore.
func (b Bucket) GetObject(ctx context.Context, key string) ([]byte, error) {
	name, err := b.name(key)
	if err != nil {
		return nil, err
	}
	object, err := b.client.GetObject(ctx, b.bucket, name, minio.GetObjectOptions{})
	if err != nil {
		return nil, b.mapError(key, err)
	}
	defer object.Close() //nolint:errcheck // read-only stream; the read error is what matters
	data, err := io.ReadAll(io.LimitReader(object, MaxObjectBytes+1))
	if err != nil {
		return nil, b.mapError(key, err)
	}
	if len(data) > MaxObjectBytes {
		return nil, fmt.Errorf("%w: %s", ErrTooLarge, key)
	}
	return data, nil
}

// PutObject implements ports.ObjectStore: one single-part upload with the
// object's Cache-Control and content type.
func (b Bucket) PutObject(ctx context.Context, key string, data []byte, cacheControl string) error {
	name, err := b.name(key)
	if err != nil {
		return err
	}
	_, err = b.client.PutObject(ctx, b.bucket, name, bytes.NewReader(data), int64(len(data)), minio.PutObjectOptions{
		CacheControl:     cacheControl,
		ContentType:      contentType(key),
		DisableMultipart: true,
	})
	if err != nil {
		return fmt.Errorf("put %s: %w", key, err)
	}
	return nil
}

// CacheControl returns the Cache-Control an object was stored with.
func (b Bucket) CacheControl(ctx context.Context, key string) (string, error) {
	name, err := b.name(key)
	if err != nil {
		return "", err
	}
	info, err := b.client.StatObject(ctx, b.bucket, name, minio.StatObjectOptions{})
	if err != nil {
		return "", b.mapError(key, err)
	}
	return info.Metadata.Get("Cache-Control"), nil
}

func (b Bucket) name(key string) (string, error) {
	if err := distribution.CheckKey(key); err != nil {
		return "", fmt.Errorf("s3bucket: %w", err)
	}
	return b.prefix + key, nil
}

func (b Bucket) mapError(key string, err error) error {
	response := minio.ToErrorResponse(err)
	if response.StatusCode == http.StatusNotFound || response.Code == "NoSuchKey" {
		return fmt.Errorf("%s: %w", key, ports.ErrNotFound)
	}
	return fmt.Errorf("get %s: %w", key, err)
}

func contentType(key string) string {
	if strings.HasSuffix(key, ".json") {
		return "application/json"
	}
	return "application/octet-stream"
}

func isLoopback(endpoint string) bool {
	host, _, err := net.SplitHostPort(endpoint)
	if err != nil {
		host = endpoint
	}
	if host == "localhost" {
		return true
	}
	ip := net.ParseIP(host)
	return ip != nil && ip.IsLoopback()
}
