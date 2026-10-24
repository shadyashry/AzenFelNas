package api_test

import (
	"errors"
	"testing"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/api"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/fixturetest"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

func TestValidFixturesRoundTrip(t *testing.T) {
	t.Parallel()
	fixturetest.RoundTrip[api.CorrectionRequest](t, "correction_request")
	fixturetest.RoundTrip[api.CorrectionReceipt](t, "correction_receipt")
	fixturetest.RoundTrip[api.Problem](t, "problem_details")
}

func TestREQAPI005DecodeRejectsInvalidFixtures(t *testing.T) {
	t.Parallel()
	v, err := validate.New()
	if err != nil {
		t.Fatal(err)
	}
	for _, name := range []string{"REQ-API-005_unknown_key.json", "REQ-API-006_user_identity.json", "unknown_kind.json"} {
		body := fixturetest.InvalidFixture(t, "correction_request", name)
		if _, err := api.Decode[api.CorrectionRequest](v, validate.CorrectionRequest, body); !errors.Is(err, validate.ErrInvalid) {
			t.Errorf("%s decoded (err = %v)", name, err)
		}
	}
}
