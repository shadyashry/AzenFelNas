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

## Autonomous cloud workflow (from S10, decided by the owner on 2026-10-22)
- **Repository:** `shadyashry/AzenFelNas` is `origin`. `samehamin/daily_muslim` is the earlier home: never push there.
- **One slice per cloud session.** The cloud routine "AzenFelNas: one slice per session" runs every 2 hours. Each run does exactly one slice and then stops: it finishes a half-done slice, or starts the next one in §13 order.
- **Heartbeat:** while working, push a WIP commit to the slice branch, or an empty commit to `automation/heartbeat`, at least every 30 minutes. A run stands down when any `slice/*` or `automation/*` branch moved in the last 90 minutes.
- **Branches and PRs:** branches are stacked (`slice/sNN-<name>` is cut from the previous slice's branch). Each slice gets one draft PR whose base is the previous slice's branch. Nothing is merged or pushed to `main`; the owner reviews and merges.
- **No questions to the owner:** decide after brief, targeted research and record the decision as the next `DESIGN.md §15` row. Religious values stay data and are never chosen (§0.2 rule 1). Owner-only items are written as code plus a plan and listed as **owed** in the hand-over: devices, macOS/Xcode builds, cloud accounts, secrets, approvals, store, key ceremony.
- **Hand-over:** every slice ends with a short `docs/handover/sNN-handover.md`. `docs/handover/cloud-environment.md` holds the toolchain setup script; run it as written.

## Token discipline
- Read `CLAUDE.md` and only the previous slice's hand-over, not every hand-over.
- Never print `DESIGN.md` whole. Extract only what the slice needs with grep/sed: §0.2, the slice's §13 row, §17, the cited ADRs, sections and appendices, the REQ lines (`grep 'REQ-AREA'`), and §15 rows by number or keyword.
- Read code through `rg` hits and `sed -n 'a,bp'` ranges, and don't re-read files you have already read or edited.
- Keep tool output short: `tail -20`, or a `FAIL|error` grep. Write full logs to `/tmp`.
- During development run only the affected package's tests. Run the full gates (`melos run ci`, Go `-race`, lab, schemas) once, at the end of the slice.
- Keep hand-overs and PR descriptions short; evidence is test counts and gate results, not pasted logs.

## Repository map
See `DESIGN.md §5.3`. Commands: `melos bootstrap`, `melos run ci`, `melos run gen` (pigeon + freezed + json codegen),
`dart run geo_salah_core:bench` (engine benchmark, JSONL in/out), `uv run lab benchmark` (accuracy lab), `go run ./tools/gsctl` (validate, check-change, build, sign, verify, publish and serve; promote arrives in S25).

## Commit attribution
End commit messages with:
```
Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
Claude-Session: https://claude.ai/code/session_01JR22gw2wi15YPqVazNC5Xb
```
