# ADR-009 · Distribution: static, signed, TUF-lite; no runtime prayer API

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-009 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Object storage + CDN; four metadata roles; monotonic `sequence`; signature envelope over JCS-canonical JSON (Appendix C). Rollback = new manifest with a higher sequence pointing at old content.

## Trade-offs

- **Win:** cheap, cacheable, resists freeze/rollback/CDN compromise.
- **Lose:** client-side verification code (small, specified).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
