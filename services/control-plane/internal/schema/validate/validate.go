// Package validate checks request and response bodies against the JSON
// Schemas in schemas/ (REQ-API-005, ADR-023). The files under files/ are
// byte-for-byte copies, kept equal by TestEmbeddedSchemasMatchRepository.
package validate

//go:generate sh -c "cp ../../../../../schemas/correction_request.v1.schema.json ../../../../../schemas/correction_receipt.v1.schema.json ../../../../../schemas/problem_details.v1.schema.json ../../../../../schemas/evidence_summary.v1.schema.json ../../../../../schemas/telemetry_aggregate.v1.schema.json files/"

import (
	"bytes"
	"embed"
	"errors"
	"fmt"

	"github.com/santhosh-tekuri/jsonschema/v6"
)

// Schema names a schema in files/ by its file name without ".v1.schema.json".
type Schema string

// The schemas the control plane serves or accepts.
const (
	CorrectionRequest  Schema = "correction_request"
	CorrectionReceipt  Schema = "correction_receipt"
	ProblemDetails     Schema = "problem_details"
	EvidenceSummary    Schema = "evidence_summary"
	TelemetryAggregate Schema = "telemetry_aggregate"
)

// All lists every embedded schema.
var All = []Schema{CorrectionRequest, CorrectionReceipt, ProblemDetails, EvidenceSummary, TelemetryAggregate}

// ErrInvalid wraps every validation failure.
var ErrInvalid = errors.New("validate: body does not match schema")

//go:embed files/*.json
var files embed.FS

// Validator holds the compiled schemas. It is safe for concurrent use.
type Validator struct {
	compiled map[Schema]*jsonschema.Schema
}

// New compiles every embedded schema with format assertions on.
func New() (*Validator, error) {
	c := jsonschema.NewCompiler()
	c.AssertFormat()
	compiled := make(map[Schema]*jsonschema.Schema, len(All))
	for _, s := range All {
		name := FileName(s)
		raw, err := files.ReadFile("files/" + name)
		if err != nil {
			return nil, fmt.Errorf("read %s: %w", name, err)
		}
		doc, err := jsonschema.UnmarshalJSON(bytes.NewReader(raw))
		if err != nil {
			return nil, fmt.Errorf("parse %s: %w", name, err)
		}
		if err := c.AddResource(name, doc); err != nil {
			return nil, fmt.Errorf("add %s: %w", name, err)
		}
		sch, err := c.Compile(name)
		if err != nil {
			return nil, fmt.Errorf("compile %s: %w", name, err)
		}
		compiled[s] = sch
	}
	return &Validator{compiled: compiled}, nil
}

// FileName returns the file name of s in schemas/.
func FileName(s Schema) string { return string(s) + ".v1.schema.json" }

// Embedded returns the embedded copy of s.
func Embedded(s Schema) ([]byte, error) {
	b, err := files.ReadFile("files/" + FileName(s))
	if err != nil {
		return nil, fmt.Errorf("embedded %s: %w", s, err)
	}
	return b, nil
}

// Validate returns nil when body is one JSON value valid against s, else an
// error wrapping ErrInvalid.
func (v *Validator) Validate(s Schema, body []byte) error {
	sch, ok := v.compiled[s]
	if !ok {
		return fmt.Errorf("%w: unknown schema %q", ErrInvalid, s)
	}
	doc, err := jsonschema.UnmarshalJSON(bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("%w: %w", ErrInvalid, err)
	}
	if err := sch.Validate(doc); err != nil {
		return fmt.Errorf("%w: %w", ErrInvalid, err)
	}
	return nil
}
