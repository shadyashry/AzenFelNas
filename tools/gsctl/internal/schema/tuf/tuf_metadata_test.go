package tuf_test

import (
	"encoding/json"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/fixturetest"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/tuf"
)

func TestValidFixturesRoundTrip(t *testing.T) {
	t.Parallel()
	fixturetest.RoundTrip[tuf.Metadata](t, "tuf_metadata")
}

func TestModelRejectsInvalidFixtures(t *testing.T) {
	t.Parallel()
	tests := []struct {
		name    string
		fixture string
	}{
		{name: "unknown role type", fixture: "unknown_role_type.json"},
	}
	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			t.Parallel()
			var model tuf.Metadata
			if err := json.Unmarshal(fixturetest.InvalidFixture(t, "tuf_metadata", tc.fixture), &model); err == nil {
				t.Fatalf("decoded %s without error", tc.fixture)
			}
		})
	}
}
