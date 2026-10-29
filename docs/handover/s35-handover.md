# S35 hand-over: test readiness (DESIGN.md §15 D95)

Branch `slice/s35-test-readiness`, cut from `main` at `e6a0969`.

## What changed
- **Release crash fixed.** Every release APK crashed at start (old Room via Glance → WorkManager 2.7.1). `athan-core` now pulls WorkManager 2.12.0 (Room 2.7.0); `ci-android` builds the release APK and checks the Room version.
- **Permissions.** Finishing onboarding asks for notifications (REQ-ALM-026). Athan Health shows *Allow* / *Open settings* for each fixable reason (notifications, exact alarms, muted channel, battery).
- **Health.** Re-evaluated after the plan is stored (no more false *stale plan* on first open); Home shows the real state.
- **Location.** Android reads `LocationManager` instead of Google Play services: no Google *Location Accuracy* consent dialog.
- **Athan choices.** *Athan for* switches for the five prayers; the test sound is labelled *Test Athan (not for release)*; the inexact-alarm reason says *up to an hour late*.
- **Signing.** `apps/mobile/android/key.properties` (git-ignored: `storeFile`, `storePassword`, `keyAlias`, `keyPassword`) signs release builds; without it they use the debug key.

## Evidence
- App tests: 519 passed (6 new); `melos run ci` green.
- athan-core unit tests, ktlint 1.8.0, detekt 1.23.8: green.
- Android 16 emulator (Pixel 7, x86_64), release and debug: onboarding → Cairo → Home, Qibla, Settings; notification prompt; *Allow* → exact alarms (window 1 h → 0); the Athan Test played on the alarm stream from the background; reboot re-armed the plan.

## Build a tester APK
```
cd apps/mobile
flutter build apk --release --dart-define=DM_CHANNEL=lab
```
Output: `apps/mobile/build/app/outputs/flutter-apk/app-release.apk` (debug-key signed, sideload only).

## Known before testing
- Until 2026-11-01 the seed profiles are not in effect (D77): Home shows the engine default with a notice.
- Place search runs on *Enter*; hits show the admin-1 code (e.g. "11 · EG").
- Approximate location needs the phone's network location; otherwise choose a place.

## Owed (owner)
- A physical Android phone: hear the Athan, OEM battery policies, the 72 h suite (S21).
- The upload key in `key.properties` for Play internal testing; iOS needs macOS/Xcode.
