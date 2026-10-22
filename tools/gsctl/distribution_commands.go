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

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/fsrepo"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/keyfiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/localbucket"
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
// production wait for the S25 bucket and the S27 production keys.
var errDevKeyChannelsOnly = errors.New("publishing is limited to the dev and lab channels until S25/S27 (§15 D65)")

func runPublish(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("publish", flag.ContinueOnError)
	repo := fs.String("repo", "", "signed channel repository directory")
	channelName := fs.String("channel", "", "channel to publish to: dev or lab")
	bucket := fs.String("bucket", defaultBucket, "local distribution bucket directory")
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
	store := fsrepo.Repo{Dir: *repo}
	var objects ports.ObjectStore = localbucket.Bucket{Dir: *bucket}
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
	bucket := fs.String("bucket", defaultBucket, "local distribution bucket directory")
	addr := fs.String("addr", defaultServeAddr, "listen address")
	if !parseFlags(fs, args, e) {
		return exitUsage
	}
	listener, err := (&net.ListenConfig{}).Listen(ctx, "tcp", *addr)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	server := &http.Server{
		Handler:           localbucket.Bucket{Dir: *bucket}.Handler(),
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
