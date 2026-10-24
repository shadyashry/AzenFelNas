package domain

import (
	"encoding/hex"
	"fmt"
	"io"
	"math"
	"time"
)

// CorrectionKind is what a user correction is about (§9.3).
type CorrectionKind string

// CorrectionKind values.
const (
	CorrectionZone    CorrectionKind = "zone"
	CorrectionProfile CorrectionKind = "profile"
	CorrectionHijri   CorrectionKind = "hijri"
	CorrectionOther   CorrectionKind = "other"
)

// CorrectionStatus is the review state of a correction (§9.3).
type CorrectionStatus string

// CorrectionStatus values.
const (
	CorrectionNew       CorrectionStatus = "new"
	CorrectionAccepted  CorrectionStatus = "accepted"
	CorrectionRejected  CorrectionStatus = "rejected"
	CorrectionDuplicate CorrectionStatus = "duplicate"
)

// ReceiptID identifies one correction, never the device (REQ-API-006).
type ReceiptID string

// RoundedLocation is a coordinate rounded on the device to two decimals
// (about 1 km), the most precision the server accepts (REQ-PRIV-001).
type RoundedLocation struct {
	Lat float64
	Lon float64
}

// NewRoundedLocation accepts lat/lon only when each has at most two decimals.
func NewRoundedLocation(lat, lon float64) (RoundedLocation, error) {
	for _, v := range []float64{lat, lon} {
		if !hasAtMostTwoDecimals(v) {
			return RoundedLocation{}, fmt.Errorf("%w: %v", ErrCoordinatePrecision, v)
		}
	}
	return RoundedLocation{Lat: lat, Lon: lon}, nil
}

// hasAtMostTwoDecimals tolerates the binary representation error of a
// decimal literal such as 30.07, never a third significant decimal.
func hasAtMostTwoDecimals(v float64) bool {
	scaled := v * 100
	return math.Abs(scaled-math.Round(scaled)) < 1e-6
}

// Correction is one stored user correction (§9.3 table `corrections`).
type Correction struct {
	ID          ReceiptID
	ReceivedUTC time.Time
	Kind        CorrectionKind
	PayloadJSON []byte
	Country     *string
	Location    *RoundedLocation
	Status      CorrectionStatus
}

// NewReceiptID returns a random RFC 9562 version-4 UUID read from random.
func NewReceiptID(random io.Reader) (ReceiptID, error) {
	var b [16]byte
	if _, err := io.ReadFull(random, b[:]); err != nil {
		return "", fmt.Errorf("receipt id: %w", err)
	}
	b[6] = b[6]&0x0f | 0x40
	b[8] = b[8]&0x3f | 0x80
	h := hex.EncodeToString(b[:])
	return ReceiptID(h[0:8] + "-" + h[8:12] + "-" + h[12:16] + "-" + h[16:20] + "-" + h[20:32]), nil
}
