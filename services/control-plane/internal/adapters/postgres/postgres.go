// Package postgres implements the storage ports on Postgres 16 (DESIGN.md
// §9.3, ADR-022): pgx/v5 with sqlc-generated queries in db/ and goose
// migrations embedded from migrations/. It passes the same port contract as
// the memory fake (REQ-TEST-004).
package postgres

//go:generate go run github.com/sqlc-dev/sqlc/cmd/sqlc@v1.31.1 generate

import (
	"context"
	"crypto/rand"
	"database/sql"
	"embed"
	"errors"
	"fmt"
	"time"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgtype"
	"github.com/jackc/pgx/v5/pgxpool"
	"github.com/jackc/pgx/v5/stdlib"
	"github.com/pressly/goose/v3"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/postgres/db"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports"
)

//go:embed migrations/*.sql
var migrations embed.FS

// Store is a Postgres-backed implementation of every storage port.
type Store struct {
	pool *pgxpool.Pool
	q    *db.Queries
}

// Open connects to dsn and checks the connection.
func Open(ctx context.Context, dsn string) (*Store, error) {
	cfg, err := pgxpool.ParseConfig(dsn)
	if err != nil {
		return nil, fmt.Errorf("postgres: parse dsn: %w", err)
	}
	pool, err := pgxpool.NewWithConfig(ctx, cfg)
	if err != nil {
		return nil, fmt.Errorf("postgres: connect: %w", err)
	}
	if err := pool.Ping(ctx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("postgres: ping: %w", err)
	}
	return &Store{pool: pool, q: db.New(pool)}, nil
}

// Close releases the pool.
func (s *Store) Close() { s.pool.Close() }

// Migrate applies every pending migration with goose.
func Migrate(ctx context.Context, dsn string) error {
	cfg, err := pgx.ParseConfig(dsn)
	if err != nil {
		return fmt.Errorf("postgres: parse dsn: %w", err)
	}
	sqlDB := stdlib.OpenDB(*cfg)
	defer func() { _ = sqlDB.Close() }() // read-only use is over; a close error changes nothing
	return migrate(ctx, sqlDB)
}

func migrate(ctx context.Context, sqlDB *sql.DB) error {
	provider, err := goose.NewProvider(goose.DialectPostgres, sqlDB, mustSub(migrations, "migrations"))
	if err != nil {
		return fmt.Errorf("postgres: goose: %w", err)
	}
	if _, err := provider.Up(ctx); err != nil {
		return fmt.Errorf("postgres: migrate: %w", err)
	}
	return nil
}

// InsertCorrection implements ports.CorrectionStore.
func (s *Store) InsertCorrection(ctx context.Context, c domain.Correction) error {
	p := db.InsertCorrectionParams{
		ID:          string(c.ID),
		ReceivedUtc: ts(c.ReceivedUTC),
		Kind:        string(c.Kind),
		PayloadJson: c.PayloadJSON,
		Status:      string(c.Status),
	}
	if c.Country != nil {
		p.Country = pgtype.Text{String: *c.Country, Valid: true}
	}
	if c.Location != nil {
		p.RoundedLat, p.RoundedLon = &c.Location.Lat, &c.Location.Lon
	}
	if err := s.q.InsertCorrection(ctx, p); err != nil {
		return fmt.Errorf("postgres: insert correction: %w", err)
	}
	return nil
}

// AddTelemetry implements ports.TelemetryStore in one transaction.
func (s *Store) AddTelemetry(ctx context.Context, rows []domain.TelemetryCount) error {
	return pgx.BeginFunc(ctx, s.pool, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)
		for _, r := range rows {
			day, err := time.Parse(time.DateOnly, r.Day)
			if err != nil {
				return fmt.Errorf("postgres: telemetry day %q: %w", r.Day, err)
			}
			if err := q.AddTelemetry(ctx, db.AddTelemetryParams{Date: date(day), Metric: r.Metric, Dim: r.Dim, Count: r.Count}); err != nil {
				return fmt.Errorf("postgres: add telemetry: %w", err)
			}
		}
		return nil
	})
}

// LatestEvidence implements ports.EvidenceStore.
func (s *Store) LatestEvidence(ctx context.Context, profileID string) ([]byte, error) {
	summary, err := s.q.LatestEvidence(ctx, profileID)
	if errors.Is(err, pgx.ErrNoRows) {
		return nil, domain.ErrNotFound
	}
	if err != nil {
		return nil, fmt.Errorf("postgres: latest evidence: %w", err)
	}
	return []byte(summary), nil
}

// PutEvidence stores the evidence summary of a profile version. The lab's
// publish step calls it (§15 D86); the API only reads.
func (s *Store) PutEvidence(ctx context.Context, profileID, version string, summary []byte) error {
	if err := s.q.PutEvidence(ctx, db.PutEvidenceParams{ProfileID: profileID, Version: version, Summary: string(summary)}); err != nil {
		return fmt.Errorf("postgres: put evidence: %w", err)
	}
	return nil
}

// DailySalt implements ports.SaltSource: the first caller of a day inserts a
// random salt and every caller reads the stored one.
func (s *Store) DailySalt(ctx context.Context, day domain.Day) (domain.Salt, error) {
	salt := make([]byte, 32)
	if _, err := rand.Read(salt); err != nil {
		return nil, fmt.Errorf("postgres: salt: %w", err)
	}
	if err := s.q.InsertSalt(ctx, db.InsertSaltParams{Day: date(day.Time), Salt: salt}); err != nil {
		return nil, fmt.Errorf("postgres: insert salt: %w", err)
	}
	stored, err := s.q.GetSalt(ctx, date(day.Time))
	if err != nil {
		return nil, fmt.Errorf("postgres: get salt: %w", err)
	}
	return stored, nil
}

// Consume implements ports.RateLimiter with one atomic upsert.
func (s *Store) Consume(ctx context.Context, p domain.Pseudonym, day domain.Day, limit int, now time.Time) (bool, error) {
	if limit < 1 || limit > 1<<20 {
		return false, fmt.Errorf("postgres: limit %d out of range", limit)
	}
	_, err := s.q.ConsumeRateLimit(ctx, db.ConsumeRateLimitParams{
		Pseudonym: p[:], Day: date(day.Time), CreatedUtc: ts(now), MaxCount: int32(limit),
	})
	if errors.Is(err, pgx.ErrNoRows) {
		return false, nil
	}
	if err != nil {
		return false, fmt.Errorf("postgres: consume: %w", err)
	}
	return true, nil
}

// AttestedKey implements ports.AttestedKeyStore.
func (s *Store) AttestedKey(ctx context.Context, p domain.Pseudonym) (ports.AttestedKey, error) {
	row, err := s.q.GetAttestedKey(ctx, p[:])
	if errors.Is(err, pgx.ErrNoRows) {
		return ports.AttestedKey{}, domain.ErrNotFound
	}
	if err != nil {
		return ports.AttestedKey{}, fmt.Errorf("postgres: attested key: %w", err)
	}
	if row.Counter < 0 || row.Counter > 1<<32-1 {
		return ports.AttestedKey{}, fmt.Errorf("postgres: attested key counter %d out of range", row.Counter)
	}
	return ports.AttestedKey{PublicKey: row.PublicKey, Counter: uint32(row.Counter)}, nil
}

// PutAttestedKey implements ports.AttestedKeyStore.
func (s *Store) PutAttestedKey(ctx context.Context, p domain.Pseudonym, k ports.AttestedKey, now time.Time) error {
	err := s.q.PutAttestedKey(ctx, db.PutAttestedKeyParams{Pseudonym: p[:], PublicKey: k.PublicKey, Counter: int64(k.Counter), CreatedUtc: ts(now)})
	if err != nil {
		return fmt.Errorf("postgres: put attested key: %w", err)
	}
	return nil
}

// AdvanceCounter implements ports.AttestedKeyStore.
func (s *Store) AdvanceCounter(ctx context.Context, p domain.Pseudonym, counter uint32) (bool, error) {
	n, err := s.q.AdvanceCounter(ctx, db.AdvanceCounterParams{Pseudonym: p[:], Counter: int64(counter)})
	if err != nil {
		return false, fmt.Errorf("postgres: advance counter: %w", err)
	}
	return n == 1, nil
}

// Claim implements ports.IdempotencyStore.
func (s *Store) Claim(ctx context.Context, k ports.IdempotencyKey, hash [32]byte, now time.Time) (ports.Claim, error) {
	n, err := s.q.ClaimIdempotencyKey(ctx, db.ClaimIdempotencyKeyParams{Route: k.Route, Key: k.Key, RequestHash: hash[:], CreatedUtc: ts(now)})
	if err != nil {
		return ports.Claim{}, fmt.Errorf("postgres: claim: %w", err)
	}
	if n == 1 {
		return ports.Claim{Outcome: ports.ClaimNew}, nil
	}
	row, err := s.q.GetIdempotencyKey(ctx, db.GetIdempotencyKeyParams{Route: k.Route, Key: k.Key})
	if errors.Is(err, pgx.ErrNoRows) {
		// Released between the insert and this read: the client may retry.
		return ports.Claim{Outcome: ports.ClaimInFlight}, nil
	}
	if err != nil {
		return ports.Claim{}, fmt.Errorf("postgres: read claim: %w", err)
	}
	switch {
	case string(row.RequestHash) != string(hash[:]):
		return ports.Claim{Outcome: ports.ClaimMismatch}, nil
	case !row.Status.Valid:
		return ports.Claim{Outcome: ports.ClaimInFlight}, nil
	default:
		return ports.Claim{Outcome: ports.ClaimReplay, Response: ports.StoredResponse{
			Status: int(row.Status.Int32), ContentType: row.ContentType.String, Body: row.Body,
		}}, nil
	}
}

// Complete implements ports.IdempotencyStore.
func (s *Store) Complete(ctx context.Context, k ports.IdempotencyKey, r ports.StoredResponse) error {
	if r.Status < 100 || r.Status > 599 {
		return fmt.Errorf("postgres: status %d out of range", r.Status)
	}
	n, err := s.q.CompleteIdempotencyKey(ctx, db.CompleteIdempotencyKeyParams{
		Route: k.Route, Key: k.Key,
		Status:      pgtype.Int4{Int32: int32(r.Status), Valid: true},
		ContentType: pgtype.Text{String: r.ContentType, Valid: true},
		Body:        r.Body,
	})
	if err != nil {
		return fmt.Errorf("postgres: complete: %w", err)
	}
	if n != 1 {
		return fmt.Errorf("postgres: complete unclaimed key on %s", k.Route)
	}
	return nil
}

// Release implements ports.IdempotencyStore.
func (s *Store) Release(ctx context.Context, k ports.IdempotencyKey) error {
	if err := s.q.ReleaseIdempotencyKey(ctx, db.ReleaseIdempotencyKeyParams{Route: k.Route, Key: k.Key}); err != nil {
		return fmt.Errorf("postgres: release: %w", err)
	}
	return nil
}

// Purge implements ports.Purger in one transaction.
func (s *Store) Purge(ctx context.Context, c domain.Cutoffs) (domain.PurgeCounts, error) {
	var n domain.PurgeCounts
	err := pgx.BeginFunc(ctx, s.pool, func(tx pgx.Tx) error {
		q := s.q.WithTx(tx)
		steps := []struct {
			name string
			run  func() (int64, error)
			into *int64
		}{
			{"corrections", func() (int64, error) { return q.PurgeCorrections(ctx, ts(c.CorrectionsBefore)) }, &n.Corrections},
			{"telemetry", func() (int64, error) { return q.PurgeTelemetry(ctx, date(c.TelemetryBefore.Time)) }, &n.Telemetry},
			{"rate limits", func() (int64, error) { return q.PurgeRateLimits(ctx, ts(c.PseudonymsBefore)) }, &n.Pseudonyms},
			{"attested keys", func() (int64, error) { return q.PurgeAttestedKeys(ctx, ts(c.PseudonymsBefore)) }, nil},
			{"idempotency keys", func() (int64, error) { return q.PurgeIdempotencyKeys(ctx, ts(c.IdempotencyBefore)) }, &n.Idempotency},
			{"salts", func() (int64, error) { return q.PurgeSalts(ctx, date(c.SaltsBefore.Time)) }, &n.Salts},
		}
		for _, step := range steps {
			count, err := step.run()
			if err != nil {
				return fmt.Errorf("postgres: purge %s: %w", step.name, err)
			}
			if step.into == nil {
				n.Pseudonyms += count
				continue
			}
			*step.into += count
		}
		return nil
	})
	if err != nil {
		return domain.PurgeCounts{}, err
	}
	return n, nil
}

// Ping implements ports.Pinger.
func (s *Store) Ping(ctx context.Context) error {
	if err := s.pool.Ping(ctx); err != nil {
		return fmt.Errorf("postgres: ping: %w", err)
	}
	return nil
}

func ts(t time.Time) pgtype.Timestamptz { return pgtype.Timestamptz{Time: t.UTC(), Valid: true} }

func date(t time.Time) pgtype.Date { return pgtype.Date{Time: t.UTC(), Valid: true} }
