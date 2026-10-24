package domain_test

import (
	"bytes"
	"errors"
	"regexp"
	"testing"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/telemetry"
)

func TestREQPRIV001RoundedLocationAcceptsAtMostTwoDecimals(t *testing.T) {
	t.Parallel()
	for _, ok := range [][2]float64{{30.04, 31.24}, {30.07, -0.01}, {-90, 180}, {21.4, 39.8}} {
		if _, err := domain.NewRoundedLocation(ok[0], ok[1]); err != nil {
			t.Errorf("%v rejected: %v", ok, err)
		}
	}
	for _, bad := range [][2]float64{{30.044, 31.24}, {30.04, 31.2449}, {21.422487, 39.826206}} {
		if _, err := domain.NewRoundedLocation(bad[0], bad[1]); !errors.Is(err, domain.ErrCoordinatePrecision) {
			t.Errorf("%v accepted", bad)
		}
	}
}

func TestREQPRIV007PseudonymChangesWithTheDailySalt(t *testing.T) {
	t.Parallel()
	key := domain.AttestationKeyID("app-instance-key")
	a := domain.PseudonymOf(key, domain.Salt("salt-day-1"))
	if a != domain.PseudonymOf(key, domain.Salt("salt-day-1")) {
		t.Fatal("pseudonym is not deterministic within a day")
	}
	if a == domain.PseudonymOf(key, domain.Salt("salt-day-2")) {
		t.Fatal("pseudonym survives a new salt")
	}
	if bytes.Contains(a[:], key) {
		t.Fatal("pseudonym embeds the key id")
	}
}

func TestREQDATA002CutoffsFollowTheRetentionTable(t *testing.T) {
	t.Parallel()
	now := time.Date(2026, 10, 24, 9, 30, 0, 0, time.UTC)
	c := domain.CutoffsAt(now)
	if !c.CorrectionsBefore.Equal(now.AddDate(0, 0, -365)) || c.TelemetryBefore.String() != "2024-10-24" ||
		!c.PseudonymsBefore.Equal(now.Add(-24*time.Hour)) || !c.IdempotencyBefore.Equal(now.Add(-24*time.Hour)) ||
		c.SaltsBefore.String() != "2026-10-24" {
		t.Fatalf("%+v", c)
	}
}

func TestReceiptIDIsARandomUUIDv4(t *testing.T) {
	t.Parallel()
	id, err := domain.NewReceiptID(bytes.NewReader(bytes.Repeat([]byte{0xff}, 16)))
	if err != nil {
		t.Fatal(err)
	}
	if !regexp.MustCompile(`^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$`).MatchString(string(id)) {
		t.Fatalf("id %s", id)
	}
	if _, err := domain.NewReceiptID(bytes.NewReader(nil)); err == nil {
		t.Fatal("short random source accepted")
	}
}

func TestProfileVersionsCompareNumerically(t *testing.T) {
	t.Parallel()
	if domain.CompareProfileVersions("2026.10.0", "2026.9.3") <= 0 || domain.CompareProfileVersions("2026.1.0", "2026.1.0") != 0 {
		t.Fatal("version order")
	}
}

func TestFlattenAggregateDropsZerosAndCountsTheReport(t *testing.T) {
	t.Parallel()
	a := telemetry.Aggregate{
		Day: "2026-10-23", AppVersion: "1.0.0", Platform: telemetry.PlatformAndroid,
		Counters: telemetry.Counters{
			PackageActivations: map[telemetry.PackageType]int{telemetry.PackageTzdata: 2, telemetry.PackageHijri: 0},
			HealthState:        map[telemetry.HealthState]int{telemetry.HealthReady: 1},
			TestResults:        telemetry.TestResults{Heard: 1},
			SyncOutcome:        telemetry.SyncOutcome{OK: 3},
		},
	}
	got := domain.FlattenAggregate(a)
	want := []domain.TelemetryCount{
		{Day: "2026-10-23", Metric: domain.MetricHealthState, Dim: "READY", Count: 1},
		{Day: "2026-10-23", Metric: domain.MetricPackageActivations, Dim: "tzdata", Count: 2},
		{Day: "2026-10-23", Metric: domain.MetricReportsAppVersion, Dim: "1.0.0", Count: 1},
		{Day: "2026-10-23", Metric: domain.MetricReportsCountry, Dim: "ZZ", Count: 1},
		{Day: "2026-10-23", Metric: domain.MetricReports, Dim: "android", Count: 1},
		{Day: "2026-10-23", Metric: domain.MetricSyncOutcome, Dim: "ok", Count: 3},
		{Day: "2026-10-23", Metric: domain.MetricTestResults, Dim: "heard", Count: 1},
	}
	if len(got) != len(want) {
		t.Fatalf("got %+v", got)
	}
	for i := range want {
		if got[i] != want[i] {
			t.Fatalf("row %d = %+v, want %+v", i, got[i], want[i])
		}
	}
}
