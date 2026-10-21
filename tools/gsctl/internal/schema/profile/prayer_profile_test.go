package profile_test

import (
	"encoding/json"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/fixturetest"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/profile"
)

func TestValidFixturesRoundTrip(t *testing.T) {
	t.Parallel()
	fixturetest.RoundTrip[profile.PrayerProfile](t, "prayer_profile")
}

func TestModelRejectsInvalidFixtures(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name    string
		fixture string
	}{
		{name: "unknown top-level key", fixture: "unknown_top_level_key.json"},
		{name: "unknown rule type", fixture: "unknown_rule_type.json"},
		{name: "unknown status", fixture: "status_unknown.json"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			var model profile.PrayerProfile
			if err := json.Unmarshal(fixturetest.InvalidFixture(t, "prayer_profile", tc.fixture), &model); err == nil {
				t.Fatalf("decoded %s without error", tc.fixture)
			}
		})
	}
}
