# Sign-off and change approvals

`DESIGN.md` §23.3 (change control) and §23.4 (sign-off block). Changes to `DESIGN.md` need a PR, an ADR entry and the Architect's approval; religious-semantics sections also need a Sharia board member.

## Sign-off block (§23.4)

Business ☐ · Product ☐ · Architect ☐ · Sharia board chair ☐ · Security ☐

## Approved changes to `DESIGN.md`

| Date | Change | Sections | Approved by | Basis |
|---|---|---|---|---|
| 2026-10-21 | ADR-019 tolerances: altitude formula only above `0.001° / 60 s`, explicit `NEAR_TANGENT` grading, Dhuhr fixed 0.2 s time tolerance with its offset checked separately | §4 ADR-019, §15 D26 | Project owner (acting Architect) | Owner's recommendation and the S03 architect review (findings F7, owner points 1–3) |
| 2026-10-21 | S05 ships a minimal bench CLI; S05 differential covers 49 cities × 12 monthly dates | §13 S05/S06, §15 D30 | Project owner (acting Architect) | S03 architect review (F2, F7) |
| 2026-10-21 | Engine bench contract carries the Hijri state; comparison rules, profile allow-list, Dhuhr offset check | §15 D29 | Project owner (acting Architect) | S03 architect review (F1, F4, F5) |
| 2026-10-21 | MET Norway accepted as the S03 done-test's published source | §15 D31 | Project owner (acting Architect) | USNO unreachable; S03 architect review (F6) |

None of these changes touches religious semantics (§6.4–§6.5, D2–D4, D8, D12), so no Sharia board approval is required. The real Architect confirms them in PR review if the project owner is not the Architect.
