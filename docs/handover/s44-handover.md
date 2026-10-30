# S44 hand-over: verse features from the downloaded Quran data (DESIGN.md §15 D114)

Branch `slice/s44-quran-ayah`, cut from `slice/s41-ux-polish` at `50637e5` (S42's reader is merged there).

## What changed
- **Line geometry** `MushafLines` for layout `kfgqpc-hafs-1441-604`, measured from the package's own page images
  (never changed): 15 evenly spaced lines on pages 3–604 inside a frame that alternates with page parity; 8 lines in a
  circle on pages 1–2.
- **Verse places** `ReadVersePlaces` over the package's `verse` table (`SqliteMushafIndex`): verses on a page, a verse
  by reference.
- **Verse highlights** `AyahHighlight`, stored per verse and layout in `quran_notes.sqlite` table
  `quran_ayah_highlights` (schema v2, forward-only migration; `quran_notes` now registered in `build.yaml` with schema
  dumps and generated migration tests). Drawn as whole-line bands, hidden with the other highlights.
- **Ayahs sheet**: press and hold a line, or reader menu *Ayahs on this page*: reference, start of the text in the
  KFGQPC font, highlight / recolour / remove, copy (`﴿text﴾` + reference), *Show on the page* (gold outline, 4 s).
  Tapping a highlighted verse opens it. Search, surah index and juz index open their verse with the outline.
  *My highlights* lists highlighted ayahs.

## Evidence
- `flutter analyze lib test`: no issues. `flutter test test/features/quran test/drift/quran_notes`: 60 passed (+8
  package-gated, all passing with `DM_QURAN_PACKAGE` pointing at the built package).
- Geometry: fit over 20 sampled pages (worst line-centre deviation 0.008 of the page height); bands drawn over pages 1,
  2, 62, 293, 604 and inspected. Package-wide: every verse's lines have a band; uncovered lines are titles/basmalahs.

- On-device pass (Android 16 emulator, debug build of `ac77859`, 2026-10-30), English and Arabic:
  - Opening the reader migrated the existing v1 `quran_notes.sqlite` to v2; its bookmark and reading position were
    kept.
  - Long press on page 62 line 7 listed 3:95 and 3:96, and line 8 listed 3:96 and 3:97. On page 1 line 5 it listed
    1:5 and 1:6. All match the package.
  - Highlighting 3:96 green drew one band over lines 7–8 and stored one `quran_ayah_highlights` row. It showed under
    *My highlights*, which opens the page with the outline. Tapping the band opened its sheet, and removing the
    highlight cleared the band and the row.
  - Copy put `﴿text﴾` plus the reference on the clipboard.
  - The surah index opened 18:1 with the gold outline on page 293 line 12 and on page 1 line 2; the outline faded
    after 4 s.
  - In Arabic the sheets are right to left, the references use the Arabic form and digits, and the page images are
    unchanged.
- Found on device and fixed: pasting a copied ayah into Quran search found nothing, because the search fold kept
  `﴿ ﴾` and the reference. `ArabicSearchText.query` now searches the text inside `﴿…﴾`; checked on the emulator (the
  paste finds 3:96 on page 62) and against the real package with the English and the Arabic reference.
- Owner requests on the reader's title: the surah name opens the surah index at the current surah, marked; the juz
  opens the juz index at the current juz, every juz listing the surahs inside it; the page number opens a strip of the
  surah's pages (official page images, small, right to left) with a slider, and *Go to page* one tap away. Widget tests
  in English and Arabic, a package test (every surah sits under a juz; juz 4 opens at 3:93 on page 62). Checked on the
  emulator in both languages: Juz 4 lists Ali 'Imran from 93 and An-Nisa' from page 77; the strip shows Ali 'Imran pages
  50–76, the slider moved it to 71 and the button opened page 71.

## Owed
- **On a phone**: haptic feedback on long press (an emulator has none).
- **Sharia board / Content**: the copy format and the Arabic strings; that a verse highlight covers whole lines.
- Verse-precise (within-line) highlighting needs per-glyph coordinates the package does not have.
