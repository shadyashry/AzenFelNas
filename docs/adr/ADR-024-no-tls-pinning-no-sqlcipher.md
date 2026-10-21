# ADR-024 · No TLS pinning; no SQLCipher

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-024 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

TUF signatures make integrity independent of TLS; pinning causes outages. Local databases rely on platform file encryption (Android credential-encrypted storage, iOS Data Protection `complete`); no secrets stored.

## Trade-offs

- **Win:** fewer outages, no local key management.
- **Lose:** none material under the threat model.

---

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
