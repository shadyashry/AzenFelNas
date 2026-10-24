package domain

import (
	"crypto/sha256"
	"time"
)

// CorrectionsPerDay is the daily correction allowance per attestation key (§9.3).
const CorrectionsPerDay = 10

// AttestationKeyID is the platform's app-instance key id: the App Attest key
// id on iOS, the app's installation key bound into the Play Integrity request
// hash on Android (§15 D86). It is never stored or logged.
type AttestationKeyID []byte

// Salt is the server's random salt for one UTC day.
type Salt []byte

// Day is a UTC calendar day.
type Day struct{ time.Time }

// DayOf returns the UTC day containing t.
func DayOf(t time.Time) Day {
	y, m, d := t.UTC().Date()
	return Day{time.Date(y, m, d, 0, 0, 0, 0, time.UTC)}
}

// String formats the day as YYYY-MM-DD.
func (d Day) String() string { return d.Format(time.DateOnly) }

// Pseudonym is sha256(attestationKeyId + dailyServerSalt), the only
// device-derived identifier the server keeps, for at most 24 h (REQ-PRIV-007).
type Pseudonym [sha256.Size]byte

// PseudonymOf derives the daily pseudonym of an attestation key.
func PseudonymOf(key AttestationKeyID, salt Salt) Pseudonym {
	h := sha256.New()
	h.Write(key)
	h.Write(salt)
	var p Pseudonym
	copy(p[:], h.Sum(nil))
	return p
}
