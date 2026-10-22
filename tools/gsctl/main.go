// Command gsctl validates and compiles prayer profiles into signed
// packages and signs and verifies TUF-lite metadata (DESIGN.md §9.1–§9.2,
// Appendix C, ADR-008, ADR-009). This file and commands.go are the
// composition root: they parse flags into typed requests, wire adapters to
// use cases and map errors to exit codes. publish and serve use a local
// bucket until the distribution infrastructure (S25) adds R2 and promotion.
package main

import (
	"context"
	"errors"
	"flag"
	"fmt"
	"io"
	"os"
	"os/signal"
	"strings"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/adapters/sysclock"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/profileset"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/domain/trust"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/ports"
)

// Exit codes.
const (
	exitOK     = 0
	exitFailed = 1
	exitUsage  = 2
)

const usage = `usage: gsctl <command> [flags]

commands:
  validate      check profiles/*/*.yaml for a channel
  check-change  refuse a PR that changes an angle and tz/coordinate data together (§9.2)
  build         package prayer_profiles (compiled profiles) or tzdata (the pipeline's payload) and stage its target
  sign          sign one role: root, targets (adds staged targets), snapshot or timestamp
  verify        verify a channel's metadata chain and packages as a client would
  publish       verify a signed channel and copy it into the local distribution bucket (dev, lab)
  serve         serve the local bucket over HTTP the way the CDN serves R2

Run "gsctl <command> -h" for the flags of a command.
`

// env is what the process provides beyond its arguments.
type env struct {
	lookup         func(string) (string, bool)
	clock          ports.Clock
	stdout, stderr io.Writer
}

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt)
	code := run(ctx, os.Args[1:], env{lookup: os.LookupEnv, clock: sysclock.Clock{}, stdout: os.Stdout, stderr: os.Stderr})
	stop()
	os.Exit(code)
}

// run executes one gsctl command and returns the process exit code.
func run(ctx context.Context, args []string, e env) int {
	if len(args) == 0 {
		write(e.stderr, usage)
		return exitUsage
	}
	commands := map[string]func(context.Context, []string, env) int{
		"validate":     runValidate,
		"check-change": runCheckChange,
		"build":        runBuild,
		"sign":         runSign,
		"verify":       runVerify,
		"publish":      runPublish,
		"serve":        runServe,
	}
	cmd, ok := commands[args[0]]
	if !ok {
		write(e.stderr, fmt.Sprintf("gsctl: unknown command %q\n\n%s", args[0], usage))
		return exitUsage
	}
	return cmd(ctx, args[1:], e)
}

// parseFlags parses args into fs, which reports its own errors; required
// lists flags that must not be empty.
func parseFlags(fs *flag.FlagSet, args []string, e env, required ...string) bool {
	fs.SetOutput(e.stderr)
	if err := fs.Parse(args); err != nil {
		return false
	}
	if fs.NArg() > 0 {
		write(e.stderr, fmt.Sprintf("gsctl %s: unexpected argument %q\n", fs.Name(), fs.Arg(0)))
		return false
	}
	for _, name := range required {
		if f := fs.Lookup(name); f == nil || f.Value.String() == "" {
			write(e.stderr, fmt.Sprintf("gsctl %s: -%s is required\n", fs.Name(), name))
			return false
		}
	}
	return true
}

// fail reports err for cmd with its Appendix J code, when it has one, and
// returns the exit code.
func fail(e env, cmd string, err error) int {
	var invalid *profileset.ValidationError
	if errors.As(err, &invalid) {
		for _, p := range invalid.Problems {
			write(e.stderr, fmt.Sprintf("gsctl %s: PROFILE_INVALID: %s: %s\n", cmd, p.Path, p.Message))
		}
		return exitFailed
	}
	prefix := ""
	if code := trust.Code(err); code != "" {
		prefix = code + ": "
	}
	write(e.stderr, fmt.Sprintf("gsctl %s: %s%v\n", cmd, prefix, err))
	return exitFailed
}

func usageError(e env, cmd string, err error) int {
	write(e.stderr, fmt.Sprintf("gsctl %s: %v\n", cmd, err))
	return exitUsage
}

// write prints s; a failed write to the terminal cannot be reported
// anywhere else, so it is dropped.
func write(w io.Writer, s string) {
	_, _ = io.WriteString(w, s) // nothing left to report a write failure to
}

func lines(parts ...string) string { return strings.Join(parts, "\n") + "\n" }
