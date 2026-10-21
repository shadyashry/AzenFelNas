<!-- Use only for changes to the frozen lab reference (lab/reference/**, DESIGN.md §9.4, ADR-019, kickoff §C). Label this PR `reference-update`; ci-lab fails without the label. It must contain no engine change, and the engine author must not write it. -->

## Lab reference update

- Why the reference changes (cities, `harness.v1.toml`, ephemeris pin, or reference-deciding code listed in `lab/src/dm_lab/manifest.py` `REFERENCE_SOURCES`):
- Manifest inputs that changed (role → old sha256 → new sha256):

## Numeric diff

<!-- Per (caseId, event): old kind/instant/tolerance → new. Attach the full diff as an artifact if large. -->

| caseId | event | old | new | Δ ms |
|---|---|---|---|---|

## Evidence

- [ ] `uv run --frozen lab reference --years 2026-2028` run twice: byte-identical output.
- [ ] `uv run --frozen pytest` green in `lab/`, including the published-source done-test.
- [ ] Architect and accuracy lead reviewed (CODEOWNERS `/lab/`).
- [ ] No engine or golden-corpus file changed.
