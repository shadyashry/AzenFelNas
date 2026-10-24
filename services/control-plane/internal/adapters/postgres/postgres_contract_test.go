package postgres_test

import (
	"context"
	"crypto/rand"
	"encoding/hex"
	"net/url"
	"os"
	"slices"
	"testing"

	"github.com/jackc/pgx/v5"

	"github.com/samehamin/daily_muslim/services/control-plane/internal/adapters/postgres"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/domain"
	"github.com/samehamin/daily_muslim/services/control-plane/internal/ports/porttest"
)

// testDSN returns DM_PG_TEST_URL, a Postgres 16 server URL whose user may
// create databases (CI starts postgres:16.15), or skips the test.
func testDSN(t *testing.T) string {
	t.Helper()
	dsn := os.Getenv("DM_PG_TEST_URL")
	if dsn == "" {
		t.Skip("DM_PG_TEST_URL not set; the Postgres contract runs in ci-go")
	}
	return dsn
}

// freshDatabase creates an empty, migrated database and drops it after the test.
func freshDatabase(t *testing.T, serverDSN string) string {
	t.Helper()
	ctx := context.Background()
	b := make([]byte, 6)
	if _, err := rand.Read(b); err != nil {
		t.Fatal(err)
	}
	name := "cp_test_" + hex.EncodeToString(b)
	admin, err := pgx.Connect(ctx, serverDSN)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = admin.Close(context.Background()) })
	if _, err := admin.Exec(ctx, "CREATE DATABASE "+name); err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() {
		if _, err := admin.Exec(context.Background(), "DROP DATABASE "+name+" WITH (FORCE)"); err != nil {
			t.Errorf("drop %s: %v", name, err)
		}
	})
	u, err := url.Parse(serverDSN)
	if err != nil {
		t.Fatal(err)
	}
	u.Path = "/" + name
	if err := postgres.Migrate(ctx, u.String()); err != nil {
		t.Fatal(err)
	}
	return u.String()
}

func open(t *testing.T, dsn string) *postgres.Store {
	t.Helper()
	s, err := postgres.Open(context.Background(), dsn)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(s.Close)
	return s
}

func TestREQTEST004PostgresStoreContract(t *testing.T) {
	server := testDSN(t)
	dsns := map[porttest.Subject]string{}
	porttest.Run(t, porttest.Harness{
		New: func(t *testing.T) porttest.Subject {
			dsn := freshDatabase(t, server)
			s := open(t, dsn)
			dsns[s] = dsn
			return s
		},
		SeedEvidence: func(t *testing.T, s porttest.Subject, id, version string, summary []byte) {
			store, ok := s.(*postgres.Store)
			if !ok {
				t.Fatal("not a postgres store")
			}
			if err := store.PutEvidence(context.Background(), id, version, summary); err != nil {
				t.Fatal(err)
			}
		},
		CorrectionIDs: func(t *testing.T, s porttest.Subject) []domain.ReceiptID {
			var ids []domain.ReceiptID
			for _, id := range queryStrings(t, dsns[s], "SELECT id::text FROM corrections ORDER BY received_utc, id") {
				ids = append(ids, domain.ReceiptID(id))
			}
			return ids
		},
		TelemetryCount: func(t *testing.T, s porttest.Subject, day, metric, dim string) int64 {
			conn, err := pgx.Connect(context.Background(), dsns[s])
			if err != nil {
				t.Fatal(err)
			}
			defer func() { _ = conn.Close(context.Background()) }()
			var n int64
			err = conn.QueryRow(context.Background(), "SELECT coalesce(sum(count), 0) FROM telemetry_daily WHERE date = $1::date AND metric = $2 AND dim = $3", day, metric, dim).Scan(&n)
			if err != nil {
				t.Fatal(err)
			}
			return n
		},
	})
}

func TestREQPRIV001DatabaseStoresAtMostTwoDecimals(t *testing.T) {
	dsn := freshDatabase(t, testDSN(t))
	open(t, dsn)
	got := queryStrings(t, dsn, "SELECT (30.044::numeric(5,2))::text")
	if !slices.Equal(got, []string{"30.04"}) {
		t.Fatalf("numeric(5,2) kept %v", got)
	}
}

func queryStrings(t *testing.T, dsn, sql string) []string {
	t.Helper()
	conn, err := pgx.Connect(context.Background(), dsn)
	if err != nil {
		t.Fatal(err)
	}
	defer func() { _ = conn.Close(context.Background()) }()
	rows, err := conn.Query(context.Background(), sql)
	if err != nil {
		t.Fatal(err)
	}
	out, err := pgx.CollectRows(rows, pgx.RowTo[string])
	if err != nil {
		t.Fatal(err)
	}
	return out
}
