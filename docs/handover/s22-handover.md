# S22 hand-over (iOS `AthanKit`) → S23

Branch `slice/s22-ios-athan`, cut from `slice/s21-android-athan` at `b26793d`. No PR was opened: the owner rule from 2026-10-22 (S17 hand-over) is to review the branch directly. Setup: `docs/handover/cloud-environment.md` (its script worked as written; a new "Swift on Linux" section was added).

## Built (`apps/mobile/ios/AthanKit`, mechanics in §15 D82)
- **Scheduling/**: `DeliveryWindow` (future entries; Athans → AlarmKit on iOS 26+ when authorised, everything else → notifications; each cut to 64 − 1 in D80 order, horizon warning always kept), `RearmFromPlan` (diffs platform plan requests against the window, so it is idempotent and never touches Test/spike ids), `ApplyPlan`, `CancelGenerationsBelow`, `ReconcileOutcome` (the D81 variants), `Receipts`, `PlanIds` (AlarmKit UUID = entry id twice), `TriggerInterval` (interval from absolute instant).
- **Health/**: D81 ordering, path-dependent severities; `EvaluateHealth` appends `deliveryVerified` itself, `false` on the notification path, and `AlarmKitEvidence.deliveryProven = false` keeps AlarmKit below READY until ADR-025 GO.
- **Audio/**: `AthanClipCatalog` (manifest `iosClip`, ≤ min(29 s, policy)), `SoundLibrary` + `InstallClips` (`Library/Sounds/<soundId>.caf`, atomic rename), `InstalledClips`.
- **SelfTest/**: `StartAthanTest` (same path as Athans), `NativeCopy` (drafts in `Resources/native_copy.json`, en/ar).
- **Bridge/**: `AthanBridge` (reconcile, rearm, cancelGenerationsBelow, health, startTest, drainEvents) and the composition root `AthanGraph`.
- **Platform/** (Darwin only): `UserNotificationsAdapter`, `NotificationReceipts` delegate, `AlarmKitAdapter` + `StopAthanAlarmIntent`, `DarwinPathGate`, `DarwinProbes`, `AthanGraph.live(assets:)`.
- **Plan/**: `EventsStore` (append under a `Mutex`, drain by rename); `PlanDirectory.appGroup` is nil off Darwin.
- **Schema first:** `athan_audio_manifest.v1` gains optional `iosClip` (.caf, ≤ 29 000 ms), with 2 invalid fixtures; `dm_contracts` `AthanIosClip` regenerated.
- **Runner:** `Runner.entitlements` (App Group, time-sensitive) and `PrivacyInfo.xcprivacy` wired into `project.pbxproj` (parsed back with `openstep_parser`).
- `.swiftformat` disables `swiftTestingTestCaseNames` (justified in the file; closes the S20 carry-over).

## Evidence (this session, Linux)
- **First real Swift run of AthanKit:** Swift 6.2 (`swift:6.2-noble`, Docker Hub) `swift test`: **48/48** (24 earlier + 24 new; the S20 tests had never run). Strict Swift 6 mode, 0 warnings. `Platform/` and `Spike/` are excluded by `canImport` on Linux and were **not compiled**.
- SwiftLint 0.65.1 `--strict`: 0 (SourceKit rule `statement_position` skipped on Linux). SwiftFormat 0.64.0 `--lint`: 0.
- `dart run melos run ci`: **SUCCESS** (app 316, dm_contracts 20; arch_lint 0 violations in 595 files; req_index 0 problems in 1511 files). `schemas/tools/validate_fixtures.sh`: exit 0.
- Not run: Xcode build, `ci-ios`, any simulator or device test. Go, Kotlin and the lab were not touched.

## REQ IDs proved by named Swift tests
REQ-ALM-002, REQ-ALM-003, REQ-ALM-030, REQ-ALM-031 (incl. a source scan for calendar triggers), REQ-ALM-032, REQ-ALM-033 (all 3¹⁰ probe outcomes), REQ-ALM-034, REQ-ALM-035, REQ-ALM-036, REQ-ALM-040, REQ-ALM-041, REQ-DOM-040. Device behaviour for all of them is OWED.

## §15 rows and ADRs
- **D82** (new): path, ids, window, reconcile, health severities, clips, receipts, copy and entitlements, Linux build.
- ADR-013 S22 note in §4 and `docs/adr/` (REQ tags and tests filled). §8.2 status line. No new dependency (Docker image and lint binaries are local tools only).

## Owed / open
- **Owner, macOS:** link AthanKit into Runner (local package reference), wire `AthanGraph.live` / receipts / re-arm triggers in `AppDelegate`, run `swift test` + `flutter build ios` (`ci-ios`; S17 noted the runner lacks SwiftLint 0.65.1). Steps: `docs/test-plans/s22-ios-athan-device-suite.md`.
- **Owner, devices:** the 14-scenario suite (iOS 26 AlarmKit, iOS 18 notifications, silent switch, Focus, budget, TZ/time change, reboot, Test) and the ADR-025 run; then flip `AlarmKitEvidence.deliveryProven` only with receipts.
- **Owner, App Store Connect:** App Group + time-sensitive capability on `app.dailymuslim`; early internal TestFlight build (not submitted).
- **Product / Content:** Test/Stop copy (en/ar drafts), which kinds are time-sensitive, foreground presentation, no Snooze on iOS. **Privacy:** review the privacy manifest (no collected types declared).
- **S23:** pigeon contract + host over `AthanBridge`; ship `assets/athan/athan_audio_manifest.json` and `.caf` clips; consider Dart `FitSlotBudget` at 63 to match the native Test slot; Dart Health must mirror D82 severities; `BGAppRefreshTask` decision.

## Inputs for S23 (Athan feature UI)
- Native contracts: `AthanBridge` (iOS) and Kotlin `AthanBridge` (Android) — same operations, outcomes and `events.jsonl` codes; receipt stages D81 + `user_open`.
- Health: `HealthReport.platformPath` ∈ `androidExact | androidInexact | iosAlarmKit | iosNotification`; iOS is never READY today (REQ-ALM-033, ADR-025).
- Probe names: Kotlin `health/Health.kt` labels and Swift `ProbeName` raw values.
