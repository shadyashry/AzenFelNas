package domain

import "time"

// Retention periods of §9.3 (REQ-DATA-002, REQ-PRIV-007).
const (
	CorrectionRetention  = 365 * 24 * time.Hour
	TelemetryRetention   = 730 * 24 * time.Hour
	PseudonymRetention   = 24 * time.Hour
	IdempotencyRetention = 24 * time.Hour
)

// Cutoffs are the instants before which each kind of row is deleted.
type Cutoffs struct {
	CorrectionsBefore time.Time
	TelemetryBefore   Day
	PseudonymsBefore  time.Time
	IdempotencyBefore time.Time
	// SaltsBefore drops every salt of an earlier UTC day, so yesterday's
	// pseudonyms can no longer be recomputed (REQ-PRIV-007).
	SaltsBefore Day
}

// CutoffsAt returns the retention cutoffs at now.
func CutoffsAt(now time.Time) Cutoffs {
	now = now.UTC()
	return Cutoffs{
		CorrectionsBefore: now.Add(-CorrectionRetention),
		TelemetryBefore:   DayOf(now.Add(-TelemetryRetention)),
		PseudonymsBefore:  now.Add(-PseudonymRetention),
		IdempotencyBefore: now.Add(-IdempotencyRetention),
		SaltsBefore:       DayOf(now),
	}
}

// PurgeCounts reports how many rows a purge deleted.
type PurgeCounts struct {
	Corrections int64
	Telemetry   int64
	Pseudonyms  int64
	Idempotency int64
	Salts       int64
}
