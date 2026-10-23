# S19 hand-over (native spike) → S20

Branch `slice/s19-native-spike`, cut from `slice/s18-passport-qibla`. No PR, per the owner rule of 2026-10-22 (see the S17 hand-over); review the branch directly. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

S19 needs physical devices, so it is owner-only. This session wrote the spike code, the receipt protocol, the verdict tool and the plan. **No device ran anything, and no path has a go or a no-go.**

## Built
- **Receipt protocol and verdict** (`apps/mobile/lib/features/delivery_spike/`): `SpikeLabels`, `SpikeCriteria`, sealed `SpikeVerdict` (Go / NoGo / InsufficientEvidence) and `SpikeFailure`, and `EvaluateSpikeRun`, which reads `event_log.v1` receipts and gives one verdict for each of five paths. `apps/mobile/tool/spike_verdict.dart` is the CLI. No schema change.
- **Android** (`athan-core/src/debug/`, debug builds only): `SpikeScheduler` (`setAlarmClock`, or `setAndAllowWhileIdle` without exact alarms; request code derived from the entry id), `SpikeAlarmReceiver` → `SpikePlaybackService` (FGS `mediaPlayback`, `USAGE_ALARM`, stop action), inexact fallback notification, `SpikeBootReceiver` (direct-boot re-arm), `SpikeEventLog` (device-protected `plan/events.jsonl`), and the adb entry point `SpikeActivity`. The app now takes `debugImplementation(project(":athan-core"))`.
- **iOS** (`AthanKit/Sources/AthanKit/Spike/`): AlarmKit `.fixed(Date)` scheduling with a bundled sound, an `alerting` observer, a Stop `LiveActivityIntent` receipt, the 64-budget probe (asks for 70) and log export. All of it is driven by `dailymuslim://spike/...` URLs, which `SceneDelegate` handles only under `DEBUG && canImport(AthanKit)`. `NSAlarmKitUsageDescription` was added with draft copy.
- **Docs:** `docs/adr/ADR-025-s19-native-spike.md` (the spike report: protocol, criteria, device plan, decision per outcome, results OWED). It is indexed in DESIGN.md §4, and ADR-012/013 point to it.

## Evidence (this session, Linux)
- `evaluate_spike_run_test.dart` passes 14/14. The verdict CLI ran on a sample log (budget GO, other paths INSUFFICIENT, exit 1).
- `dart run melos run ci` reports **SUCCESS**: format, analyze `--fatal-infos`, arch_lint 0 violations (580 files), req_index 0 problems (1401 files). App tests 292 (278 before); the other packages are unchanged.
- Android: ktlint 1.8.0 and detekt 1.23.8 (the CI pins, checksums verified) are clean over `athan-core/src`. The code is **not compiled**: `dl.google.com` is denied, so there is no Android SDK here.
- iOS: SwiftLint 0.65.1 `--strict` (the Linux static binary, syntax rules only, SourceKit rules skipped) is clean on AthanKit. The code is **not compiled**: there is no Xcode or Swift here. The AlarmKit calls follow the iOS 26 SDK documentation and need checking against Xcode.
- Go, lab, schemas and pipelines were not touched, so they were not run.

## REQ IDs proved by named tests (verdict logic only)
REQ-ALM-020, REQ-ALM-023, REQ-ALM-027, REQ-ALM-030, REQ-ALM-032, REQ-ALM-034, REQ-ALM-041. These tests prove the go/no-go rules. They do not prove delivery, which needs device evidence.

## §15 rows and ADRs
- **D79**: S19 spike mechanics (receipt labels, thresholds, scenario matrix, debug-only placement, conservative state until results arrive).
- **ADR-025** (new, `PROPOSED · device results OWED`); **ADR-012/013** amended to point to it. No new dependency.

## Owed / open
- **Owner, physical devices (the S19 done-test itself):** run the ADR-025 device plan (Android: Pixel/Android 16, Samsung One UI 8, an aggressive OEM, an API 26–30 device; iOS: an iPhone on 26.x and one on 18.x), then run `dart run tool/spike_verdict.dart`, paste the output into ADR-025 and set its status.
- **Owner, macOS/Xcode:** add AthanKit as a local package to Runner, add the App Group capability and a long `.caf`, then build. Run SwiftLint with SourceKit and `swift test`.
- **Owner, Android:** build the debug APK (still blocked by the inherited compileSdk 37 / `permission_handler_android` issue) and run lint for `NewApi`.
- **Product:** `NSAlarmKitUsageDescription` copy (en draft; ar missing).
- **Carried from S18:** the inherited CI blockers (gen step vs D68, gitleaks false positive at `ci-lab.yml:47`, SwiftLint on the `ios` runner, compileSdk); Qibla and deep-link device checks; `SyncPackages` on app open; bundled fonts; RTL goldens.

## Inputs for S20 (`SchedulePlan` builder + `Snapshot` + plan/snapshot stores)
- Build to the ADR-025 conservative state: iOS budget = 64, fitted by priority from the farthest day (REQ-ALM-032); AlarmKit never `READY`; iOS notification sounds ≤ 29 s clips.
- Plan and events live at `plan/plan.json` and `plan/events.jsonl` (Android device-protected storage, iOS App Group). The spike's `SpikeEventLog` (Kotlin and Swift) shows the append format and can become `EventsStore`.
- Wire models already exist in `dm_contracts` and in `athan-core/plan` / `AthanKit/Plan` (S02).
