# CLAUDE.md — working agreement for this repository

Read `DESIGN.md` (v1.1) first. It is the normative solution and engineering design; the documents under
`docs/solution-architecture/` are background only, and where they disagree with `DESIGN.md`, `DESIGN.md` wins.

## Where to start
- Work proceeds in the **ordered slices of `DESIGN.md §13`** (S01 → S28). Start with S01. A slice may begin only when its listed inputs exist; it is done when its done-test passes and the §12 gates are green.
- Each slice names the `REQ-*` IDs it must satisfy; every ID is defined in `DESIGN.md Appendix F`. Name tests after them.
- Toolchain versions: `DESIGN.md §5.4` gives floors; in S01 pin the exact latest stable ≥ floor and never float afterwards.
- If a task needs a decision that is not in `DESIGN.md §4` (ADRs) or `§15` (open decisions), add a row to §15 with an engineering default and continue — do not block, do not guess a religious value.
- Read the relevant `schemas/*.schema.json` before touching a model; change the schema first, then the models and fixtures (ADR-023).

## Hard rules (DESIGN.md §0.2 — summarised; the full text is binding)
- No religious parameter (angle, offset, rounding mode, high-latitude method, Iqama interval, Ramadan rule) in Dart/Kotlin/Swift/Go/Python. Only in `profiles/*.yaml`; seed profiles stay `DRAFT_UNVERIFIED` and load on `dev`/`lab` only.
- The pure Dart set (`dm_core_types`, `geo_salah_core`, `geo_salah_profiles`, `dm_civil_time`, `dm_hijri`, `dm_packages`) imports nothing from Flutter or the platform. The arch lint enforces it; never disable it.
- Golden corpus changes go in a separate PR labelled `golden-update` with the numeric diff and the cause.
- Store UTC epoch-ms + `zoneId` + `tzdbVersion`; derive local time with the app's pinned TZDB, never the OS one.
- Native alarm code reads `SchedulePlan` only and must work with no Dart isolate alive.
- No raw coordinates or persistent identifiers in logs, telemetry or diagnostics. No `AD_ID` permission. Only `cdn.dailymuslim.app` and `api.dailymuslim.app` may be contacted.
- Confidence labels are the sealed `ConfidenceLabel` type with the fixed mapping in §6.2. `Unknown` beats an invented value.
- New dependency ⇒ license check + one line in `DESIGN.md §4` or a new `docs/adr/` file.
- Code quality bar is `DESIGN.md §17`: SOLID as the concrete rules in §17.1 (one use case per class, sealed types + exhaustive switch for variation, narrow consumer-defined ports, wiring only in the composition root), strict typing per language (§17.2–§17.6: no `dynamic`/`!`/`!!`/force-unwrap/`Any`; strict analyzer and lint configs in CI), tests named by behaviour and `REQ` with fakes only at ports (§17.7). Review your own PR against the checklist in §17.8 before proposing it.

## How to work
- One slice = 1–5 small PRs; each PR has tests for the `REQ-*` it touches and updates docs/ADRs when a contract changes.
- Run `melos run ci` before proposing a PR. Device-dependent work (alarms, compass, reboot) is specified with a physical-device test plan in the PR description; never claim a simulator verified it.
- If you are the only implementer: write and freeze the lab harness (S03) before the engine, and do not read the harness code while writing S04–S06.
- Prefer boring technology; anything not in `DESIGN.md §4` is proposed as an ADR, never adopted silently.
- Status copy (Calculated / Authority aligned / Verified / Estimated / Observed / Unknown / Expected) comes only from the shared constants in §18.5; prohibited-word tests guard it.

## Repository map
See `DESIGN.md §5.3`. Commands: `melos bootstrap`, `melos run ci`, `melos run gen` (pigeon + freezed + json codegen),
`dart run geo_salah_core:bench` (engine benchmark, JSONL in/out), `uv run lab benchmark` (accuracy lab), `go run ./tools/gsctl` (package build/sign/publish/promote).

## Commit attribution
End commit messages with:
```
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01JR22gw2wi15YPqVazNC5Xb
```
