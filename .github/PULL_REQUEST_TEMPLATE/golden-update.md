<!-- Use only for golden corpus changes (DESIGN.md §0.2 rule 3, ADR-019). Label this PR `golden-update`. It must contain no other change. -->

## Golden corpus update

- Engine version before → after:
- Corpus files touched (`packages/geo_salah_core/test/golden/…`):

## Numeric diff

<!-- Per (city, profileId, day, event): old rawUtcMs, new rawUtcMs, delta ms. Attach the full diff as an artifact if large. -->

| city | profileId | day | event | old rawUtcMs | new rawUtcMs | Δ ms |
|---|---|---|---|---|---|---|

## Cause

<!-- Written cause of every change. Link the engine PR that made it. -->

## Lab confirmation

<!-- Lab run (Skyfield + de440s) showing every changed value is within ADR-019 tolerance. Paste the summary and link the artifact. -->

- [ ] Every changed value is within ADR-019 tolerance of the lab reference.
- [ ] No unrelated file changed.
