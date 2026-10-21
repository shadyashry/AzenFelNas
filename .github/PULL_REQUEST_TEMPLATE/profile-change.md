<!-- Use for any change under profiles/ (ADR-008, DESIGN.md §9.2). Requires CODEOWNERS review from the accuracy lead and a Sharia reviewer (REQ-GOV-002). -->

## Profile change

- profileId(s) and version(s):
- Status before → after (`DRAFT_UNVERIFIED | CANDIDATE | APPROVED | RETIRED`):
- `effectiveFrom` (one date for all users, REQ-GOV-004):

## Evidence

<!-- Sources (title, URL, retrievedOn, sha256), benchmark set, holdout report, benchmarkReportId. -->

## Displayed-time impact

<!-- Lab benchmark output for the derivation set; holdout report link (REQ-GOV-003). -->

## Prohibited-practice checks (§9.2)

- [ ] `|perEventMinutes[*]| ≤ maxAbsMinutes`.
- [ ] No angle change in the same PR as tz/coordinate data changes.
- [ ] `rounding.* = nearest` on an entry event only with `approvals.religious.scope` containing `rounding`.
- [ ] `status: APPROVED` only with both approvals and a holdout report (REQ-GOV-001).

## Change note (ar / en)

- ar:
- en:
