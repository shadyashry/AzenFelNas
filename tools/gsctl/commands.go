package main

import (
	"context"
	"flag"
	"fmt"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/changelist"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/fsrepo"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/keyfiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/localbucket"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/pemkeys"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/sysclock"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/yamlprofiles"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/app"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

// Defaults are relative to the repository root, where CI runs gsctl.
const (
	defaultProfiles = "profiles"
	defaultKeys     = "tools/gsctl/keys/dev"
	defaultRootKeys = "tools/gsctl/keys/dev/root-keys.json"
	// devKeyEnvPrefix names the CI secrets of the dev keys
	// (tools/gsctl/keys/dev/README.md).
	devKeyEnvPrefix = "DM_DEV_"
)

func runValidate(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("validate", flag.ContinueOnError)
	profiles := fs.String("profiles", defaultProfiles, "profiles directory (<iso2|engine>/<profileId>.yaml)")
	channelName := fs.String("channel", "", "channel the set must be valid for: dev, lab, beta or production")
	if !parseFlags(fs, args, e, "channel") {
		return exitUsage
	}
	channel, err := profileset.ParseChannel(*channelName)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	set, err := app.ValidateProfiles{Source: yamlprofiles.Source{Dir: *profiles}}.Run(ctx, channel)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	write(e.stdout, fmt.Sprintf("valid: %d profile(s) for %s; payload %d bytes; compat minApp %s, minEngineSchema %d\n",
		len(set.Profiles), channel, len(set.Payload), set.Compat.MinApp, set.Compat.MinEngineSchema))
	return exitOK
}

func runCheckChange(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("check-change", flag.ContinueOnError)
	base := fs.String("base-profiles", "", "profiles directory of the PR's base")
	profiles := fs.String("profiles", defaultProfiles, "profiles directory of the PR's head")
	changed := fs.String("changed", "", "file listing the paths the PR changes, one per line (git diff --name-only)")
	if !parseFlags(fs, args, e, "base-profiles", "changed") {
		return exitUsage
	}
	err := app.CheckProfileChange{
		Base: yamlprofiles.Source{Dir: *base}, Head: yamlprofiles.Source{Dir: *profiles}, Changes: changelist.File{Path: *changed},
	}.Run(ctx)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	write(e.stdout, "ok: no angle change together with tz/coordinate data (§9.2)\n")
	return exitOK
}

func runBuild(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("build", flag.ContinueOnError)
	profiles := fs.String("profiles", defaultProfiles, "profiles directory")
	channelName := fs.String("channel", "", "channel the set must be valid for: dev, lab, beta or production")
	repo := fs.String("repo", "", "channel repository directory (metadata/, packages/, staged/)")
	version := fs.String("version", "", "package version, the <version> of the target name prayer_profiles/<version>")
	effectiveFrom := fs.String("effective-from", "", "date (YYYY-MM-DD) the release takes effect for all users (REQ-GOV-004)")
	noteAr := fs.String("note-ar", "", "change note in Arabic")
	noteEn := fs.String("note-en", "", "change note in English")
	priority := fs.String("priority", string(tuf.PriorityNormal), "normal or urgent")
	rollbackOf := fs.String("rollback-of", "", "version this release rolls back (REQ-DIST-002)")
	if !parseFlags(fs, args, e, "channel", "repo", "version", "effective-from", "note-ar", "note-en") {
		return exitUsage
	}
	channel, err := profileset.ParseChannel(*channelName)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	store := fsrepo.Repo{Dir: *repo}
	built, err := app.BuildProfilesPackage{
		Source: yamlprofiles.Source{Dir: *profiles}, Packages: store, Stager: store,
	}.Run(ctx, app.BuildRequest{Channel: channel, Release: profileset.Release{
		Version: *version, EffectiveFrom: *effectiveFrom, Priority: tuf.Priority(*priority),
		ChangeNote: tuf.ChangeNote{Ar: *noteAr, En: *noteEn}, RollbackOf: *rollbackOf,
	}})
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	write(e.stdout, lines(
		fmt.Sprintf("built: %s from %d profile(s), %d bytes, sha256 %s", built.Name, built.Profiles, built.Target.Length, built.Target.SHA256),
		"staged: sign the targets, snapshot and timestamp roles to publish it",
	))
	return exitOK
}

func runSign(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("sign", flag.ContinueOnError)
	repo := fs.String("repo", "", "channel repository directory")
	roleName := fs.String("role", "", "role to sign: root, targets, snapshot or timestamp")
	keys := fs.String("keys", defaultKeys, "public key set: roles.json and <name>.pub.hex")
	keyDir := fs.String("key-dir", "", "directory of <name>.pem private keys (gitignored); default: "+devKeyEnvPrefix+"<ROLE>_KEY_<N> variables")
	sequence := fs.Int("sequence", 0, "sequence to sign (the version, for root); default previous + 1")
	lifetime := fs.Duration("expires-in", 0, "lifetime; default root 8760h, targets 2160h, snapshot 720h, timestamp 168h (the maximum)")
	if !parseFlags(fs, args, e, "repo", "role") {
		return exitUsage
	}
	role, err := trust.ParseRoleName(*roleName)
	if err != nil {
		return usageError(e, fs.Name(), err)
	}
	var ring ports.KeyRing = pemkeys.Env{Prefix: devKeyEnvPrefix, Lookup: e.lookup}
	if *keyDir != "" {
		ring = pemkeys.Dir{Dir: *keyDir}
	}
	store := fsrepo.Repo{Dir: *repo}
	config := keyfiles.KeyConfig{Dir: *keys}
	req := app.SignRequest{Sequence: *sequence, Lifetime: *lifetime}
	var signed app.SignedRole
	switch role {
	case trust.RoleRoot:
		signed, err = app.SignRoot{Keys: config, Ring: ring, Reader: store, Writer: store, Clock: e.clock}.Run(ctx, req)
	case trust.RoleTargets:
		signed, err = app.SignTargets{Keys: config, Ring: ring, Reader: store, Writer: store, Staged: store, Clock: e.clock}.Run(ctx, req)
	case trust.RoleSnapshot:
		signed, err = app.SignSnapshot{Keys: config, Ring: ring, Reader: store, Writer: store, Clock: e.clock}.Run(ctx, req)
	case trust.RoleTimestamp:
		signed, err = app.SignTimestamp{Keys: config, Ring: ring, Reader: store, Writer: store, Clock: e.clock}.Run(ctx, req)
	}
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	write(e.stdout, fmt.Sprintf("signed: %s sequence %d, %d signature(s), expires %s\n", signed.Role, signed.Sequence, signed.Signatures, signed.Expires))
	return exitOK
}

func runVerify(ctx context.Context, args []string, e env) int {
	fs := flag.NewFlagSet("verify", flag.ContinueOnError)
	repo := fs.String("repo", "", "channel repository directory")
	rootKeys := fs.String("root-keys", defaultRootKeys, "trusted root keys (root-keys.json), as embedded in the app")
	var after trust.Sequences
	fs.IntVar(&after.Timestamp, "after-timestamp", 0, "trusted timestamp sequence; the new one must be greater (REQ-PKG-005)")
	fs.IntVar(&after.Snapshot, "after-snapshot", 0, "trusted snapshot sequence; the new one must be greater")
	fs.IntVar(&after.Targets, "after-targets", 0, "trusted targets sequence; the new one must be greater")
	if !parseFlags(fs, args, e, "repo") {
		return exitUsage
	}
	store := fsrepo.Repo{Dir: *repo}
	verified, err := app.VerifyRepository{
		Anchor: keyfiles.TrustAnchor{File: *rootKeys}, Reader: store, Packages: store, Clock: e.clock,
	}.Run(ctx, after)
	if err != nil {
		return fail(e, fs.Name(), err)
	}
	s := verified.Chain.Sequences
	write(e.stdout, fmt.Sprintf("verified: root version %d, timestamp %d, snapshot %d, targets %d; %d target(s)\n",
		verified.Chain.Root.Version, s.Timestamp, s.Snapshot, s.Targets, len(verified.Targets)))
	for _, name := range verified.Targets {
		t := verified.Chain.Targets.Targets[name]
		write(e.stdout, fmt.Sprintf("target: %s %d bytes sha256 %s\n", name, t.Length, t.SHA256))
	}
	for _, w := range verified.Chain.Warnings {
		write(e.stdout, fmt.Sprintf("warning: PKG_EXPIRED_WARNING: %s expired %s (FRESHNESS_UNVERIFIED)\n", w.Role, trust.FormatExpires(w.Expires)))
	}
	return exitOK
}

// interface checks: the adapters implement the ports main wires them to.
var (
	_ ports.ProfileSource     = yamlprofiles.Source{}
	_ ports.ChangedPaths      = changelist.File{}
	_ ports.ObjectStore       = localbucket.Bucket{}
	_ ports.MetadataReader    = fsrepo.Repo{}
	_ ports.MetadataWriter    = fsrepo.Repo{}
	_ ports.PackageReader     = fsrepo.Repo{}
	_ ports.PackageWriter     = fsrepo.Repo{}
	_ ports.TargetStager      = fsrepo.Repo{}
	_ ports.StagedTargets     = fsrepo.Repo{}
	_ ports.KeyConfigSource   = keyfiles.KeyConfig{}
	_ ports.TrustAnchorSource = keyfiles.TrustAnchor{}
	_ ports.KeyRing           = pemkeys.Dir{}
	_ ports.KeyRing           = pemkeys.Env{}
	_ ports.Clock             = sysclock.Clock{}
)
