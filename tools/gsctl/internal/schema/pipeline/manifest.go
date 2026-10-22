// Package pipeline holds the hand-written Go model of
// schemas/pipeline_manifest.v1.schema.json (ADR-023, §15 D24): the output
// manifest of a deterministic data pipeline, which gsctl cross-checks before
// it packages a pipeline's payload (§15 D69).
package pipeline

import "github.com/samehamin/daily_muslim/tools/gsctl/internal/schema/jsonx"

// Manifest is pipeline_manifest.v1. Its pattern and range constraints are
// ajv's (ci-schemas); this model fixes the shape and rejects unknown keys.
type Manifest struct {
	SchemaVersion int               `json:"schemaVersion"`
	Pipeline      string            `json:"pipeline"`
	Inputs        []Input           `json:"inputs"`
	Tools         map[string]string `json:"tools"`
	Parameters    map[string]string `json:"parameters"`
	Outputs       []Output          `json:"outputs"`
}

// Input is one pinned input; Path and URL are optional.
type Input struct {
	Role   string  `json:"role"`
	Path   *string `json:"path,omitempty"`
	URL    *string `json:"url,omitempty"`
	SHA256 string  `json:"sha256"`
}

// Output is one produced file, relative to the manifest's directory.
type Output struct {
	Path    string `json:"path"`
	SHA256  string `json:"sha256"`
	Records int64  `json:"records"`
}

// UnmarshalJSON decodes a manifest, rejecting unknown keys at every level.
func (m *Manifest) UnmarshalJSON(data []byte) error {
	type plain Manifest
	var v plain
	if err := jsonx.DecodeStrict(data, &v); err != nil {
		return err
	}
	*m = Manifest(v)
	return nil
}
