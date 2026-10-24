-- Control-plane schema (DESIGN.md §9.3, §15 D86). Applied by `api migrate` (goose) in the deploy job.

-- +goose Up
CREATE TABLE corrections (
    id           uuid PRIMARY KEY,
    received_utc timestamptz NOT NULL,
    kind         text NOT NULL CHECK (kind IN ('zone', 'profile', 'hijri', 'other')),
    payload_json jsonb NOT NULL,
    country      char(2) CHECK (country ~ '^[A-Z]{2}$'),
    -- numeric(5,2) stores at most 2 decimals exactly (REQ-PRIV-001).
    rounded_lat  numeric(5, 2) CHECK (rounded_lat BETWEEN -90 AND 90),
    rounded_lon  numeric(5, 2) CHECK (rounded_lon BETWEEN -180 AND 180),
    status       text NOT NULL DEFAULT 'new' CHECK (status IN ('new', 'accepted', 'rejected', 'duplicate')),
    reviewed_by  text,
    reviewed_utc timestamptz,
    CHECK ((rounded_lat IS NULL) = (rounded_lon IS NULL))
);
CREATE INDEX corrections_received_utc ON corrections (received_utc);
CREATE INDEX corrections_status ON corrections (status) WHERE status = 'new';

CREATE TABLE telemetry_daily (
    date   date NOT NULL,
    metric text NOT NULL,
    dim    text NOT NULL,
    count  bigint NOT NULL CHECK (count >= 0),
    PRIMARY KEY (date, metric, dim)
);

-- json, not jsonb: the summary is served byte-for-byte as published.
CREATE TABLE evidence_summaries (
    profile_id   text NOT NULL,
    version      text NOT NULL CHECK (version ~ '^\d{4}\.\d{1,2}\.\d+$'),
    summary_json json NOT NULL,
    PRIMARY KEY (profile_id, version)
);

-- Everything below holds the daily pseudonym or its inputs and lives at most 24 h (REQ-PRIV-007).
CREATE TABLE daily_salts (
    day  date PRIMARY KEY,
    salt bytea NOT NULL CHECK (length(salt) = 32)
);

CREATE TABLE rate_limits (
    pseudonym   bytea NOT NULL CHECK (length(pseudonym) = 32),
    day         date NOT NULL,
    count       integer NOT NULL CHECK (count > 0),
    created_utc timestamptz NOT NULL,
    PRIMARY KEY (pseudonym, day)
);
CREATE INDEX rate_limits_created_utc ON rate_limits (created_utc);

CREATE TABLE attested_keys (
    pseudonym   bytea PRIMARY KEY CHECK (length(pseudonym) = 32),
    public_key  bytea NOT NULL,
    counter     bigint NOT NULL CHECK (counter >= 0),
    created_utc timestamptz NOT NULL
);
CREATE INDEX attested_keys_created_utc ON attested_keys (created_utc);

CREATE TABLE idempotency_keys (
    route        text NOT NULL,
    key          text NOT NULL,
    request_hash bytea NOT NULL CHECK (length(request_hash) = 32),
    created_utc  timestamptz NOT NULL,
    status       integer,
    content_type text,
    body         bytea,
    PRIMARY KEY (route, key)
);
CREATE INDEX idempotency_keys_created_utc ON idempotency_keys (created_utc);

-- +goose Down
DROP TABLE idempotency_keys;
DROP TABLE attested_keys;
DROP TABLE rate_limits;
DROP TABLE daily_salts;
DROP TABLE evidence_summaries;
DROP TABLE telemetry_daily;
DROP TABLE corrections;
