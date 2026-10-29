# S22 device suite — iOS `AthanKit`

The S22 done-test (`DESIGN.md` §13): a device suite that includes the silent switch (Health ⇒ `unknown` evidence) and shows the notification path is never `ready`, plus an early TestFlight submission. **Status: OWED (owner: macOS/Xcode 26.3, physical iPhones, App Store Connect).** Nothing in this repository claims these results until a run is recorded below. Mechanics under test: §15 D82; the AlarmKit go/no-go is ADR-025.

## Prerequisites (macOS, once)

1. Link AthanKit into Runner: Xcode → Runner project → Package Dependencies → *Add Local…* → `apps/mobile/ios/AthanKit`, add the `AthanKit` library to the Runner target. Commit the `project.pbxproj` change.
2. In `AppDelegate.swift`: build `AthanGraph.live(assets:)` once with an `AssetSource` over `FlutterDartProject.lookupKey(forAsset:)`, run `InstallClips` when Athan is on, set `NotificationReceipts` as `UNUserNotificationCenter.current().delegate`, start `AlarmKitAdapter.observe` on iOS 26, and call `AthanBridge.rearm(.appActive)` on `sceneDidBecomeActive`, `.timeChanged` on `significantTimeChangeNotification` and `.timezoneChanged` on `NSSystemTimeZoneDidChange`. (The pigeon host that exposes `AthanBridge` to Dart is S23's.)
3. Signing: enable the App Group `group.app.azenfelnas.shared` and *Time Sensitive Notifications* for `app.azenfelnas` in the developer portal; `Runner.entitlements` already lists both.
4. `swift test` in `apps/mobile/ios/AthanKit` on macOS (also compiles `Platform/` and `Spike/`, which Linux cannot), then `flutter build ios --simulator --debug` (`ci-ios`).
5. Clips: until S23 ships `assets/athan/athan_audio_manifest.json` and the `.caf` clips, use a hand-made manifest with one ≤ 29 s `.caf` (`afconvert -f caff -d ima4 in.m4a out.caf`) for the suite.

## Devices

At least: one iPhone on iOS 26.x (AlarmKit path), one on iOS 18.x (notification path). Run the AlarmKit scenarios once with AlarmKit authorised and once denied (falls back to notifications).

## Scenarios

Apply a plan whose instants start 5 minutes from now (the S20 `built_ios.json` fixture shifted in time; its times are test instants, not prayer times) through the debug bridge, then:

| # | Scenario | Expected |
|---|---|---|
| 1 | iOS 26, AlarmKit authorised, app in the foreground | Athan alerts as an AlarmKit alarm at `fireAtUtcMs` ± 1 s with the clip; `alarmkit_alerting` receipt; Health `limited(unverifiableDelivery)` until ADR-025 GO |
| 2 | iOS 26, app killed, phone locked | alarm alerts; Stop writes `user_stop` with the entry id (App Intent, no Dart) |
| 3 | iOS 26, **silent switch on** | AlarmKit alarm still sounds; Health report lists `silentSwitch` with `positive = nil` (informational on this path) |
| 4 | iOS 26, AlarmKit denied | path `iosNotification`; Health `notReady(needsAlarmKitAuthorization)`; notifications still delivered |
| 5 | iOS 18, notifications allowed, all probes otherwise positive | Health **never `ready`**: `limited(unverifiableDelivery)`; `silentSwitch` and `focusStatus` `positive = nil` |
| 6 | iOS 18, **silent switch on** | notification arrives without sound; Health unchanged (`unknown` evidence on the silent-switch probe, state never `ready`) |
| 7 | iOS 18, Focus on (no app allowed) | time-sensitive Athan breaks through only if *Time Sensitive Notifications* is allowed for the Focus; record what happens |
| 8 | Notifications denied | `notReady(needsNotificationPermission)` on iOS 18; `limited` on iOS 26 with AlarmKit authorised |
| 9 | Budget | plan with > 64 entries: `pendingNotificationRequests().count ≤ 64` after reconcile and Test |
| 10 | Time-zone change / manual time change | re-arm on the notification; intervals recomputed (first alert still at its absolute instant) |
| 11 | Reboot, then open the app | `PLAN_APPLIED reason=appActive`; nothing lost or doubled |
| 12 | Athan Test (60 s) on each path | fires through the same path; `TEST_STARTED state=iosAlarmKit/iosNotification` |
| 13 | Clip > 29 s in the manifest | never used; the system default sound plays |
| 14 | Drain | `drainEvents` returns each receipt once; a second drain is empty |

Record per run: device, iOS version, path, scenario, expected/observed, receipts (`events.jsonl` via Xcode → Download Container).

## Early TestFlight submission (owner)

After prerequisites 1–4: archive a `beta`-channel build (`--dart-define=DM_CHANNEL=beta`; seed profiles are draft, so Home shows *Needs attention* on beta, which is expected), upload with Xcode Organizer, and submit to internal TestFlight testing to surface App Review metadata issues early (`NSAlarmKitUsageDescription` copy, privacy manifest, time-sensitive entitlement). Record the build number and any review feedback here. No submission has been made.

## Results

None recorded.
