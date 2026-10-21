# ADR-008 · Sharia approval is a signed field; profiles are GitOps

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-008 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Profiles are YAML in `profiles/` with CODEOWNERS `@accuracy-lead` + `@sharia-reviewer`; the compiled `profiles.json` is signed as a TUF target. CI refuses `production` promotion without `approvals.religious` and a holdout report.

## Trade-offs

- **Win:** governance by construction, no authoring UI.
- **Lose:** reviewers use a Git PR flow (templates + a one-page guide in `profiles/README-for-reviewers.md`).

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

—

## Supersedes

—
