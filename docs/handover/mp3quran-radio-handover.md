# Hand-over: Quran radio from MP3Quran (DESIGN.md §15 D122)

Branch `MP3Quran`, cut from `slice/s41-ux-polish` at `07c5b6e`. Not merged, no PR (owner rule). The uncommitted Quran
reader work that was on that branch (reading mode sheet) is left uncommitted in the working tree, as the owner asked;
the radio commits hold only radio changes.

## What changed
- **Radio tab** (`/radio`, sixth destination after Quran): header, player card (true state, MP3Quran source, arch,
  station, checked description, Favorite, Play/Pause, Stop, sleep timer Off/15/30/60), «Your stations» with All /
  Favorites, search (folds case, Arabic marks, tatweel, alef/taa/ya), rows, credit. Owner's light and dark tokens
  (`RadioTokens`), two light values adjusted for WCAG AA (recorded in D122). English and Arabic, LTR/RTL. Side by side in
  wide or landscape windows, compact header and card on short ones.
- **Mini player** above the tabs on every other tab while connecting, playing, paused or reconnecting; title opens Radio,
  Play/Pause and Close separate, Close stops.
- **Catalog**: `www.mp3quran.net/api/v3/radios` (ar + eng), joined by id, kept in app support storage, refreshed in full
  when 24 h old or by hand; featured 108/74/69/32 from `assets/radio/featured_stations.json` (`radio_featured.v1`).
  The radiojar station is left out (another broadcaster).
- **Player**: Android Media3 1.11.1 `RadioService` (media session, notification, focus, noisy, retries, sleep timer);
  iOS `RadioPlayer.swift` (AVPlayer, background audio, Now Playing, remote commands, interruptions). The Athan service
  now takes transient audio focus so the radio pauses for it.
- **Privacy**: REQ-PRIV-006 extended to MP3Quran's catalog host and stream domains; the egress test pins it.
- REQ-RADIO-001…014 (Appendix F), D122 (§15), ADR-027 (§4), Appendix K `radioFavorites`, `radioStationId`; credits in
  `LICENSES.md` and `attributions.v1.json`; source and permission record `docs/release/radio/README.md`.

## Evidence
- Dart: 40 radio tests pass (`test/features/radio`); full app suite 746 passed, 11 skipped, 1 failed — the S12
  gazetteer timing test (< 50 ms), which fails only under parallel load and passes alone; `dm_ui` 95 passed;
  `flutter analyze` clean on the app and `dm_ui`; `radio_featured.v1` schema and fixtures validate with ajv.
- Kotlin: `:athan-core:testDebugUnitTest` 96 passed, `:app:compileDebugKotlin` builds; ktlint 1.8.0 clean on
  athan-core and the radio files; detekt 1.23.8 clean on the radio files (athan-core keeps one finding in the
  untouched `AlertNotifications.kt`).
- Android 16 emulator (own AVD `radio_test`, debug build): live catalog; Play → Live; English/Arabic × light/dark
  screens; theme and language changes during playback kept the stream; mini player on the Quran tab in all four modes;
  landscape side by side in English and Arabic; notification with Play/Pause and Stop and no seek bar; a media-key
  Play resumed in sync with the mini player; Stop from the notification ended the session.

## Owed
- **iOS** (macOS/Xcode): build and run `RadioPlayer.swift` (not compiled here), Background Audio, lock screen and
  Control Center, interruptions, sleep timer while locked.
- **Physical Android**: lock screen, Bluetooth and wired headset buttons, unplugging, a phone call, a real Athan during
  playback (focus pause, no auto-resume), Doze with the sleep timer, swiping the app away while playing.
- **Legal**: confirm the reading of MP3Quran's permission clause (it sits in a privacy policy and names no radio or app).
- **Owner**: visual check against the references; decide whether the tab bar should follow the reference's cream bar with
  «More» (kept as the approved Horizon bar with six destinations, D122).
