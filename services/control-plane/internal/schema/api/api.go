// Package api holds the Go wire models of the control plane's request and
// response bodies (DESIGN.md §9.3, ADR-023): correction_request.v1,
// correction_receipt.v1 and problem_details.v1. Bodies are checked against
// the schema first (REQ-API-005), then decoded rejecting unknown keys.
package api

import (
	"bytes"
	"encoding/json"
	"fmt"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/schema/validate"
)

// CorrectionRequest is the body of POST /v1/feedback/corrections.
type CorrectionRequest struct {
	SchemaVersion int               `json:"schemaVersion"`
	Kind          string            `json:"kind"`
	Payload       CorrectionPayload `json:"payload"`
	Country       *string           `json:"country,omitempty"`
	RoundedLat    *float64          `json:"roundedLat,omitempty"`
	RoundedLon    *float64          `json:"roundedLon,omitempty"`
}

// CorrectionPayload is what the user says is wrong.
type CorrectionPayload struct {
	CalculationID     *string `json:"calculationId,omitempty"`
	ProfileID         *string `json:"profileId,omitempty"`
	ZoneID            *string `json:"zoneId,omitempty"`
	Event             *string `json:"event,omitempty"`
	LocalDay          *string `json:"localDay,omitempty"`
	ExpectedLocalTime *string `json:"expectedLocalTime,omitempty"`
	HijriDate         *string `json:"hijriDate,omitempty"`
	Note              *string `json:"note,omitempty"`
}

// CorrectionReceipt is the response of POST /v1/feedback/corrections.
type CorrectionReceipt struct {
	ReceiptID string `json:"receiptId"`
}

// Problem is an RFC 9457 problem details body (REQ-API-001).
type Problem struct {
	Type     string `json:"type"`
	Title    string `json:"title"`
	Status   int    `json:"status"`
	Detail   string `json:"detail,omitempty"`
	Instance string `json:"instance,omitempty"`
	TraceID  string `json:"traceId"`
}

// Decode validates body against s and decodes it into a T, rejecting
// unknown keys and trailing data. Errors wrap validate.ErrInvalid.
func Decode[T any](v *validate.Validator, s validate.Schema, body []byte) (T, error) {
	var out T
	if err := v.Validate(s, body); err != nil {
		return out, err
	}
	dec := json.NewDecoder(bytes.NewReader(body))
	dec.DisallowUnknownFields()
	if err := dec.Decode(&out); err != nil {
		return out, fmt.Errorf("%w: %w", validate.ErrInvalid, err)
	}
	return out, nil
}
