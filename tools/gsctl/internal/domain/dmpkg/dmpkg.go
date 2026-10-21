// Package dmpkg packs and unpacks the .dmpkg container (§9.1): gzip of one
// payload file. Packing is deterministic for a given payload and Go
// release, so a rebuild of the same payload has the same content address
// (REQ-DIST-003, §15 D60). Pure.
package dmpkg

import (
	"bytes"
	"compress/gzip"
	"errors"
	"fmt"
	"io"
)

// MaxPayloadBytes bounds an unpacked payload (64 MiB, far above the §9.5
// sizes) so a hostile package cannot exhaust memory.
const MaxPayloadBytes = 64 << 20

// osUnknown is the gzip OS byte for "unknown" (RFC 1952), written so the
// container does not depend on the build host.
const osUnknown = 255

// ErrNotSingle is returned when the container holds more than one gzip
// member or trailing bytes: a .dmpkg carries exactly one payload.
var ErrNotSingle = errors.New("dmpkg: not a single gzip member")

// ErrTooLarge is returned when a payload exceeds MaxPayloadBytes.
var ErrTooLarge = errors.New("dmpkg: payload exceeds the size limit")

// Pack returns gzip(payload) with the payload's file name in the header, no
// modification time and the "unknown" OS byte.
func Pack(fileName string, payload []byte) ([]byte, error) {
	var buf bytes.Buffer
	zw, err := gzip.NewWriterLevel(&buf, gzip.BestCompression)
	if err != nil {
		return nil, fmt.Errorf("dmpkg: %w", err)
	}
	zw.Name = fileName
	zw.OS = osUnknown
	if _, err := zw.Write(payload); err != nil {
		return nil, fmt.Errorf("dmpkg: compress: %w", err)
	}
	if err := zw.Close(); err != nil {
		return nil, fmt.Errorf("dmpkg: compress: %w", err)
	}
	return buf.Bytes(), nil
}

// Unpack returns the payload's file name and bytes.
func Unpack(container []byte) (string, []byte, error) {
	in := bytes.NewReader(container)
	zr, err := gzip.NewReader(in)
	if err != nil {
		return "", nil, fmt.Errorf("dmpkg: %w", err)
	}
	zr.Multistream(false)
	payload, err := io.ReadAll(io.LimitReader(zr, MaxPayloadBytes+1))
	if err != nil {
		return "", nil, fmt.Errorf("dmpkg: decompress: %w", err)
	}
	if len(payload) > MaxPayloadBytes {
		return "", nil, ErrTooLarge
	}
	if err := zr.Close(); err != nil {
		return "", nil, fmt.Errorf("dmpkg: %w", err)
	}
	if in.Len() != 0 {
		return "", nil, ErrNotSingle
	}
	return zr.Name, payload, nil
}
