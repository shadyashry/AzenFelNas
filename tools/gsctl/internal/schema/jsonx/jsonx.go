// Package jsonx holds the strict JSON helpers shared by the hand-written wire
// models of schemas/ (ADR-023, §15 D24): unknown keys are rejected, enums are
// closed, and tagged unions are encoded with their discriminator key.
package jsonx

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"slices"
)

// ErrTrailingData is returned when a JSON value is followed by more data.
var ErrTrailingData = errors.New("jsonx: trailing data after JSON value")

// ErrUnknownEnum is returned when a string is not one of an enum's values.
var ErrUnknownEnum = errors.New("jsonx: unknown enum value")

// ErrMissingTag is returned when a tagged union has no string discriminator.
var ErrMissingTag = errors.New("jsonx: missing union discriminator")

// DecodeStrict decodes data into v, rejecting unknown object keys and any
// trailing data.
func DecodeStrict(data []byte, v any) error {
	dec := json.NewDecoder(bytes.NewReader(data))
	dec.DisallowUnknownFields()
	if err := dec.Decode(v); err != nil {
		return fmt.Errorf("decode %T: %w", v, err)
	}
	if dec.More() {
		return ErrTrailingData
	}
	return nil
}

// ParseEnum returns the value of allowed whose text is b.
func ParseEnum[T ~string](b []byte, allowed ...T) (T, error) {
	value := T(b)
	if !slices.Contains(allowed, value) {
		var zero T
		return zero, fmt.Errorf("%w %q", ErrUnknownEnum, b)
	}
	return value, nil
}

// SplitTag reads the string discriminator key from the JSON object data and
// returns it with the remaining members re-encoded as an object.
func SplitTag(data []byte, key string) (string, []byte, error) {
	var fields map[string]json.RawMessage
	if err := DecodeStrict(data, &fields); err != nil {
		return "", nil, err
	}
	raw, ok := fields[key]
	if !ok {
		return "", nil, fmt.Errorf("%w %q", ErrMissingTag, key)
	}
	var tag string
	if err := json.Unmarshal(raw, &tag); err != nil {
		return "", nil, fmt.Errorf("%w %q: %w", ErrMissingTag, key, err)
	}
	delete(fields, key)
	rest, err := json.Marshal(fields)
	if err != nil {
		return "", nil, fmt.Errorf("re-encode union members: %w", err)
	}
	return tag, rest, nil
}

// WithTag encodes the struct v as a JSON object with key set to tag.
func WithTag(key, tag string, v any) ([]byte, error) {
	encoded, err := json.Marshal(v)
	if err != nil {
		return nil, fmt.Errorf("encode %T: %w", v, err)
	}
	var fields map[string]json.RawMessage
	if err := json.Unmarshal(encoded, &fields); err != nil {
		return nil, fmt.Errorf("encode %T as object: %w", v, err)
	}
	quoted, err := json.Marshal(tag)
	if err != nil {
		return nil, fmt.Errorf("encode tag: %w", err)
	}
	fields[key] = quoted
	out, err := json.Marshal(fields)
	if err != nil {
		return nil, fmt.Errorf("encode tagged %T: %w", v, err)
	}
	return out, nil
}
