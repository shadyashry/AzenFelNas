// Package jcs implements the JSON Canonicalization Scheme (RFC 8785) that
// TUF-lite signatures cover (Appendix C, REQ-DIST-004) and that fixes the
// bytes of a compiled package payload (§15 D60). The Dart twin is
// dm_core_types' CanonicalJson; both pass tools/gsctl/testdata/jcs.
package jcs

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"math"
	"slices"
	"strconv"
	"unicode/utf16"
	"unicode/utf8"
)

// ErrInvalidInput is returned for input that RFC 8785 cannot canonicalise:
// invalid JSON or UTF-8, a duplicate member name, trailing data, or a number
// outside the IEEE 754 double range.
var ErrInvalidInput = errors.New("jcs: invalid input")

// Canonicalize returns the canonical form of the JSON text data: members
// sorted by UTF-16 code units, numbers in the ECMAScript form, strings with
// only the RFC 8785 escapes, and no whitespace. Pure and deterministic.
func Canonicalize(data []byte) ([]byte, error) {
	if !utf8.Valid(data) {
		return nil, fmt.Errorf("%w: not UTF-8", ErrInvalidInput)
	}
	dec := json.NewDecoder(bytes.NewReader(data))
	dec.UseNumber()
	var out bytes.Buffer
	if err := writeValue(&out, dec); err != nil {
		return nil, err
	}
	if _, err := dec.Token(); !errors.Is(err, io.EOF) {
		return nil, fmt.Errorf("%w: trailing data", ErrInvalidInput)
	}
	return out.Bytes(), nil
}

// Marshal encodes v with encoding/json and returns its canonical form.
func Marshal(v any) ([]byte, error) {
	encoded, err := json.Marshal(v)
	if err != nil {
		return nil, fmt.Errorf("jcs: encode %T: %w", v, err)
	}
	return Canonicalize(encoded)
}

func writeValue(out *bytes.Buffer, dec *json.Decoder) error {
	tok, err := dec.Token()
	if err != nil {
		return fmt.Errorf("%w: %w", ErrInvalidInput, err)
	}
	switch v := tok.(type) {
	case json.Delim:
		if v == '{' {
			return writeObject(out, dec)
		}
		return writeArray(out, dec)
	case string:
		writeString(out, v)
	case json.Number:
		return writeNumber(out, v)
	case bool:
		out.WriteString(strconv.FormatBool(v))
	case nil:
		out.WriteString("null")
	default:
		return fmt.Errorf("%w: unexpected token %v", ErrInvalidInput, tok)
	}
	return nil
}

type member struct {
	key   string
	units []uint16
	value []byte
}

func writeObject(out *bytes.Buffer, dec *json.Decoder) error {
	var members []member
	seen := map[string]bool{}
	for dec.More() {
		tok, err := dec.Token()
		if err != nil {
			return fmt.Errorf("%w: %w", ErrInvalidInput, err)
		}
		key, ok := tok.(string)
		if !ok {
			return fmt.Errorf("%w: member name %v", ErrInvalidInput, tok)
		}
		if seen[key] {
			return fmt.Errorf("%w: duplicate member %q", ErrInvalidInput, key)
		}
		seen[key] = true
		var value bytes.Buffer
		if err := writeValue(&value, dec); err != nil {
			return err
		}
		members = append(members, member{key: key, units: utf16.Encode([]rune(key)), value: value.Bytes()})
	}
	if _, err := dec.Token(); err != nil { // the closing '}'
		return fmt.Errorf("%w: %w", ErrInvalidInput, err)
	}
	slices.SortFunc(members, func(a, b member) int { return slices.Compare(a.units, b.units) })
	out.WriteByte('{')
	for i, m := range members {
		if i > 0 {
			out.WriteByte(',')
		}
		writeString(out, m.key)
		out.WriteByte(':')
		out.Write(m.value)
	}
	out.WriteByte('}')
	return nil
}

func writeArray(out *bytes.Buffer, dec *json.Decoder) error {
	out.WriteByte('[')
	for i := 0; dec.More(); i++ {
		if i > 0 {
			out.WriteByte(',')
		}
		if err := writeValue(out, dec); err != nil {
			return err
		}
	}
	if _, err := dec.Token(); err != nil { // the closing ']'
		return fmt.Errorf("%w: %w", ErrInvalidInput, err)
	}
	out.WriteByte(']')
	return nil
}

// writeNumber writes the ECMAScript Number::toString form of the double
// nearest to n (RFC 8785 §3.2.2.3), as encoding/json does for float64,
// with -0 written as 0.
func writeNumber(out *bytes.Buffer, n json.Number) error {
	f, err := strconv.ParseFloat(n.String(), 64)
	if err != nil || math.IsInf(f, 0) || math.IsNaN(f) {
		return fmt.Errorf("%w: number %s", ErrInvalidInput, n)
	}
	if f == 0 {
		out.WriteByte('0')
		return nil
	}
	format := byte('f')
	if abs := math.Abs(f); abs < 1e-6 || abs >= 1e21 {
		format = 'e'
	}
	b := strconv.AppendFloat(nil, f, format, -1, 64)
	if format == 'e' {
		// Go writes a two-digit exponent ("1e-07"); ECMAScript writes "1e-7".
		if n := len(b); n >= 4 && b[n-4] == 'e' && b[n-2] == '0' {
			b[n-2] = b[n-1]
			b = b[:n-1]
		}
	}
	out.Write(b)
	return nil
}

// writeString writes s with the RFC 8785 escapes: quote, backslash, the
// short forms \b \f \n \r \t and \u00xx (lowercase) for other C0 controls.
func writeString(out *bytes.Buffer, s string) {
	out.WriteByte('"')
	for _, r := range s {
		switch r {
		case '"':
			out.WriteString(`\"`)
		case '\\':
			out.WriteString(`\\`)
		case '\b':
			out.WriteString(`\b`)
		case '\f':
			out.WriteString(`\f`)
		case '\n':
			out.WriteString(`\n`)
		case '\r':
			out.WriteString(`\r`)
		case '\t':
			out.WriteString(`\t`)
		default:
			if r < 0x20 {
				const hexDigits = "0123456789abcdef"
				out.WriteString(`\u00`)
				out.WriteByte(hexDigits[r>>4])
				out.WriteByte(hexDigits[r&0xf])
			} else {
				out.WriteRune(r)
			}
		}
	}
	out.WriteByte('"')
}
