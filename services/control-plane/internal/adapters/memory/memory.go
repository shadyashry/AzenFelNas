// Package memory implements every storage port in process memory. It backs
// the API's tests and `api serve -store=memory` for local runs; the same
// contract tests as the Postgres adapter prove it equivalent (REQ-TEST-004).
package memory

import (
	"bytes"
	"context"
	"crypto/rand"
	"fmt"
	"slices"
	"sync"
	"time"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

// Store is an in-memory database. The zero value is not usable; call New.
type Store struct {
	mu          sync.Mutex
	corrections []domain.Correction
	telemetry   map[telemetryKey]int64
	evidence    map[string][]evidenceRow
	salts       map[string]domain.Salt
	limits      map[limitKey]limitRow
	keys        map[domain.Pseudonym]keyRow
	idempotency map[ports.IdempotencyKey]idemRow
}

type telemetryKey struct{ day, metric, dim string }

type evidenceRow struct {
	version string
	summary []byte
}

type limitKey struct {
	pseudonym domain.Pseudonym
	day       string
}

type limitRow struct {
	count   int
	created time.Time
}

type keyRow struct {
	key     ports.AttestedKey
	created time.Time
}

type idemRow struct {
	hash     [32]byte
	created  time.Time
	done     bool
	response ports.StoredResponse
}

// New returns an empty store.
func New() *Store {
	return &Store{
		telemetry:   map[telemetryKey]int64{},
		evidence:    map[string][]evidenceRow{},
		salts:       map[string]domain.Salt{},
		limits:      map[limitKey]limitRow{},
		keys:        map[domain.Pseudonym]keyRow{},
		idempotency: map[ports.IdempotencyKey]idemRow{},
	}
}

// InsertCorrection implements ports.CorrectionStore.
func (s *Store) InsertCorrection(_ context.Context, c domain.Correction) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if slices.ContainsFunc(s.corrections, func(x domain.Correction) bool { return x.ID == c.ID }) {
		return fmt.Errorf("memory: correction %s exists", c.ID)
	}
	c.PayloadJSON = bytes.Clone(c.PayloadJSON)
	s.corrections = append(s.corrections, c)
	return nil
}

// Corrections returns a copy of the stored corrections, oldest first.
func (s *Store) Corrections() []domain.Correction {
	s.mu.Lock()
	defer s.mu.Unlock()
	return slices.Clone(s.corrections)
}

// AddTelemetry implements ports.TelemetryStore.
func (s *Store) AddTelemetry(_ context.Context, rows []domain.TelemetryCount) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	for _, r := range rows {
		s.telemetry[telemetryKey{r.Day, r.Metric, r.Dim}] += r.Count
	}
	return nil
}

// TelemetryCount returns the stored count of one row.
func (s *Store) TelemetryCount(day, metric, dim string) int64 {
	s.mu.Lock()
	defer s.mu.Unlock()
	return s.telemetry[telemetryKey{day, metric, dim}]
}

// PutEvidence stores a summary for a profile version (test and local seeding).
func (s *Store) PutEvidence(profileID, version string, summary []byte) {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.evidence[profileID] = append(s.evidence[profileID], evidenceRow{version, bytes.Clone(summary)})
}

// LatestEvidence implements ports.EvidenceStore. Versions compare as
// "YYYY.M.N" numbers, as in prayer_profile.v1.
func (s *Store) LatestEvidence(_ context.Context, profileID string) ([]byte, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	rows := s.evidence[profileID]
	if len(rows) == 0 {
		return nil, domain.ErrNotFound
	}
	best := slices.MaxFunc(rows, func(a, b evidenceRow) int { return domain.CompareProfileVersions(a.version, b.version) })
	return bytes.Clone(best.summary), nil
}

// DailySalt implements ports.SaltSource.
func (s *Store) DailySalt(_ context.Context, day domain.Day) (domain.Salt, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	if salt, ok := s.salts[day.String()]; ok {
		return bytes.Clone(salt), nil
	}
	salt := make(domain.Salt, 32)
	if _, err := rand.Read(salt); err != nil {
		return nil, fmt.Errorf("memory: salt: %w", err)
	}
	s.salts[day.String()] = salt
	return bytes.Clone(salt), nil
}

// Consume implements ports.RateLimiter.
func (s *Store) Consume(_ context.Context, p domain.Pseudonym, day domain.Day, limit int, now time.Time) (bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	k := limitKey{p, day.String()}
	row, ok := s.limits[k]
	if !ok {
		row.created = now
	}
	if row.count >= limit {
		return false, nil
	}
	row.count++
	s.limits[k] = row
	return true, nil
}

// AttestedKey implements ports.AttestedKeyStore.
func (s *Store) AttestedKey(_ context.Context, p domain.Pseudonym) (ports.AttestedKey, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	row, ok := s.keys[p]
	if !ok {
		return ports.AttestedKey{}, domain.ErrNotFound
	}
	return ports.AttestedKey{PublicKey: bytes.Clone(row.key.PublicKey), Counter: row.key.Counter}, nil
}

// PutAttestedKey implements ports.AttestedKeyStore.
func (s *Store) PutAttestedKey(_ context.Context, p domain.Pseudonym, k ports.AttestedKey, now time.Time) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	s.keys[p] = keyRow{key: ports.AttestedKey{PublicKey: bytes.Clone(k.PublicKey), Counter: k.Counter}, created: now}
	return nil
}

// AdvanceCounter implements ports.AttestedKeyStore.
func (s *Store) AdvanceCounter(_ context.Context, p domain.Pseudonym, counter uint32) (bool, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	row, ok := s.keys[p]
	if !ok || counter <= row.key.Counter {
		return false, nil
	}
	row.key.Counter = counter
	s.keys[p] = row
	return true, nil
}

// Claim implements ports.IdempotencyStore.
func (s *Store) Claim(_ context.Context, k ports.IdempotencyKey, hash [32]byte, now time.Time) (ports.Claim, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	row, ok := s.idempotency[k]
	switch {
	case !ok:
		s.idempotency[k] = idemRow{hash: hash, created: now}
		return ports.Claim{Outcome: ports.ClaimNew}, nil
	case row.hash != hash:
		return ports.Claim{Outcome: ports.ClaimMismatch}, nil
	case !row.done:
		return ports.Claim{Outcome: ports.ClaimInFlight}, nil
	default:
		r := row.response
		r.Body = bytes.Clone(r.Body)
		return ports.Claim{Outcome: ports.ClaimReplay, Response: r}, nil
	}
}

// Complete implements ports.IdempotencyStore.
func (s *Store) Complete(_ context.Context, k ports.IdempotencyKey, r ports.StoredResponse) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	row, ok := s.idempotency[k]
	if !ok {
		return fmt.Errorf("memory: complete unclaimed key %q", k.Key)
	}
	row.done = true
	row.response = ports.StoredResponse{Status: r.Status, ContentType: r.ContentType, Body: bytes.Clone(r.Body)}
	s.idempotency[k] = row
	return nil
}

// Release implements ports.IdempotencyStore.
func (s *Store) Release(_ context.Context, k ports.IdempotencyKey) error {
	s.mu.Lock()
	defer s.mu.Unlock()
	if row, ok := s.idempotency[k]; ok && !row.done {
		delete(s.idempotency, k)
	}
	return nil
}

// Purge implements ports.Purger.
func (s *Store) Purge(_ context.Context, c domain.Cutoffs) (domain.PurgeCounts, error) {
	s.mu.Lock()
	defer s.mu.Unlock()
	var n domain.PurgeCounts
	kept := s.corrections[:0]
	for _, x := range s.corrections {
		if x.ReceivedUTC.Before(c.CorrectionsBefore) {
			n.Corrections++
			continue
		}
		kept = append(kept, x)
	}
	s.corrections = kept
	for k := range s.telemetry {
		if k.day < c.TelemetryBefore.String() {
			delete(s.telemetry, k)
			n.Telemetry++
		}
	}
	for k, row := range s.limits {
		if row.created.Before(c.PseudonymsBefore) {
			delete(s.limits, k)
			n.Pseudonyms++
		}
	}
	for k, row := range s.keys {
		if row.created.Before(c.PseudonymsBefore) {
			delete(s.keys, k)
			n.Pseudonyms++
		}
	}
	for k, row := range s.idempotency {
		if row.created.Before(c.IdempotencyBefore) {
			delete(s.idempotency, k)
			n.Idempotency++
		}
	}
	for day := range s.salts {
		if day < c.SaltsBefore.String() {
			delete(s.salts, day)
			n.Salts++
		}
	}
	return n, nil
}

// Ping implements ports.Pinger.
func (s *Store) Ping(context.Context) error { return nil }
