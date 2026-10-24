package domain

import (
	"cmp"
	"slices"
	"strings"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/telemetry"
)

// TelemetryCount is one row increment of `telemetry_daily(date, metric, dim, count)` (§9.3).
type TelemetryCount struct {
	Day    string
	Metric string
	Dim    string
	Count  int64
}

// Telemetry metric names; each aggregate also counts one report per platform,
// app version and country so totals can be normalised (§15 D86).
const (
	MetricReports            = "reports.platform"
	MetricReportsAppVersion  = "reports.appVersion"
	MetricReportsCountry     = "reports.country"
	MetricPackageActivations = "packageActivations"
	MetricHealthState        = "healthState"
	MetricTestResults        = "testResults"
	MetricSyncOutcome        = "syncOutcome"
	unknownCountry           = "ZZ"
)

// FlattenAggregate turns one device's daily aggregate into row increments.
// Zero counters are dropped; the result is sorted so storage is deterministic.
func FlattenAggregate(a telemetry.Aggregate) []TelemetryCount {
	country := unknownCountry
	if a.CountryCode != nil {
		country = *a.CountryCode
	}
	rows := []TelemetryCount{
		{Day: a.Day, Metric: MetricReports, Dim: string(a.Platform), Count: 1},
		{Day: a.Day, Metric: MetricReportsAppVersion, Dim: a.AppVersion, Count: 1},
		{Day: a.Day, Metric: MetricReportsCountry, Dim: country, Count: 1},
	}
	add := func(metric, dim string, n int) {
		if n > 0 {
			rows = append(rows, TelemetryCount{Day: a.Day, Metric: metric, Dim: dim, Count: int64(n)})
		}
	}
	for k, n := range a.Counters.PackageActivations {
		add(MetricPackageActivations, string(k), n)
	}
	for k, n := range a.Counters.HealthState {
		add(MetricHealthState, string(k), n)
	}
	t := a.Counters.TestResults
	add(MetricTestResults, "heard", t.Heard)
	add(MetricTestResults, "notHeard", t.NotHeard)
	add(MetricTestResults, "unknown", t.Unknown)
	s := a.Counters.SyncOutcome
	add(MetricSyncOutcome, "ok", s.OK)
	add(MetricSyncOutcome, "warn", s.Warn)
	add(MetricSyncOutcome, "fail", s.Fail)
	slices.SortFunc(rows, func(x, y TelemetryCount) int {
		return cmp.Or(strings.Compare(x.Metric, y.Metric), strings.Compare(x.Dim, y.Dim))
	})
	return rows
}
