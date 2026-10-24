package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"net"
	"net/http"
	"strings"
	"time"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/cdnstandin"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/fsrepo"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/keyfiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/localbucket"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/s3bucket"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/app"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

const (
	// defaultBucket is the local distribution bucket (gitignored, §15 D65).
	defaultBucket = "dist"
	// defaultServeAddr serves the local bucket on loopback only.
	defaultServeAddr = "127.0.0.1:8787"
	// Timeouts of the local CDN stand-in.
	serveHeaderTimeout = 5 * time.Second
	serveIOTimeout     = 30 * time.Second
	serveShutdown      = 5 * time.Second
)

// errDevKeyChannelsOnly: the dev keys publish to dev and lab only; beta and
// production wait for the S27 production keys (§15 D65, D85).
var errDevKeyChannelsOnly = errors.New("publishing is limited to the dev and lab channels until the S27 production keys (§15 D65, D85)")

// errBucketSpec is returned for a -bucket value that names no bucket.
var errBucketSpec = errors.New("bucket must be a directory or s3://<bucket>[/<prefix>]")

const bucketUsage = "distribution bucket: a local directory, or s3://<bucket>[/<prefix>] (R2) with " +
	s3EnvPrefix + "ENDPOINT, " + s3EnvPrefix + "ACCESS_KEY_ID, " + s3EnvPrefix + "SECRET_ACCESS_KEY and, for a loopback test server only, " + s3EnvPrefix + "INSECURE=1"

// s3EnvPrefix names the variables that configure an s3:// bucket; CI sets
// them from the environment's R2 token (§15 D85).
const s3EnvPrefix = "DM_S3_"

// bucketStore is what the distribution commands need from a bucket.
type bucketStore interface {
	ports.ObjectStore
	cdnstandin.Store
}

// openBucket maps -bucket to an adapter: s3://… is R2 (or a test server),
// anything else a local directory.
func openBucket(spec string, e env) (bucketStore, error) {
	rest, ok := strings.CutPrefix(spec, "s3://")
	if !ok {
		if spec == "" {
			return nil, errBucketSpec
		}
		return localbucket.Bucket{Dir: spec}, nil
	}
	name, prefix, _ := strings.Cut(rest, "/")
	if name == "" {
		return nil, errBucketSpec
	}
	get := func(key string) string {
		v, _ := e.lookup(s3EnvPrefix + key)
		return v
	}
	return s3bucket.New(s3bucket.Config{
		Endpoint:        get("ENDPOINT"),
		Bucket:          name,
		Prefix:          prefix,
		AccessKeyID:     get("ACCESS_KEY_ID"),
		SecretAccessKey: get("SECRET_ACCESS_KEY"),
		Insecure:        get("INSECURE") == "1",
	})
}

func runPull(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("pull", flag.ContinueOnError)
	repo := fs.String("repo", "", "channel repository directory to restore (empty, or equal to the published channel)")
	channelName := fs.String("channel", "", "published channel to pull")
	bucket := fs.String("bucket", defaultBucket, bucketUsage)
	rootKeys := fs.String("root-keys", defaultRootKeys, "trusted root keys the published channel must verify against")
	if !parseFlags(fs, args, e, "repo", "channel") {
		return exitUsage
	}
	channel, err := profileset.ParseChannel(*channelName)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	objects, err := openBucket(*bucket, e)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	store := fsrepo.Repo{Dir: *repo}
	pulled, err := app.PullChannel{
		Published: app.BucketChain{Anchor: keyfiles.TrustAnchor{File: *rootKeys}, Store: objects, Clock: e.clock},
		Reader:    store, Writer: store, Packages: store,
	}.Run(ctx, channel)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	if pulled.Fresh {
		write(e.stdout, fmt.Sprintf("pulled: %s was never published; the first release starts at sequence 1\n", channel))
		return exitOK
	}
	s := pulled.Sequences
	write(e.stdout, fmt.Sprintf("pulled: %s timestamp %d, snapshot %d, targets %d; %d target(s)\n", channel, s.Timestamp, s.Snapshot, s.Targets, pulled.Targets))
	return exitOK
}

func runPromote(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("promote", flag.ContinueOnError)
	repo := fs.String("repo", "", "repository of the destination channel (pulled first)")
	from := fs.String("from", "", "published source channel")
	to := fs.String("to", "", "destination channel, the one above -from")
	sequence := fs.Int("sequence", 0, "the source targets sequence that was reviewed")
	bucket := fs.String("bucket", defaultBucket, bucketUsage)
	rootKeys := fs.String("root-keys", defaultRootKeys, "trusted root keys the source channel must verify against")
	if !parseFlags(fs, args, e, "repo", "from", "to") {
		return exitUsage
	}
	source, err := profileset.ParseChannel(*from)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	destination, err := profileset.ParseChannel(*to)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	if destination != profileset.ChannelDev && destination != profileset.ChannelLab {
		return usageError(e, fs.Name(), errDevKeyChannelsOnly)
	}
	if *sequence < 1 {
		return usageError(e, fs.Name(), errors.New("-sequence must be the reviewed targets sequence (≥ 1)"))
	}
	objects, err := openBucket(*bucket, e)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	store := fsrepo.Repo{Dir: *repo}
	staged, err := app.PromoteChannel{
		Source:   app.BucketChain{Anchor: keyfiles.TrustAnchor{File: *rootKeys}, Store: objects, Clock: e.clock},
		Packages: store, Stager: store,
	}.Run(ctx, app.Promotion{From: source, To: destination, Sequence: *sequence})
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	write(e.stdout, fmt.Sprintf("staged for %s from %s targets %d: %s; sign targets, snapshot and timestamp, then publish\n",
		destination, source, *sequence, strings.Join(staged, ", ")))
	return exitOK
}

func runPublish(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("publish", flag.ContinueOnError)
	repo := fs.String("repo", "", "signed channel repository directory")
	channelName := fs.String("channel", "", "channel to publish to: dev or lab")
	bucket := fs.String("bucket", defaultBucket, bucketUsage)
	rootKeys := fs.String("root-keys", defaultRootKeys, "trusted root keys the repository must verify against")
	if !parseFlags(fs, args, e, "repo", "channel") {
		return exitUsage
	}
	channel, err := profileset.ParseChannel(*channelName)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	if channel != profileset.ChannelDev && channel != profileset.ChannelLab {
		return usageError(e, fs.Name(), errDevKeyChannelsOnly)
	}
	objects, err := openBucket(*bucket, e)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	store := fsrepo.Repo{Dir: *repo}
	published, err := app.PublishChannel{
		Verify:   app.VerifyRepository{Anchor: keyfiles.TrustAnchor{File: *rootKeys}, Reader: store, Packages: store, Clock: e.clock},
		Reader:   store,
		Packages: store,
		Store:    objects,
	}.Run(ctx, channel)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	roles := make([]string, 0, len(published.Roles))
	for _, r := range published.Roles {
		roles = append(roles, string(r))
	}
	write(e.stdout, fmt.Sprintf("published to %s/%s: %d package(s) [%s], metadata [%s]\n",
		*bucket, channel, len(published.Packages), strings.Join(published.Packages, ", "), strings.Join(roles, ", ")))
	return exitOK
}

func runServe(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("serve", flag.ContinueOnError)
	bucket := fs.String("bucket", defaultBucket, bucketUsage)
	addr := fs.String("addr", defaultServeAddr, "listen address")
	if !parseFlags(fs, args, e) {
		return exitUsage
	}
	objects, err := openBucket(*bucket, e)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	listener, err := (&net.ListenConfig{}).Listen(ctx, "tcp", *addr)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	server := &http.Server{
		Handler:           cdnstandin.Handler(objects),
		ReadHeaderTimeout: serveHeaderTimeout,
		ReadTimeout:       serveIOTimeout,
		WriteTimeout:      serveIOTimeout,
		IdleTimeout:       serveIOTimeout,
	}
	write(e.stdout, fmt.Sprintf("serving %s at http://%s/ (Ctrl+C stops)\n", *bucket, listener.Addr()))
	done := make(chan error, 1)
	go func() { done <- server.Serve(listener) }()
	select {
	case err := <-done:
		return fail(e, fs.Name(), err)
	case <-ctx.Done():
		shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), serveShutdown)
		defer cancel()
		if err := server.Shutdown(shutdownCtx); err != nil {
			return fail(e, fs.Name(), err)
		}
		return exitOK
	}
}
