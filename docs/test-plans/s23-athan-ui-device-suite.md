# S23 Athan feature UI — owner build and device plan

Nothing here has been run on a device or simulator. The Dart and Linux Swift results are in `docs/handover/s23-handover.md`.

## 1. Builds (owner)

| Step | Where | Command / action | Pass when |
|---|---|---|---|
| B1 | Linux/macOS with `dl.google.com` | `cd apps/mobile/android && ./gradlew :athan-core:testDebugUnitTest :app:assembleDebug lint` | green; `AthanCoreHost.kt`, `AthanSchedulerHost.kt` and the generated `AthanSchedulerApi.g.kt` compile with `allWarningsAsErrors` |
| B2 | macOS, Xcode 26 | Add `Runner/Pigeon/AthanSchedulerApi.g.swift` and `Runner/AthanSchedulerHost.swift` to the Runner target; link the local `AthanKit` package (S22 plan step 1) | `flutter build ios --no-codesign` green |
| B3 | macOS | In `AppDelegate.didInitializeImplicitFlutterEngine`, add `AthanSchedulerHost.register(messenger: registrar.messenger(), assetURL: { path in Bundle.main.url(forResource: FlutterDartProject.lookupKey(forAsset: "assets/" + path), withExtension: nil) })` under a `DmAthan` registrar | the Athan page shows a Health state other than "Not available" |
| B4 | macOS | `swift test` in `ios/AthanKit` (Darwin files included) and `ci-ios` | green |

## 2. Device runs (owner; Android API 34 + 36, iPhone iOS 18 and iOS 26)

| # | Scenario | Steps | Expected |
|---|---|---|---|
| U0 | No plan yet | Fresh install (plan wiring open, D83) | "Not ready" with "Open the app to schedule the Athan" |
| U1 | Health, all granted (after the plan wiring lands) | Fresh install, grant notifications (+ exact alarms on Android, AlarmKit on iOS 26), open `/health` | Android: "Ready" or "Limited" with reasons; iOS 18: "Limited · This phone cannot confirm the Athan played"; iOS 26: "Limited" until ADR-025 GO |
| U2 | Health, notifications denied | Deny notifications, open `/health` | "Not ready" with "Allow notifications for Azen Fel Nas" |
| U3 | Test heard | Pick a sound, tap the Test, lock the phone | Athan at +60 s (± 2 s on the exact/AlarmKit path); question after ≥ 10 s; "Yes" ⇒ "Recorded: you heard the test"; `TEST_RESULT state=heard` in diagnostics |
| U4 | Test not heard | Silent mode / muted channel, run the Test, answer "No" | Health becomes "Limited" with "You did not hear the last test" |
| U5 | Receipt evidence | Run U3 with the app killed after arming (Android) | after reopening and answering, `TEST_RESULT reason=presented` |
| U6 | Drain on start | Let an Athan fire with the app killed, reopen | the event log holds the `ALARM_PRESENTED` line; `events.jsonl` is empty afterwards |
| U7 | Pre-reminder | Set 10 min (needs the `ApplyAthanPlan` wiring open in D83) | the next plan holds `PRE_REMINDER` entries 10 min before each Athan |
| U8 | RTL / 200 % text | Arabic locale, largest font | the page scrolls; no clipped text |

Record each run with device, OS build, timestamps and screenshots; never mark a row green from a simulator.
