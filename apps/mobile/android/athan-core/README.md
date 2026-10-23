# athan-core (Kotlin)

Native Athan layer for Android (`DESIGN.md` §8.1, ADR-002, ADR-012). It reads the `SchedulePlan` only, works with no Dart isolate alive, and never calculates times.

| Package | Contents |
|---|---|
| `plan/` | Wire models, `PlanStore`, `SnapshotStore`, `EventsStore` (`events.jsonl`), all in device-protected `files/plan/` |
| `schedule/` | `ArmingWindow` (next 200 entries), `RearmFromPlan` (every system event and fire), `ApplyPlan` (bridge `reconcile`), `AndroidAlarmPort` (`setAlarmClock` / `setExactAndAllowWhileIdle` / `setAndAllowWhileIdle`) |
| `receive/` | `AlarmReceiver`, `BootReceiver`, `TimeChangeReceiver`, `PackageReplacedReceiver`, `ExactAlarmPermissionReceiver`; `ChoosePresentation`; receipts |
| `playback/` | `AthanForegroundService` (`mediaPlayback`, `USAGE_ALARM`, Stop / Snooze once), audio from `files/athan/<soundId>.m4a` |
| `notify/` | `ChannelSpec` ids `athan_<sha256(kind\|soundId\|v)[0:12]>`, `ChannelRegistry` (create + migrate), `AlertNotifications` |
| `health/` | `AndroidProbes`, `PlanProbes`, `EvaluateHealth` (§8.3) |
| `selftest/` | `StartAthanTest` (REQ-ALM-040) |
| `bridge/` | `AthanGraph` (composition root), `AthanBridge` (the `AthanSchedulerApi` operations; the pigeon host arrives with the contract, D81) |

Decisions: `DESIGN.md` §15 D79 (spike, fallback) and D81 (S21 mechanics). Device suite: `docs/test-plans/s21-android-athan-device-suite.md`.

The compiler bar: `explicitApi()`, warnings as errors, JVM 17, minSdk 26, compileSdk 36. Versions come from `../gradle/libs.versions.toml`. Lint: ktlint 1.8.0 and detekt 1.23.8 (`ci-android.yml`).

Without the Android SDK (no `dl.google.com`), the module can still be compiled and its JVM tests run with standalone `kotlinc` against Robolectric's `android-all` jar from Maven Central; see `docs/handover/s21-handover.md`.
