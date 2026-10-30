# Release polish and the 0.2.0+2 test build (DESIGN.md §15 D116)

Branch `slice/s41-ux-polish` (equal to `main` at `281640f` when the pass began). No PR (owner rule).

## What changed
- **Font licences**: the four bundled OFL faces' licences ship as `dm_ui` assets and appear on the open-source licences
  page (`FontLicences`).
- **Athan Health**: the phone alarm tone (`device_alarm`) counts as an installed sound on Android, so Home no longer says
  *the Athan will not sound* when the tone will ring. iOS unchanged (owed).
- **Quran reader**: zoom, fit and page buttons stopped working after the bars were hidden and shown (viewport remount
  cleared the controller's handler). Keyed surface + handler released only by its owner; regression test.
- **Arabic counts**: ICU plurals for the countdown and pre-reminders («ساعتين», «٣ ساعات», «١٠ دقائق»).
- **Native text language**: Android 13+ per-app locale follows the in-app language (`dm/app_language`), so the Athan
  Test, Stop/Snooze, channels and the widget are Arabic when the app is.
- **Visual**: Health bullets point into their text; arc labels have the hero's shadow; launch-green window behind Flutter.
- **Build**: version `0.2.0+2`; `lab` channel; Dart symbols split out of the APK.

## Evidence
- Gates: `melos run ci` SUCCESS (app 671 passed, 11 package-gated skips; dm_ui 92; engine 337); athan-core 95/95 and
  Android lint; after the language bridge, app shell + settings tests 44 passed and `flutter analyze lib` clean.
- Artifacts (`build/release/0.2.0+2/`, git-ignored; SHA-256 in `SHA256SUMS.txt`): universal APK 79 656 097 bytes
  (baseline 84 022 019), arm64 36 980 925, armv7 34 524 981, AAB 77 982 446; not debuggable; signed **Android Debug**.
  `libapp.so` arm64 9 503 624 → 8 127 368 bytes with `--split-debug-info`.
- Emulator (Android 16, API 36, x86_64 split of the same build, 1080×2400 @420 dpi), upgraded in place over an older
  debuggable build with real data: place, onboarding, language, Quran bookmark/position (page 62), highlight and the
  downloaded package all kept. Offline (airplane mode) after restart: reader, search (pasted verse → 3:96), surah index,
  page strip, RTL page turns, highlight, zoom (also after hiding/showing bars). Arabic and English Home, landscape,
  130 % font. Athan Test rang with the phone alarm tone (foreground service, `USAGE_ALARM`), Stop ended it, notification
  in Arabic. 146 Athan alarms, same set after upgrade and after a phone time-zone change (Dubai place). Licences page
  lists the four fonts. Launcher icon whole in the circle mask.
- Cold start (`am start -W`, after warm-up): baseline 931–1380 ms, final 843–1315 ms — no claim beyond "no regression".
- Not tested here: a physical phone, Android < 13 (no image), the arm64 APK itself (same build, different ABI), date
  rollover on device, fresh install onboarding of this build.

## Owed
- **Owner**: the Play upload key (`android/key.properties`, `docs/release/key-ceremony.md`). Until then every release
  build is signed with the debug key and cannot go to Play.
- **Ops**: `cdn.azenfelnas.app` does not resolve (checked 2026-10-30), so on a new phone the Quran and Athan voice
  downloads fail; the uploads of S42/S43 are still owed.
- **iOS** (macOS): the same `device_alarm` rule in AthanKit's sound probe.
- **Physical phone**: Athan ringing on time from a locked, idle phone; pre-Android-12 launch (no emulator image here).
- **Content / Sharia board**: the Arabic plural wording; the voices' listening review (D111, D112).

## Built-in Quran and Athan voices (D117, after the owner reviewed the screens)
- **Quran** comes with the app: `tool/bundle_quran.py <package dir>` copies the pinned, verified package into
  `assets/quran/` (not in git). At first start it is prepared on the phone with no network through the D107 checks;
  the CDN download is only the fallback. A Quran removed on the storage page stays removed (`quranRemoved`).
- **Athan**: the two D112 voices are bundled sounds; the first is the default Athan and the Test plays it.
  Still `TEST-`/lab-only until the owner's listening review. Fajr follows the Athan voice (D111): **Sharia board** owes
  whether Fajr should default to the phone tone until a Fajr recording is approved.
- To build an APK with the Quran: run the bundle script first (package from `dm-pipelines quran build`).
- Build note: right after `flutter clean`, the first `flutter build apk` here produced APKs with no Flutter assets at
  all (22.6 MB); the next build was correct (158.8 MB arm64). Always check before shipping:
  `unzip -l <apk> | grep -cE "quran/pages/.*webp|athan/.*m4a"` must print 606.
- Evidence (0.2.0+3, emulator Android 16, x86_64 split of the same build): upgrade over +2 kept the installed Quran and
  switched the Athan voice to the bundled default; app data cleared + airplane mode: setup in Arabic, the Quran
  prepared from the app in about 30 s and opened at page 1; the plan's 145 Athan entries use `mirza_isha_2013`; the Test
  played on `USAGE_ALARM` in the foreground service and Stop ended it. Tests: app 679 passed (one 50 ms timing test
  failed under load and passed alone), analyze clean.

## Stopping the Athan and the Qibla vibration (D118, 0.2.0+4)
- The Athan could not be stopped once its notification was swiped away (Android 14+). Now: swipe-away stops it, a gold
  Stop bar shows above the tabs while it plays, and volume, headset and power buttons stop it.
- Qibla: one 1 s vibration when the phone lines up, again only after turning clearly away.
- Emulator evidence: each stop path ended playback (dumpsys audio); Kotlin 96/96, app tests for Athan, shell and Qibla
  191 passed. Owed: physical phones (volume-key routing, screen-on timing), the Qibla vibration on a real compass.
