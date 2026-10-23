# S23 hand-over (Athan feature UI) → S24

Branch `slice/s23-athan-ui`, cut from `slice/s22-ios-athan` at `cf14c20`. No PR, per the owner rule of 2026-10-22 (S17 hand-over): review the branch directly. Setup: `docs/handover/cloud-environment.md`; its script and the "Swift on Linux" steps worked as written.

## Built (mechanics in §15 D83)
- **Contract:** pigeon 29.0.11 `AthanSchedulerApi` (`packages/dm_contracts/pigeons/`, `melos run gen:pigeon`); generated Dart, Kotlin and Swift committed. §7.8 changes: `startTest` returns `bool`; one `@async drainEvents()` of `event_log.v1` lines replaces `drainReceipts`/`drainSystemEvents`.
- **Dart `features/athan`:** `EvaluateAthanHealth` + `ProbeRules` (D81/D82 table; Dart ignores the native `state`), `AdvanceAthanTest` (pure Test machine), `StartAthanTest`, `RecordAthanTestResult`, `TestPresentation`; ports `ReadPlatformHealth`, `ArmAthanTest`, `DrainNativeEvents`, `ReadLastTestHeard`, `ReadAthanSounds`; pigeon/asset/event-log adapters; `AthanTestController`; the Athan page (Health card, Test panel, sound, pre-reminder) at `/health`, replacing the placeholder, linked from Settings and the Home Athan row. `StartApp` drains native events on every start (REQ-ALM-041). en/ar copy drafts.
- **Native hosts:** `athan-core` public `AthanCoreHost` + app-module `AthanSchedulerHost` (registered in `MainActivity`; app adds `kotlinx-coroutines-android`); AthanKit public `AthanHost` (+ Darwin `AthanHost.live`) + `Runner/AthanSchedulerHost.swift` (behind `canImport(AthanKit)`).

## Evidence (this session, Linux)
- `dart run melos run ci`: **SUCCESS** — app **360** tests (316 before, +44), dm_contracts 20; analyze clean; arch_lint 0 violations in 624 files; req_index 0 problems in 1567 files.
- Swift 6.2 (`swift:6.2-noble`, Docker) `swift test`: **50/50** (48 + 2 new `AthanHost` tests), 0 warnings; SwiftLint 0.65.1 `--strict` 0; SwiftFormat 0.64.0 `--lint` 0. `Platform/` (incl. `AthanHostLive.swift`) and Runner are not compiled on Linux.
- Not run: Gradle/Kotlin compile (dl.google.com blocked), Xcode/`ci-ios`, any simulator or device. Schemas, Go and the lab were not touched.

## REQ IDs proved by named Dart tests
REQ-ALM-003 (incl. property sweeps over all 3¹⁰ Android and 3¹¹ iOS-notification probe outcomes — the done-test), REQ-ALM-025, REQ-ALM-027, REQ-ALM-033, REQ-ALM-040, REQ-ALM-041, REQ-ALM-042, REQ-UX-030. Swift: REQ-ALM-033, REQ-ALM-040, REQ-ALM-041 for the public host. Port contract tests run against the fake and the pigeon adapters.

## §15 rows and ADRs
- **D83** (new): contract, Dart Health ordering, Test machine and timing (question 10 s after fire), receipts evidence, drain points, UI, and the open plan-application gap. §7.8 sketch, §8.3 status line and the ADR-011 dependency row (pigeon pin) updated. No new third-party dependency beyond the ADR-011 pigeon pin and the catalogued coroutines library.

## Owed / open
- **Open, recommended first PR of S24:** no slice wires `BuildSchedulePlan` → `reconcile` from Dart, and there are no per-prayer enable toggles. Until an `ApplyAthanPlan` use case exists, every device reports `notReady(stalePlan)` (D83).
- **Owner, Android build:** `./gradlew :athan-core:testDebugUnitTest :app:assembleDebug lint` (plan B1).
- **Owner, macOS:** add the two Runner Swift files to the target, link AthanKit, one `AppDelegate` line (plan B2–B4).
- **Owner, devices:** `docs/test-plans/s23-athan-ui-device-suite.md` U0–U8.
- **Content:** Athan recordings + `assets/athan/athan_audio_manifest.json` (+ iOS `.caf` clips); until then the sound list is empty and the Test asks for a sound.
- **Product / Content:** Health, reason and Test copy (en/ar drafts), the 10 s question delay, the Athan page at `/health`.
- Home still shows `AthanReadinessUnknown`; map Health into Home with the snapshot work.

## Inputs for S24 (privacy hardening)
- New egress: none (pigeon is in-process). New event-log writers: `TEST_RESULT` (`entryId`, `state`, `reason`) and drained native lines, all through the closed `event_log.v1` allow-list (lines with other keys are dropped — tested with a `lat` key).
- Diagnostics export can read `DriftEventLog.entries()` (now also used by `EventLogLastTest`).
- iOS privacy manifest unchanged since S22; the Runner host adds no API with a required reason.
