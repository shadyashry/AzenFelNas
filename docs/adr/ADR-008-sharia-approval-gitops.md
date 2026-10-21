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

## Gate stages in place (slice S07, 2026-10-21)

- `ParsePrayerProfile` enforces the Appendix A CI gate: `APPROVED` needs both approvals and a holdout report. It also enforces the §9.2 prohibited practices that a single profile can show: offsets within `maxAbsMinutes`, and `nearest` rounding of an entry event only with `rounding` in the religious scope.
- `CheckProfileChannel` keeps `DRAFT_UNVERIFIED` and `CANDIDATE` on `dev`/`lab` (Appendix E).
- `profiles-gate` runs the schema stage, the non-overlap and conformance tests, and fails closed for any profile above `DRAFT_UNVERIFIED`. The compile/sign (S09), lab-benchmark and holdout stages are still owed (§15 D52).
- "No angle change in a PR that also touches tz/coordinate data" is a PR-level check and stays with the S09 gate.

## Compile and signing gate (slice S09, 2026-10-22)

- `gsctl validate` / `gsctl build` compile `profiles/*/*.yaml` into the signed `profiles.json` package (§15 D60). They refuse a set that breaks the Appendix A governance gate (`APPROVED` without both approvals and a holdout report) or the Appendix E channel gate. This is the signing-time gate of REQ-GOV-001 (§15 D61).
- `profiles-gate` now runs this compile stage. The D52 semantics stay in `geo_salah_profiles`, which `release-package` also runs before `gsctl build`. The gate still fails closed above `DRAFT_UNVERIFIED` until the lab-benchmark and holdout stages exist.
- `gsctl check-change` enforces the §9.2 PR-level rule "no angle change in a PR that also touches tz/coordinate data" (§15 D64). `profiles-gate` runs it against the PR's merge base.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

`REQ-GOV-001` (profile-level gate since S07, signing-time gate in `gsctl` since S09), `REQ-GOV-003`

## Tests

- `packages/geo_salah_profiles/test/parse_prayer_profile_test.dart`: the APPROVED gate, nearest rounding, offsets and Ramadan events.
- `packages/geo_salah_profiles/test/check_profile_channel_test.dart`: the channel gate.
- `tools/gsctl/internal/domain/profileset/compile_test.go`, `tools/gsctl/internal/app/app_test.go`: the signing-time governance and channel gates.
- `tools/gsctl/internal/domain/profileset/change_gate_test.go`, `tools/gsctl/main_test.go`: the §9.2 angle and tz/coordinate rule.

## Supersedes

—
