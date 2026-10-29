# ADR-025 · S19 native spike: plan, go/no-go criteria and report

- **Status:** `[PROPOSED · device results OWED]`. The code, receipt protocol, scenario matrix and verdict tool are in place; no physical-device run has happened, so **no path has a go or a no-go yet**. Nothing below is a measured result.
- **Source:** `DESIGN.md` §13 S19, ADR-012, ADR-013, §8.1–§8.3, §15 D79.
- **Time box:** 5 working days of device time (owner).

## Context

ADR-012 and ADR-013 defer four questions to S19: does an exact alarm reliably start a `mediaPlayback` foreground service on current Android (and what does the fallback look like); does AlarmKit `.fixed(Date)` deliver with a receipt we can trust enough to show `READY` (§8.3); does an AlarmKit sound play longer than 30 s; does iOS keep exactly 64 pending notification requests. Only physical devices answer them, and simulators prove nothing here (CLAUDE.md).

## What was built (slice S19)

| Piece | Where | State |
|---|---|---|
| Receipt protocol (labels for `event_log.v1` lines, no schema change) | `apps/mobile/lib/features/delivery_spike/domain/spike_protocol.dart`, mirrored in `SpikeLabels.kt` / `SpikeLabels.swift` | tested |
| Verdict evaluator `EvaluateSpikeRun` (go / no-go / insufficient evidence per path) | `apps/mobile/lib/features/delivery_spike/application/` | 14 tests |
| Verdict CLI | `apps/mobile/tool/spike_verdict.dart` | run on a sample |
| Android spike: `setAlarmClock` → `SpikeAlarmReceiver` → `SpikePlaybackService` (FGS `mediaPlayback`, `USAGE_ALARM`), inexact fallback notification, direct-boot re-arm, adb entry `SpikeActivity` | `apps/mobile/android/athan-core/src/debug/` (debug builds only; app takes `debugImplementation(project(":athan-core"))`) | ktlint 1.8.0 + detekt 1.23.8 clean; **not compiled** (no Android SDK in the session) |
| iOS spike: AlarmKit `.fixed(Date)` with bundled sound, `alerting` observer, Stop `LiveActivityIntent` receipt, 64-budget probe, URL entry `azenfelnas://spike/...` | `apps/mobile/ios/AthanKit/Sources/AthanKit/Spike/`, `Runner/SceneDelegate.swift` (behind `DEBUG && canImport(AthanKit)`), `NSAlarmKitUsageDescription` in `Info.plist` | SwiftLint 0.65.1 `--strict` clean (syntax rules); **not compiled** (no Xcode) |

Receipts land where the product will put them (§8.1/§8.2): Android `<device-protected files>/plan/events.jsonl`, iOS `<App Group>/plan/events.jsonl`, so S20/S21 reuse the store and Dart drains them (REQ-ALM-041).

## Receipt protocol

| Line | `entryId` | `state` | `reason` | `durationMs` |
|---|---|---|---|---|
| `ALARM_SCHEDULED` | 16 hex | scenario | `android_exact` · `android_inexact` · `ios_alarmkit` | trigger − `utcMs` |
| `ALARM_PRESENTED` | ✓ | — | `receiver` · `fgs_started` · `fgs_denied` · `audio_started` · `notification_posted` · `alarmkit_alerting` | lateness vs trigger |
| `ALARM_DISMISSED` | ✓ | — | `user_stop` · `audio_completed` | ringing time |
| `TEST_RESULT` | optional | — | `heard` · `not_heard` · `long_audio_full` · `long_audio_cut` · `pending_budget` | heard ms (`count` = pending for the budget) |

## Go / no-go criteria (engineering defaults, §15 D79)

A path is **GO** when every required scenario has ≥ 3 judged entries and every judged entry passed; **NO-GO** when any judged entry failed; otherwise **INSUFFICIENT EVIDENCE**. An entry with no receipt is judged missed 30 min after its trigger.

| Path | An entry passes when | Required scenarios |
|---|---|---|
| `androidExactFgs` | `fgs_started` and `audio_started` both ≤ 5 s after trigger, no `fgs_denied`, not reported `not_heard` | foreground, doze, swiped, reboot_unlocked, reboot_locked, battery_saver, dnd_alarms |
| `androidInexactFallback` | `notification_posted` ≤ 15 min after trigger | exact_revoked |
| `iosAlarmKitDelivery` | `alarmkit_alerting` ≤ 5 s late, or a `user_stop` receipt; not `not_heard` | foreground, locked_killed, reboot, silent_switch, focus |
| `iosAlarmKitLongAudio` | ≥ 3 `long_audio_full`, no `long_audio_cut` | — |
| `iosNotificationBudget` | every `pending_budget` count is exactly 64 after asking for 70 | — |

## Device plan (owner)

**Devices.** Android: a Pixel on Android 16 (stock), a Samsung on One UI 8, one aggressive-OEM device (Xiaomi HyperOS or Oppo ColorOS), and one API 26–30 device. iOS: an iPhone on iOS 26.x (AlarmKit, long audio, budget) and one on iOS 18.x (budget). Record model and OS build per log file.

**Android.** Build `flutter run --debug`. Optional long clip: `adb push athan.ogg /data/local/tmp/` then `adb shell run-as app.azenfelnas sh -c 'mkdir -p /data/user_de/0/app.azenfelnas/files/athan && cp /data/local/tmp/athan.ogg /data/user_de/0/app.azenfelnas/files/athan/spike.ogg'`. Schedule with
`adb shell am start -n app.azenfelnas/app.azenfelnas.athan.spike.SpikeActivity --es cmd schedule --es scenario <s> --ei inSeconds <n> --ei count 3 --ei spacingSeconds 600`.

| Scenario | Set-up after scheduling |
|---|---|
| foreground | app open, screen on |
| doze | screen off, `adb shell dumpsys battery unplug && adb shell dumpsys deviceidle force-idle` |
| swiped | swipe the app from recents |
| reboot_unlocked | `adb reboot`, unlock before the trigger |
| reboot_locked | `adb reboot`, do **not** unlock before the trigger (direct boot) |
| battery_saver | `adb shell settings put global low_power 1` |
| dnd_alarms | Do Not Disturb on, alarms allowed |
| exact_revoked | `adb shell appops set app.azenfelnas SCHEDULE_EXACT_ALARM deny` (or Settings › Alarms & reminders off) before scheduling |

Answer per entry: `--es cmd heard|not_heard --es entryId <id>`. Pull: `adb shell run-as app.azenfelnas cat /data/user_de/0/app.azenfelnas/files/plan/events.jsonl > <device>.jsonl`.

**iOS.** In Xcode: add `apps/mobile/ios/AthanKit` as a local package to the Runner target, add the App Group `group.app.azenfelnas.shared` capability, add a long sound (≥ 3 min `.caf`) to the Runner bundle. Run a debug build on the device; open URLs from Safari or Notes:
`azenfelnas://spike/schedule?scenario=<s>&in=<seconds>&count=3&spacing=600&sound=<file>` · `azenfelnas://spike/observe` (foreground scenario) · `azenfelnas://spike/answer?reason=heard|not_heard|long_audio_full|long_audio_cut&entry=<id>&heard=<seconds>` (time the long clip with a stopwatch) · `azenfelnas://spike/budget?requested=70` · `azenfelnas://spike/export`, then Xcode › Devices › Download Container › `Documents/spike-events.jsonl`.
Scenarios: foreground, locked_killed (lock and swipe the app away), reboot (restart before the trigger), silent_switch (ring/silent switch or Action button on silent), focus (a Focus that silences all apps).

**Verdict.** `cd apps/mobile && dart run tool/spike_verdict.dart <device>.jsonl...` prints one line per path and exits 0 only if all five are GO. Paste the output below and change this ADR's status.

## Decision per outcome

| Path | GO ⇒ | NO-GO ⇒ |
|---|---|---|
| `androidExactFgs` | ADR-012 stands; S21 builds §8.1 as designed. | The receiver posts a high-importance alarm-stream notification instead of starting the service on the failing device class; Health `LIMITED`; OEM guidance row added. |
| `androidInexactFallback` | REQ-ALM-027 as designed. | Keep the path; Health copy states the observed worst-case delay. |
| `iosAlarmKitDelivery` | AlarmKit path may report `READY` (§8.3); amend ADR-013. | AlarmKit path stays `LIMITED(unverifiableDelivery)` like the notification path. |
| `iosAlarmKitLongAudio` | AlarmKit plays the full Athan. | AlarmKit uses the ≤ 29 s clip catalogue too (REQ-ALM-034). |
| `iosNotificationBudget` | S20 fits plans to 64. | S20 fits to the lowest observed count; amend ADR-013. |

Until results exist, S20–S22 build to the designed paths with the conservative state: Android exact → FGS as §8.1 with the notification fallback wired, iOS AlarmKit never `READY`, iOS notification clips ≤ 29 s, budget 64.

## Results

**OWED** — no device run yet. Per path: `androidExactFgs` OWED · `androidInexactFallback` OWED · `iosAlarmKitDelivery` OWED · `iosAlarmKitLongAudio` OWED · `iosNotificationBudget` OWED.

## REQ tags

REQ-ALM-020, REQ-ALM-021, REQ-ALM-022, REQ-ALM-023, REQ-ALM-027, REQ-ALM-030, REQ-ALM-031, REQ-ALM-032, REQ-ALM-034, REQ-ALM-040, REQ-ALM-041.

## Tests

`apps/mobile/test/features/delivery_spike/evaluate_spike_run_test.dart` (verdict logic only; delivery itself is device evidence).
