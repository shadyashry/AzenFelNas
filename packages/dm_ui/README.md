# dm_ui

Design system: tokens, SkyTheme and RTL-aware components (DESIGN.md §7.9, ADR-018).

Flutter package, no business logic. Since S15:

- `tokens/sky.v1.json` — Appendix G as data; `SkyTokens`, `StaticPalette` and `DmScales` mirror it (sync test).
- `WcagContrast` — WCAG 2.2 luminance, ratio, compositing.
- `SkyTheme.fromSolarState` / `forPhase` — Appendix G colours plus the text scrim of §15 D75.
- `DmTheme.of(brightness, locale)` — static content-surface theme.
- `StatusCopy` — the only source of §18.5 status copy (prohibited-word tests).
- `ConfidenceChip`, `TimeRow`, `SkyHeader` — semantics, ≥ 44 pt targets, 200 % text, reduced motion, start/end layout.

Goldens: `flutter test --update-goldens test/sky_contrast_done_test.dart` (10 phases × light/dark × LTR/RTL).
