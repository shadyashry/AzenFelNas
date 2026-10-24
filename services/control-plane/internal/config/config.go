// Package config is the control plane's one typed configuration, loaded once
// from the environment in cmd/api (DESIGN.md §17.5, §15 D86).
package config

import (
	"errors"
	"fmt"
	"strconv"
	"strings"
)

// Environment is the deployment channel.
type Environment string

// Environment values.
const (
	EnvDev        Environment = "dev"
	EnvLab        Environment = "lab"
	EnvBeta       Environment = "beta"
	EnvProduction Environment = "production"
)

// StoreKind selects the storage adapter.
type StoreKind string

// StoreKind values.
const (
	StorePostgres StoreKind = "postgres"
	StoreMemory   StoreKind = "memory"
)

// Config is the whole configuration.
type Config struct {
	Env         Environment
	Addr        string
	Store       StoreKind
	DatabaseURL string
	GCPProject  string
	// TraceSampleRatio is the share of root traces exported (0..1). Trace ids
	// exist on every request regardless (REQ-API-001).
	TraceSampleRatio float64

	AndroidPackage    string
	AndroidCertSHA256 []string

	IOSAppID string
	// AppAttestRootPEM is the Apple App Attestation Root CA, owner-supplied.
	AppAttestRootPEM string
	// AppAttestDevelopment accepts development-environment App Attest keys.
	AppAttestDevelopment bool
}

// ErrInvalid wraps every configuration error.
var ErrInvalid = errors.New("config: invalid")

// Load reads the configuration with getenv (os.Getenv in main).
func Load(getenv func(string) string) (Config, error) {
	c := Config{
		Env:               Environment(or(getenv("DM_ENV"), string(EnvDev))),
		Addr:              or(getenv("DM_HTTP_ADDR"), ":"+or(getenv("PORT"), "8080")),
		Store:             StoreKind(or(getenv("DM_STORE"), string(StorePostgres))),
		DatabaseURL:       getenv("DM_DATABASE_URL"),
		GCPProject:        getenv("DM_GCP_PROJECT"),
		AndroidPackage:    getenv("DM_ANDROID_PACKAGE"),
		AndroidCertSHA256: list(getenv("DM_ANDROID_CERT_SHA256")),
		IOSAppID:          getenv("DM_IOS_APP_ID"),
		AppAttestRootPEM:  getenv("DM_APPATTEST_ROOT_CA_PEM"),
	}
	var errs []error
	switch c.Env {
	case EnvDev, EnvLab, EnvBeta, EnvProduction:
	default:
		errs = append(errs, fmt.Errorf("DM_ENV %q", c.Env))
	}
	switch c.Store {
	case StorePostgres:
		if c.DatabaseURL == "" {
			errs = append(errs, errors.New("DM_DATABASE_URL is required with DM_STORE=postgres"))
		}
	case StoreMemory:
		if c.Env == EnvBeta || c.Env == EnvProduction {
			errs = append(errs, errors.New("DM_STORE=memory is for dev and lab only"))
		}
	default:
		errs = append(errs, fmt.Errorf("DM_STORE %q", c.Store))
	}
	ratio, err := strconv.ParseFloat(or(getenv("DM_TRACE_SAMPLE_RATIO"), "0.1"), 64)
	if err != nil || ratio < 0 || ratio > 1 {
		errs = append(errs, errors.New("DM_TRACE_SAMPLE_RATIO must be in [0, 1]"))
	}
	c.TraceSampleRatio = ratio
	switch v := or(getenv("DM_APPATTEST_ENVIRONMENT"), "production"); v {
	case "production":
	case "development":
		if c.Env == EnvProduction {
			errs = append(errs, errors.New("development App Attest keys are not accepted in production"))
		}
		c.AppAttestDevelopment = true
	default:
		errs = append(errs, fmt.Errorf("DM_APPATTEST_ENVIRONMENT %q", v))
	}
	if len(errs) > 0 {
		return Config{}, fmt.Errorf("%w: %w", ErrInvalid, errors.Join(errs...))
	}
	return c, nil
}

func or(v, fallback string) string {
	if v == "" {
		return fallback
	}
	return v
}

func list(v string) []string {
	var out []string
	for item := range strings.SplitSeq(v, ",") {
		if item = strings.TrimSpace(item); item != "" {
			out = append(out, item)
		}
	}
	return out
}
