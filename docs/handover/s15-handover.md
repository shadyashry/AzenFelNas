# S15 hand-over (`dm_ui`: tokens, SkyTheme, components, RTL/a11y goldens) → S16

Branch `slice/s15-dm-ui`, cut from `slice/s14-packages-client` at `cbdfc58`. Draft PR base `slice/s14-packages-client`. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built
- **Engine (`geo_salah_core`, pure)**: `ComputeSolarState` (§6.3 `solarState`: exact SPA topocentric altitude/azimuth, direction from the hour angle), `SkyPhase` with the Appendix G bands (`classify`, `progressAt`) and the freezed `SolarState`. Display only; no prayer time reads it, golden corpus untouched.
- **`packages/dm_ui`** (Flutter, depends on `geo_salah_core` + `meta`, both already in the workspace; no new third-party dependency):
  - `tokens/sky.v1.json` — Appendix G as data; `SkyTokens`, `StaticPalette`, `DmScales` mirror it.
  - `WcagContrast` (WCAG 2.2 luminance, ratio, compositing).
  - `SkyTheme.forPhase` / `fromSolarState` — tokens unchanged plus a computed text scrim (D75).
  - `DmTheme.of(brightness, locale)` — static content theme, Arabic +2 line height.
  - `StatusCopy` (§18.5; `chip`, `line`, `expectedHijri`), `StatusDetails`, `StatusLocale`, `DigitStyle`.
  - `ConfidenceChip` (sealed label in, per-variant icon), `TimeRow` (one semantics node "event, time, confidence", ≥ 44 pt, wraps at 200 %), `SkyHeader` (gradient + scrim, 200 ms / 0 ms reduced motion).

## Evidence (this session, Linux)
- **Done-test** `packages/dm_ui/test/sky_contrast_done_test.dart`: 10 phases × light/dark × LTR/RTL = 40 rendered cases; sky text equals `onSurface` with ≥ 4.5:1 over top/mid/bottom through the scrim, content text ≥ 4.5:1 on the static surface, direction checked, 40 goldens in `test/goldens/`. **Green.**
- `dm_ui`: 63 tests (0 before). `geo_salah_core`: +6 (`test/api/compute_solar_state_test.dart`).
- Gates: see `GATES` below.
- Go, lab, schemas not touched → not run. No Android/iOS build possible here.

## REQ IDs proved by named tests
- **REQ-UX-010**: done-test, `sky_theme_test.dart`, token sync, band/solar-state tests.
- **REQ-UX-020**: `components_a11y_test.dart` (semantics, tap-target guidelines, 200 % text, reduced motion, header).
- **REQ-UX-030**: done-test RTL goldens, start/end placement test.
- **REQ-UX-040**: `status_copy_test.dart` prohibited words, Unknown never a number, chip copy.
- **REQ-UX-001**: Estimated range / Observed count in copy.
- **REQ-DOM-020**: `ComputeSolarState` determinism.

## §15 rows and ADRs
- **D75**: Sky theme mechanics — civil dawn/dusk tokens fail 4.5:1 as specified, so a computed scrim; brightness-independent sky; band edges; draft copy; fonts not bundled.
- **ADR-018**: pointer to D75 and the tests.

## Owed / open
- **Design**: review the civilDawn/civilDusk scrim or retune those gradients (D75); the Appendix G civilDawn on-surface pick contradicts its own rule.
- **Content**: review the Arabic chip/detail copy beyond §18.5 (D75).
- **S16/S17**: bundle `Inter` and `IBM Plex Sans Arabic` (OFL licence line, §10.4); wire `DmTheme`, `ComputeSolarState` → `SkyTheme` (repaint ≤ 1/min, `DmScales.skyMinRepaint`), Appendix K `themeMode`/`digits`/`reducedMotionOverride`; map `HijriConfidence.expected` to `StatusCopy.expectedHijri`; reason-code → reason text for `Unknown`.
- Commit `feat(engine)` carries the session's default attribution lines instead of the CLAUDE.md ones (pushed before noticing; slice branches are never force-pushed).
- **Device (owner)**: TalkBack/VoiceOver pass and 200 % system text on hardware (§18.10).

## Inputs for S16 (app shell: DI, router, failure model, drift two DBs, settings, l10n ARB, attributions)
- S13–S15 done. `dm_ui` exports `DmTheme`, `SkyTheme`, `StatusCopy` and the components; S14 owed wiring list is in `s14-handover.md`.
