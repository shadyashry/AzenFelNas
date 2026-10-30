# S44 hand-over: verse features from the downloaded Quran data (DESIGN.md §15 D111)

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

## Owed
- **On-device pass** (long press, sheet, highlight, outline, copy) on the emulator or a phone: the shared emulator was
  in use by the S43 adhan session during this slice.
- **Sharia board / Content**: the copy format and the Arabic strings; that a verse highlight covers whole lines.
- Verse-precise (within-line) highlighting needs per-glyph coordinates the package does not have.
