package telemetry_test

import (
	"encoding/json"
	"testing"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/fixturetest"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/telemetry"
)

func TestValidFixturesRoundTrip(t *testing.T) {
	t.Parallel()
	fixturetest.RoundTrip[telemetry.Aggregate](t, "telemetry_aggregate")
}

func TestModelRejectsInvalidFixtures(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name    string
		fixture string
	}{
		{name: "unknown key is rejected (REQ-API-005)", fixture: "REQ-API-005_unknown_key.json"},
		{name: "device identifier key is rejected (REQ-PRIV-001)", fixture: "REQ-PRIV-001_device_identifier.json"},
		{name: "unknown package type", fixture: "unknown_package_type.json"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			var model telemetry.Aggregate
			if err := json.Unmarshal(fixturetest.InvalidFixture(t, "telemetry_aggregate", tc.fixture), &model); err == nil {
				t.Fatalf("decoded %s without error", tc.fixture)
			}
		})
	}
}
