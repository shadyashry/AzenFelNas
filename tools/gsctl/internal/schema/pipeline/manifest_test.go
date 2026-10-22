package pipeline_test

import (
	"encoding/json"
	"testing"

	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/fixturetest"
	"github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/pipeline"
)

func TestValidFixturesRoundTrip(t *testing.T) {
	t.Parallel()
	fixturetest.RoundTrip[pipeline.Manifest](t, "pipeline_manifest")
}

func TestModelRejectsAnUnknownKey(t *testing.T) {
	t.Parallel()
	var m pipeline.Manifest
	doc := `{"schemaVersion":1,"pipeline":"p","inputs":[],"tools":{},"parameters":{},"outputs":[],"extra":1}`
	if err := json.Unmarshal([]byte(doc), &m); err == nil {
		t.Fatal("decoded a manifest with an unknown key")
	}
}
