# S42 hand-over: offline Quran reader (DESIGN.md §15 D107)

Branch `slice/s42-quran-reader`, cut from `slice/s41-ux-polish` at `710f66b`, then merged into `slice/s41-ux-polish`
(the decision was renumbered D107 because S41 took D105 and D106).

## What changed
- **Quran tab** (second tab, open-Mushaf glyph): download screen until the package is ready, then the reader.
- **Package** from the official KFGQPC sources only: `dm-pipelines quran fetch|build` (pins in
  `data-pipelines/config/quran.v1.toml`). 604 lossless WebP pages (1400 × 2002, each checked pixel for pixel against
  the PDFium render of the Complex's vector page), `quran.sqlite` (114 surahs, 6 236 verses with page and lines, 30 juz),
  the KFGQPC Hafs font byte for byte, `manifest.json` (`quran_package.v1`). Two builds were byte-identical.
- **Download**: pinned manifest, free-space check, per-file `.part` + HTTP Range resume, size + SHA-256 per file,
  on-device FTS5 search index that must answer, one rename to activate; old package readable until then.
  Storage page: status, edition, measured size, full check, repair, remove (notes kept).
- **Reader**: right-to-left page order in Arabic and English (Next page on the left, swipe right = forward, left
  arrow key = forward), zoom 1–4× (pinch, double tap, buttons, keys), pan, fit page / fit width, facing pages on wide
  landscape windows, go to page (1–604, Western or Arabic-Indic digits), surah/juz index, search, bookmarks, area
  highlights (several boxes, several pages, five colours, recolour, delete, "My highlights"), last page restored.

## Evidence
- Host: `flutter test test/features/quran` 36 passed (+6 package-gated, passing with `DM_QURAN_PACKAGE`), Python
  `tests/test_quran.py` 6 passed (+ rebuild test passing with `DM_QURAN_SOURCES`), dm_contracts round trip 30 passed.
- Emulator (Android 16, 1080×2400 @ 420 dpi, 2.5 GB RAM, profile): download, stop, app killed mid-download and resumed
  (HTTP 206), then airplane mode + restart: unvisited pages 1→2, 3, 42, 82, 440, 586, 587, go to page, invalid page
  refused, index, zoom/pan, bookmark, two-page highlight drawn / recoloured / opened, rotation, Arabic interface,
  restart with state kept. `integration_test/quran_device_test.dart` (flutter drive, profile): passed.
- Also on the emulator: full check of 606 files, a truncated page detected at start and repaired (only that file
  fetched), removal (notes kept) and re-download with the bookmark restored.
- Measured (D107): search 0.6–37 ms; PSS 173 MB on Home, 184–186 MB reading (60 pages, 4× zoom); APK arm64 release
  +656 768 bytes; download 124 946 306 bytes, installed 126.6 MB, free space asked 143.4 MB.
- `melos run ci`: SUCCESS (format, analyze --fatal-infos, arch and REQ lints, all Dart/Flutter tests).

## Owed
- **Legal**: written confirmation from the Complex for redistributing the converted pages from our CDN and for using the
  v3.0 Word text in a search index. **Ops**: upload the package to `cdn.azenfelnas.app/<channel>/quran/hafs-madinah-1441/1441.1/`.
- **Sharia board / Content**: review of the reader, the search folding and the Arabic copy.
- Physical phones (low-end Android, tablet), iOS build (the `dm/storage` channel is written, not built), VoiceOver/TalkBack pass.
- Word- or verse-precise highlighting needs verified per-edition coordinates; none were found, so highlights are areas.
