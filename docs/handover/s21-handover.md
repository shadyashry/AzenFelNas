# S21 hand-over (Android `athan-core`) → S22

Branch `slice/s21-android-athan`, cut from `slice/s20-schedule-plan` at `8921352`. No PR was opened, per the owner rule from 2026-10-22 recorded in the S17 hand-over: review the branch directly. Setup: `docs/handover/cloud-environment.md`. Its script worked as written.

## Built (`apps/mobile/android/athan-core`, mechanics in §15 D81)
- **schedule/**: `ArmingWindow` arms the next 200 future entries. ATHAN entries use `setAlarmClock`, the other kinds use `setExactAndAllowWhileIdle`, and every entry uses `setAndAllowWhileIdle` when exact alarms are not allowed. `RearmFromPlan` runs on every system event and after every fire. `ApplyPlan` is the bridge's `reconcile`: it writes the plan, disarms the entries the new plan dropped, then re-arms. Outcomes are `Applied | Partial | NoPlan | Stale | Failed`. `AndroidAlarmPort` is the adapter.
- **receive/**: `AlarmReceiver`, plus `BootReceiver` (locked and unlocked boot), `TimeChangeReceiver`, `PackageReplacedReceiver` and `ExactAlarmPermissionReceiver`. All are `exported=false` and `directBootAware`, and they do their work under `goAsync` on a worker thread. `ChoosePresentation` picks full Athan, a notification, or `Drop` when the entry is gone from the plan. Receipts go to `events.jsonl` with the S19 stage labels.
- **playback/**: `AthanForegroundService` is a `mediaPlayback` FGS with `USAGE_ALARM` and a partial wake lock. It has a Stop action and offers Snooze once (`policy.snoozeMinutes`). When the FGS start is refused, the notification fallback is posted (D79). Audio is read from device-protected `files/athan/<soundId>.m4a`; when that file is missing, the default alarm sound plays and `AUDIO_ASSET_MISSING` is logged.
- **notify/**: channel ids are `athan_` + sha256(`KIND|soundId|v`)[0:12]. `ChannelRegistry` keeps one group per kind and migrates settings to a replacement channel. Copy is in `res/values{,-ar}/strings.xml` (drafts).
- **health/**: `AndroidProbes` (10 probes) and `PlanProbes` feed `EvaluateHealth`, which applies NOT_READY > LIMITED > UNKNOWN > READY.
- **selftest/**: `StartAthanTest` arms the Test through the real path.
- **bridge/**: `AthanGraph` is the composition root. `AthanBridge` covers the `AthanSchedulerApi` operations. The pigeon host is **not** generated yet (see Owed).
- **debug**: `AthanSuiteActivity`, an adb driver for the device suite (`apply`, `health`, `test`, `drain`).
- The app module now takes `implementation(project(":athan-core"))` in every build type, not only debug.

## Evidence (this session, Linux)
- **Kotlin, compiled and tested for real:** standalone kotlinc 2.4.21 compiled main and debug against Robolectric `android-all` 16 (API 36, Maven Central) with `-Xexplicit-api=strict -Werror`. This is the first time the Android-facing code has been type-checked. The R class was a compile-only stub, and resources and API-level lint were not checked. JUnit 6.1.3 ran **74/74** tests: 16 from S20 and 58 new. ktlint 1.8.0 and detekt 1.23.8 (the CI pins, checksums verified) are clean.
- Not run: Gradle, Android Lint, Robolectric tests or any device test. The 72 h device suite (the done-test) is **OWED**.
- `dart run melos run ci` reports **SUCCESS**. Dart was not changed, so the app still has 316 tests. arch_lint found 0 violations in 595 files, and req_index 0 problems in 1476 files (that count includes the new Kotlin tests and docs).
- Go, the lab, the schemas and Swift were not touched.

## REQ IDs proved by named JVM tests
REQ-ALM-001, REQ-ALM-002, REQ-ALM-003, REQ-ALM-010, REQ-ALM-020, REQ-ALM-021 (request codes, manifest, immutable flags), REQ-ALM-022 (manifest), REQ-ALM-023 (decision, manifest, sound probe), REQ-ALM-024, REQ-ALM-025, REQ-ALM-026, REQ-ALM-027, REQ-ALM-040, REQ-ALM-041, REQ-ALM-042, REQ-DOM-040. Device behaviour for all of them is still OWED.

## §15 rows and ADRs
- **D81** (new) covers the arming window, delivery modes, reconcile, events, presentation, channels, health ordering, bridge and the Linux build.
- ADR-012 has an S21 note in both §4 and `docs/adr/`. No new dependency: `android-all` and kotlinc are local verification tools only, not part of the build.

## Owed / open
- **Owner, devices:** `docs/test-plans/s21-android-athan-device-suite.md` (15 scenarios, 72 h, at least 3 devices), plus the S19 ADR-025 run.
- **Owner, Android build:** Gradle `assembleDebug`, `testDebugUnitTest` and Android Lint (NewApi, resources). They are still blocked here by `dl.google.com`.
- **S23 (or earlier):** the pigeon contract (§7.8) in `dm_contracts`, with its Dart caller and the generated Kotlin host delegating to `AthanBridge`. A pigeon dependency needs a license line in ADR-011 when it is added. Dart's Health state machine must mirror the D81 ordering.
- **S23 (Athan UI) or a follow-up:** per-sound channel URIs, and copying `assets/athan/*.m4a` to device-protected `files/athan/` when Athan is enabled. The iOS clip check (REQ-ALM-034) belongs to S22.
- **Product / Content:** Stop, Snooze, channel and Test copy (en and ar drafts), and whether the phone should vibrate during full Athan playback (today the playback channel vibrates once when `policy.vibrate`).
- Carried from S20: the AthanKit `swift test` run and the SwiftFormat rule decision.

## Inputs for S22 (iOS `AthanKit`)
- Mirror the Android contract: `RearmFromPlan`/`ApplyPlan` outcomes, `events.jsonl` receipts (`PLAN_APPLIED` reasons, stage labels) and the D81 health ordering. Remember that the iOS notification path never reports READY (REQ-ALM-033).
- Health probe names are the `label`s in `athan-core/health/Health.kt`. Reuse them where the semantics match.
