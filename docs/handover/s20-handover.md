# S20 hand-over (`SchedulePlan` builder + `Snapshot` + plan/snapshot stores) → S21

Branch `slice/s20-schedule-plan`, cut from `slice/s19-native-spike` at `dee2b2c`. No PR was opened: the S17 hand-over records an owner rule from 2026-10-22 that says no PRs, so review the branch directly. Setup: `docs/handover/cloud-environment.md`. Its script worked as written.

## Built
- **Dart (`apps/mobile/lib/features/athan/`)**
  - `BuildSchedulePlan` turns engine days into the §7.7 plan. `ATHAN` entries fire at `displayedUtcMs`. The plan also holds `IMSAK` entries, `PRE_REMINDER` entries at the global offset, and one `HORIZON_WARNING`, which fires 48 h before the plan ends on Android and 24 h before on iOS. Entries already in the past are left out. `displayLocal` comes from the pinned TZDB.
  - `FitSlotBudget` fits the iOS plan into 64 slots. It drops priority 3 first, then priority 2, then the farthest Athans.
  - `PlanEntryId` is sha256 over `contextId|day|EVENT|KIND`, truncated to 16 hex digits. `PlanContextId` is `ctx_<id>`.
  - `BuildSnapshot` covers the next 48 h: items with confidence and detail, the sky timeline sampled every 5 min, and health passed in by the caller.
  - Plan copy goes through the `PlanTexts` port. The adapter is `ArbPlanTexts`, which reads 8 new ARB keys in en and ar.
  - `CalculateSchedule` gains `dayCount` (`planDays = 30`).
- **Android (`athan-core/plan/`):** `PlanStore`, `SnapshotStore`, `AtomicTextFile` (writes a tmp file, fsyncs, then renames), `WireDecode` and `PlanDirectory` (device-protected `plan/`). A store validates the document and refuses an older generation. The same generation is rewritten.
- **iOS (`AthanKit/Plan/`):** `PlanStore`, `SnapshotStore`, `WireFile` (`Data.write(.atomic)`) and `PlanDirectory.appGroup`. The contract matches Android, plus an `unwritable` outcome.
- **Schema fixtures (no schema change):** `schemas/fixtures/schedule_plan/valid/built_android.json` (299 entries over 30 days, Cairo), `built_ios.json` (64 entries) and `snapshot/valid/built.json`. The Dart tests compare the builders' output to these files byte for byte. After an engine or TZDB change, `DM_UPDATE_FIXTURES=1 flutter test test/features/athan` rewrites them; review that diff like a golden diff.

## Evidence (this session, Linux)
- `dart run melos run ci` reports **SUCCESS**: arch_lint found 0 violations in 595 files and req_index 0 problems in 1436 files. App tests: 316 (292 before; +24 in `test/features/athan`). `dm_contracts` tests pass 20/20, and those include round-trips of the new fixtures.
- `schemas/tools/validate_fixtures.sh` exits 0. ajv accepts all three built fixtures.
- **Kotlin compiled and tested for the first time:** standalone kotlinc 2.4.21 with the serialization plugin, `-Xexplicit-api=strict -Werror`, built `plan/` and `codes/` plus their tests. JUnit 6.1.3 ran **16/16** (PlanStore 5, wire round-trips including the new fixtures, codes mirror). This was not a Gradle build: `PlanDirectory.kt` (android.Context) was left out because `dl.google.com` is still denied. ktlint 1.8.0 and detekt 1.23.8 are clean.
- **Swift:** SwiftLint 0.65.1 `--strict` (Linux static binary) is clean. The code is **not compiled**, because there is no Swift toolchain (`download.swift.org` is denied). SwiftFormat 0.64.0 (Linux) flags only its `swiftTestingTestCaseNames` rule on the new test file. It flags the same rule on every existing `@Test("…")` file, and it also flags the S19 spike files. That is pre-existing; see Open.
- Go, the lab and the pipelines were not touched, so they were not run.

## REQ IDs proved by named tests
REQ-ALM-001, REQ-ALM-010, REQ-ALM-021 (deterministic ids), REQ-ALM-032 (the done-test: iOS budget fitting), REQ-ALM-042, REQ-TIME-001, REQ-TIME-020, REQ-UX-001 (snapshot confidence detail), REQ-DOM-040 (plan copy is in both locales). In Kotlin, and in Swift (written but not run): REQ-ALM-035 (atomic write) and REQ-ALM-002 (an older generation never replaces the plan; a malformed plan is rejected).

## §15 rows and ADRs
- **D80** (new): kinds and sounds, ids, horizon and warning, iOS fitting, policy values, snapshot window and sky sampling, store contract, fixture regeneration.
- ADR-002 now points to the S20 builder and stores. No new third-party dependency: `crypto` 3.0.7 was already in the workspace lock and used by `geo_salah_core` and `dm_packages`, and it is now a direct dependency of the app.

## Owed / open
- **Product / Content:** the plan copy (8 ARB keys, en and ar drafts in an Egyptian tone); whether Sunrise should alert (schema v1 has no kind for it); the sound for non-Athan entries (`notification_default`).
- **Owner, macOS/Xcode:** run `swift test` for AthanKit (the new `PlanStoreTests`), and decide whether to adopt SwiftFormat's raw-identifier test names or disable `swiftTestingTestCaseNames` in `.swiftformat`.
- **Owner, Android:** a Gradle build and `testDebugUnitTest` (still blocked by `dl.google.com` and the inherited compileSdk issue).
- **iOS clip check (REQ-ALM-034):** the builder does not yet check that the Athan `soundId` is a ≤ 29 s clip in the audio manifest. That belongs to S22.
- **Carried from S19:** the ADR-025 device run (S19 done-test), plus the inherited CI blockers and device checks listed in the S19 hand-over.

## Inputs for S21 (Android `athan-core`)
- Read the plan only with `PlanStore(PlanDirectory.of(context)).read()`. The bridge's `reconcile(json)` calls `PlanStore.write` and diffs by entry id + generation. Request codes come from the 16-hex id.
- The Dart side builds with `BuildSchedulePlan(tzdb, ArbPlanTexts())(PlanRequest(…, target: AndroidPlanTarget()))` from `CalculateSchedule(…, dayCount: CalculateSchedule.planDays)`. Wiring (providers, Appendix K settings → `AthanPreferences`, generation persistence) is not done yet.
- `SpikeEventLog` (debug) shows the `events.jsonl` append format that `EventsStore` should use. Build the notification fallback alongside the exact path (D79).
