## Scope

- Slice: S__ (`DESIGN.md` §13)
- REQ IDs: `REQ-…`

## What changed

## How it was tested

<!-- Paste command output (melos run ci, uv run pytest, go test, …). Device-dependent behaviour: attach the physical-device test plan; never claim a simulator verified it. -->

## Schema / ADR changes

<!-- Schema first, then models, then fixtures (ADR-023). Name every ADR or §15 row touched. -->

## §17.8 review checklist

- [ ] 1. One reason to change per class; no type-tag `if` that should be a sealed variant.
- [ ] 2. Layer boundaries respected (arch lint green); wiring only in the composition root.
- [ ] 3. No `dynamic`, `!`, `!!`, force-unwrap, `Any`, ignored error or catch-all without justification.
- [ ] 4. Fallible paths typed and mapped to a user-facing state.
- [ ] 5. New public APIs documented with their contract and covered by a contract test.
- [ ] 6. Nothing religious, locational or time-zone-related hard-coded that belongs in a profile or package.
- [ ] 7. Tests named by behaviour/REQ; fakes limited to ports; invariants property-tested.
- [ ] 8. Contract changed ⇒ schema first, regenerated, ADR updated.
