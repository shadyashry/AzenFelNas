# S43 hand-over: downloadable Athan voices (DESIGN.md §15 D111)

Branch `slice/s43-adhan-voices`, cut from `slice/s41-ux-polish` at `50637e5`. Not merged, no PR (owner rule).

## What changed
- **Sources checked** on Commons (licence metadata, file histories, uploaders, block log): one recording integrated,
  three excluded. Record and reasons: `docs/release/athan-voices/README.md`; licence text beside it.
  - Integrated: `malmo_fajr_2012`, Fajr Athan by Islamic Center Malmö (YouTube, 2012), CC BY 3.0.
  - Excluded: `Beautiful_adhan.ogg` and `Azan.ogg` (uploaders are blocked sock puppets of a user whose Athan upload
    was deleted as "not own voice"), `…Aaqib_Azeez.mp3` (file overwritten by a different recording, performer and
    recorder unstated). The bundled dev/lab test sound made from `Beautiful_adhan.ogg` (D94) is **removed**.
- **Pipeline** `dm-pipelines athan-voices fetch|build` (pins in `data-pipelines/config/athan_voices.v1.toml`):
  original audio stream copied out, 4.5 s of leading silence trimmed, −2.2 dB to −16 LUFS, AAC-LC 96 kbps `.m4a`;
  checks decode, loudness, peak and the pinned output sha256. 2 975 655 bytes, 243.05 s.
- **App**: catalog `assets/athan/voice_catalog.json` (`athan_voice_catalog.v1`, pinned size + SHA-256); download from
  `cdn.azenfelnas.app/<channel>/athan/voices/` with `.part` + Range resume, free-space check, integrity check, one
  rename into `<app support>/athan_voices/`, then the `dm/athan_audio` channel copies it to device-protected
  `athan/<soundId>.m4a` for the alarm service; re-checked every start (damaged ⇒ deleted, never played).
- **Choice**: Athan page rows "Athan voice" and "Fajr Athan voice" (new Appendix K key `fajrSoundId`; Fajr entries of
  the plan carry it). Voice page: phone alarm tone, "same as the Athan voice" (Fajr), bundled sounds, catalog voices
  with kind, length, size, review state, licence + creator (links to the licences page), Download / progress / stop /
  Try again / Listen–Stop / Remove. A chosen voice that disappears falls back to the alarm tone (Fajr: to the Athan
  voice) and the page names both (REQ-ALM-053). A Fajr voice is never offered or played for other prayers.
- **Preview** (Android): athan-core `PreviewGate` on the alarm stream, one at a time; the Athan service ends it and
  none starts while an Athan plays. **iOS**: no install or preview yet, so the catalog is empty there.
- REQ-ALM-050..054 added to Appendix F; en/ar strings (Egyptian colloquial); credits in `attributions.v1.json`, `LICENSES.md`.

## Evidence
- Pipeline: `uv run pytest` 72 passed (5 skipped need pinned sources); the voice test rebuilt the file byte for byte
  from the Commons original with `DM_ATHAN_VOICE_SOURCES`; ruff and mypy clean.
- Kotlin: `:athan-core:testDebugUnitTest` 94 passed (new `PreviewGateTest` 4, `BundledAudioInstallerTest` +1);
  ktlint 1.8.0 and detekt 1.23.8 clean; `flutter build apk --debug` builds.
- Dart: athan + settings tests 136 passed (new `voices/` tests: download, resume, corrupt, low storage, refused
  install, damaged-file check, catalog licences and credits, schema fixtures, page download/select/preview/stop/
  remove/fallback, Arabic layout); `melos run ci` result in the session report. Schema fixtures validate.
- Emulator (Android 16, debug, local CDN copy): download, hashes of both copies, preview on the alarm stream and
  Stop, plan Fajr entries on the voice, offline restart keeps the choice and preview, deleted file falls back and is
  named, offline failure then Try again (details in D111).
- Listening review: **not done** (no listening possible here); the voice stays `PENDING` (dev/lab only, Fajr only).

## Owed
- **Owner**: listen to the whole Malmö file (completeness, words, noise, the possibly cut last phrase, the 3.5 s
  sound at 4.75 s); then set `review = "passed"` in the pin file and `"PASSED"` in the catalog, or drop it.
- **Ops**: upload `malmo_fajr_2012.m4a` to `cdn.azenfelnas.app/<channel>/athan/voices/malmo_fajr_2012/1/`
  (build: `dm-pipelines athan-voices fetch --voice malmo_fajr_2012 --dest X.webm`, then `build --source X.webm --out DIR`).
- **Content/Legal**: a reviewed **standard** (non-Fajr) voice; until then the Athan voice is the phone alarm tone and
  Health shows `noSoundAsset`, as before D94 on beta/production. Legal check of the CC BY notice wording.
- **Sharia board**: whether a mosque recording with reverberation is acceptable as the alarm.
- **iOS** (macOS build): AthanKit install of a ≤ 29 s `.caf` clip, a preview player, then enable the catalog on iOS.
- **Physical device**: a Fajr alarm actually ringing with the downloaded voice; preview interrupted by a real Athan.
