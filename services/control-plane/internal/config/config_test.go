package config_test

import (
	"errors"
	"testing"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/config"
)

func env(m map[string]string) func(string) string { return func(k string) string { return m[k] } }

func TestLoadDefaultsForCloudRun(t *testing.T) {
	c, err := config.Load(env(map[string]string{"DM_ENV": "production", "PORT": "9000", "DM_DATABASE_URL": "postgres://x", "DM_ANDROID_CERT_SHA256": "a, b"}))
	if err != nil {
		t.Fatal(err)
	}
	if c.Addr != ":9000" || c.Store != config.StorePostgres || c.TraceSampleRatio != 0.1 || len(c.AndroidCertSHA256) != 2 || c.AppAttestDevelopment {
		t.Fatalf("%+v", c)
	}
}

func TestLoadRejectsUnsafeCombinations(t *testing.T) {
	for name, vars := range map[string]map[string]string{
		"memory store in production":     {"DM_ENV": "production", "DM_STORE": "memory"},
		"postgres without url":           {"DM_ENV": "lab"},
		"development app attest in prod": {"DM_ENV": "production", "DM_DATABASE_URL": "x", "DM_APPATTEST_ENVIRONMENT": "development"},
		"unknown environment":            {"DM_ENV": "staging", "DM_STORE": "memory"},
		"sample ratio out of range":      {"DM_STORE": "memory", "DM_TRACE_SAMPLE_RATIO": "2"},
	} {
		t.Run(name, func(t *testing.T) {
			if _, err := config.Load(env(vars)); !errors.Is(err, config.ErrInvalid) {
				t.Fatalf("err = %v", err)
			}
		})
	}
}
