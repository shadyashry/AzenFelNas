-- name: InsertCorrection :exec
INSERT INTO corrections (id, received_utc, kind, payload_json, country, rounded_lat, rounded_lon, status)
VALUES (sqlc.arg(id), sqlc.arg(received_utc), sqlc.arg(kind), sqlc.arg(payload_json), sqlc.narg(country), sqlc.narg(rounded_lat), sqlc.narg(rounded_lon), sqlc.arg(status));

-- name: AddTelemetry :exec
INSERT INTO telemetry_daily (date, metric, dim, count)
VALUES (@date, @metric, @dim, @count)
ON CONFLICT (date, metric, dim) DO UPDATE SET count = telemetry_daily.count + EXCLUDED.count;

-- name: LatestEvidence :one
SELECT summary_json::text AS summary
FROM evidence_summaries
WHERE profile_id = @profile_id
ORDER BY string_to_array(version, '.')::int[] DESC
LIMIT 1;

-- name: PutEvidence :exec
INSERT INTO evidence_summaries (profile_id, version, summary_json)
VALUES (@profile_id, @version, CAST(sqlc.arg(summary)::text AS json))
ON CONFLICT (profile_id, version) DO UPDATE SET summary_json = EXCLUDED.summary_json;

-- name: InsertSalt :exec
INSERT INTO daily_salts (day, salt) VALUES (@day, @salt) ON CONFLICT (day) DO NOTHING;

-- name: GetSalt :one
SELECT salt FROM daily_salts WHERE day = @day;

-- name: ConsumeRateLimit :one
INSERT INTO rate_limits (pseudonym, day, count, created_utc)
VALUES (@pseudonym, @day, 1, @created_utc)
ON CONFLICT (pseudonym, day) DO UPDATE SET count = rate_limits.count + 1
WHERE rate_limits.count < @max_count::integer
RETURNING count;

-- name: GetAttestedKey :one
SELECT public_key, counter FROM attested_keys WHERE pseudonym = @pseudonym;

-- name: PutAttestedKey :exec
INSERT INTO attested_keys (pseudonym, public_key, counter, created_utc)
VALUES (@pseudonym, @public_key, @counter, @created_utc)
ON CONFLICT (pseudonym) DO UPDATE SET public_key = EXCLUDED.public_key, counter = EXCLUDED.counter;

-- name: AdvanceCounter :execrows
UPDATE attested_keys SET counter = @counter WHERE pseudonym = @pseudonym AND counter < @counter;

-- name: ClaimIdempotencyKey :execrows
INSERT INTO idempotency_keys (route, key, request_hash, created_utc)
VALUES (@route, @key, @request_hash, @created_utc)
ON CONFLICT (route, key) DO NOTHING;

-- name: GetIdempotencyKey :one
SELECT request_hash, status, content_type, body FROM idempotency_keys WHERE route = @route AND key = @key;

-- name: CompleteIdempotencyKey :execrows
UPDATE idempotency_keys SET status = @status, content_type = @content_type, body = @body
WHERE route = @route AND key = @key AND status IS NULL;

-- name: ReleaseIdempotencyKey :exec
DELETE FROM idempotency_keys WHERE route = @route AND key = @key AND status IS NULL;

-- name: PurgeCorrections :execrows
DELETE FROM corrections WHERE received_utc < @before;

-- name: PurgeTelemetry :execrows
DELETE FROM telemetry_daily WHERE date < @before;

-- name: PurgeRateLimits :execrows
DELETE FROM rate_limits WHERE created_utc < @before;

-- name: PurgeAttestedKeys :execrows
DELETE FROM attested_keys WHERE created_utc < @before;

-- name: PurgeIdempotencyKeys :execrows
DELETE FROM idempotency_keys WHERE created_utc < @before;

-- name: PurgeSalts :execrows
DELETE FROM daily_salts WHERE day < @before;
