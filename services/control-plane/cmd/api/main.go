// Command api is the composition root of the Daily Muslim control plane
// (DESIGN.md §9.3, ADR-010): the only place that wires adapters to ports.
//
//	api serve    serve /v1 on DM_HTTP_ADDR (default :$PORT)
//	api migrate  apply the goose migrations (the deploy job)
//	api purge    delete rows past their retention (hourly job, REQ-DATA-002)
package main

import (
	"context"
	"crypto/rand"
	"crypto/x509"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/rs/zerolog"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/attest"
	httpadapter "github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/http"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/memory"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/postgres"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/app"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/config"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

func main() {
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	code := run(ctx, os.Args[1:], os.Getenv, os.Stderr)
	stop()
	os.Exit(code)
}

// run executes one subcommand and returns the process exit code.
func run(ctx context.Context, args []string, getenv func(string) string, stderr io.Writer) int {
	log := zerolog.New(stderr).With().Timestamp().Logger().Hook(severityHook{})
	cmd := "serve"
	if len(args) > 0 {
		cmd = args[0]
	}
	cfg, err := config.Load(getenv)
	if err != nil {
		log.Error().Err(err).Msg("configuration")
		return 2
	}
	switch cmd {
	case "serve":
		err = serve(ctx, cfg, log)
	case "migrate":
		err = migrate(ctx, cfg)
	case "purge":
		err = purge(ctx, cfg, log)
	default:
		err = fmt.Errorf("unknown command %q (serve, migrate, purge)", cmd)
	}
	if err != nil {
		log.Error().Err(err).Str("command", cmd).Msg("failed")
		return 1
	}
	return 0
}

type systemClock struct{}

func (systemClock) Now() time.Time { return time.Now().UTC() }

// storage is what one storage adapter provides to the use cases.
type storage interface {
	ports.CorrectionStore
	ports.TelemetryStore
	ports.EvidenceStore
	ports.SaltSource
	ports.RateLimiter
	ports.AttestedKeyStore
	ports.IdempotencyStore
	ports.Purger
	ports.Pinger
}

// openStore returns the configured storage adapter and its closer.
func openStore(ctx context.Context, cfg config.Config) (storage, func(), error) {
	switch cfg.Store {
	case config.StoreMemory:
		return memory.New(), func() {}, nil
	case config.StorePostgres:
		s, err := postgres.Open(ctx, cfg.DatabaseURL)
		if err != nil {
			return nil, nil, err
		}
		return s, s.Close, nil
	default:
		return nil, nil, fmt.Errorf("store %q", cfg.Store)
	}
}

func migrate(ctx context.Context, cfg config.Config) error {
	if cfg.Store != config.StorePostgres {
		return errors.New("migrate needs DM_STORE=postgres")
	}
	return postgres.Migrate(ctx, cfg.DatabaseURL)
}

func purge(ctx context.Context, cfg config.Config, log zerolog.Logger) error {
	store, closeStore, err := openStore(ctx, cfg)
	if err != nil {
		return err
	}
	defer closeStore()
	n, err := app.PurgeExpired{Purger: store, Clock: systemClock{}}.Execute(ctx)
	if err != nil {
		return err
	}
	log.Info().Int64("corrections", n.Corrections).Int64("telemetry", n.Telemetry).Int64("pseudonyms", n.Pseudonyms).
		Int64("idempotency", n.Idempotency).Int64("salts", n.Salts).Msg("purged")
	return nil
}

// verifier wires the platform verifiers; a platform without configuration fails closed.
func verifier(cfg config.Config, keys ports.AttestedKeyStore, clock ports.Clock) (ports.AttestationVerifier, error) {
	v := attest.ByPlatform{
		Android: attest.Unconfigured{Reason: "DM_ANDROID_PACKAGE not set"},
		IOS:     attest.Unconfigured{Reason: "DM_IOS_APP_ID or DM_APPATTEST_ROOT_CA_PEM not set"},
	}
	client := &http.Client{Timeout: 3 * time.Second}
	if cfg.AndroidPackage != "" {
		v.Android = attest.PlayIntegrity{
			PackageName: cfg.AndroidPackage, CertSHA256: cfg.AndroidCertSHA256,
			Tokens: &attest.MetadataTokens{Client: client}, Client: client, Clock: clock,
		}
	}
	if cfg.IOSAppID != "" && cfg.AppAttestRootPEM != "" {
		roots := x509.NewCertPool()
		if !roots.AppendCertsFromPEM([]byte(cfg.AppAttestRootPEM)) {
			return nil, errors.New("DM_APPATTEST_ROOT_CA_PEM holds no certificate")
		}
		aaguid := attest.AAGUIDProduction
		if cfg.AppAttestDevelopment {
			aaguid = attest.AAGUIDDevelopment
		}
		v.IOS = attest.AppAttest{AppID: cfg.IOSAppID, Roots: roots, AAGUID: aaguid, Keys: keys, Clock: clock}
	}
	return v, nil
}

func serve(ctx context.Context, cfg config.Config, log zerolog.Logger) error {
	store, closeStore, err := openStore(ctx, cfg)
	if err != nil {
		return err
	}
	defer closeStore()
	obs, err := newObservability(ctx, cfg.TraceSampleRatio, string(cfg.Env))
	if err != nil {
		return err
	}
	defer func() {
		shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 5*time.Second)
		defer cancel()
		if err := obs.shutdown(shutdownCtx); err != nil {
			log.Warn().Err(err).Msg("telemetry shutdown")
		}
	}()
	validator, err := validate.New()
	if err != nil {
		return err
	}
	clock := systemClock{}
	verify, err := verifier(cfg, store, clock)
	if err != nil {
		return err
	}
	handler := httpadapter.NewHandler(httpadapter.Deps{
		Validator: validator,
		Corrections: app.SubmitCorrection{
			Verifier: verify, Salts: store, Limiter: store, Store: store, Clock: clock, Random: rand.Reader,
		},
		Telemetry:   app.RecordTelemetry{Verifier: verify, Salts: store, Store: store, Clock: clock},
		Evidence:    app.GetEvidence{Store: store},
		Idempotency: store,
		Ready:       store,
		Clock:       clock,
		Log:         log,
		Tracer:      obs.tracer,
		Meter:       obs.meter,
		GCPProject:  cfg.GCPProject,
	})
	srv := &http.Server{
		Addr:              cfg.Addr,
		Handler:           handler,
		ReadHeaderTimeout: 2 * time.Second,
		ReadTimeout:       httpadapter.RequestTimeout,
		WriteTimeout:      httpadapter.RequestTimeout + time.Second,
		IdleTimeout:       60 * time.Second,
		MaxHeaderBytes:    32 << 10,
	}
	errs := make(chan error, 1)
	go func() { errs <- srv.ListenAndServe() }()
	log.Info().Str("addr", cfg.Addr).Str("env", string(cfg.Env)).Str("store", string(cfg.Store)).Msg("serving")
	select {
	case err := <-errs:
		return fmt.Errorf("listen: %w", err)
	case <-ctx.Done():
	}
	shutdownCtx, cancel := context.WithTimeout(context.WithoutCancel(ctx), 10*time.Second)
	defer cancel()
	if err := srv.Shutdown(shutdownCtx); err != nil {
		return fmt.Errorf("shutdown: %w", err)
	}
	if err := <-errs; !errors.Is(err, http.ErrServerClosed) {
		return fmt.Errorf("listen: %w", err)
	}
	return nil
}

// severityHook adds the Cloud Logging severity field.
type severityHook struct{}

func (severityHook) Run(e *zerolog.Event, level zerolog.Level, _ string) {
	severity := map[zerolog.Level]string{
		zerolog.DebugLevel: "DEBUG", zerolog.InfoLevel: "INFO", zerolog.WarnLevel: "WARNING",
		zerolog.ErrorLevel: "ERROR", zerolog.FatalLevel: "CRITICAL", zerolog.PanicLevel: "ALERT",
	}[level]
	if severity != "" {
		e.Str("severity", severity)
	}
}
