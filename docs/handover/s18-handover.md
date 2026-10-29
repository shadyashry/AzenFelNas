# S18 hand-over (Accuracy Passport + Qibla) → S19

Branch `slice/s18-passport-qibla`, cut from `slice/s17-onboarding-home` at `b7447c1`. No PR opened: the owner rule of 2026-10-22 (S17 hand-over) says no PRs; review the branch directly. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built
- **Engine (`geo_salah_core`)**: `CalculateQibla` (§6.3 `calculateQibla(Observer) → QiblaResult`), `Geodesic` = Dart port of GeographicLib 2.0's inverse (Karney 2013, MIT, noted in `LICENSES.md`), `Kaaba` (§6.6 point, ref `2026.1`). `EngineVersion` unchanged.
- **Qibla golden vectors** (`golden-update` commit `8b0b536`): `test/qibla/qibla_vectors.json`, 260 cases from GeographicLib 2.0 Python (`tool/qibla_vectors.py`): 49 golden cities, 11 edges (Kaaba, poles, date line, Papeete, 4 near-antipodal), 200 seeded random. +260 / 0 changed / 0 removed.
- **`passport` feature**: `ResolveCalculationId`, `ImportCalculationLink`, `MeasureSensitivity` (±1 km N/S/E/W), `CalculationLink` (strict codec), `PassportState` ready / importMismatch / notFound (+loading), `PassportPage` (inputs, versions, raw vs shown instant, rounding, origin, adjustment trace, plain-language flags, sensitivity line, copy link).
- **Routing**: `CalculationRoute(id, event?, inputs?)`; `RoutePolicy` lets only Calculation routes take `#<event>` (in-app `/calc/<id>/<event>`) and one `?i=`. Home and timeline rows open their Passport entry (US-05).
- **`schedule`**: `Schedule` carries the resolved `profile` and per-day `CalculationInputs` (hash = `Provenance.inputsHash`).
- **`qibla` feature**: `HeadingSource` port, `ChannelHeadingSource` (`dm/heading` event channel, 5 s first-event timeout), `ObserveHeading` (ready needs true north and accuracy ≤ 15°), `QiblaState` noHeading / calibrating / ready / numericOnly, `QiblaPage` (dial + numeric bearing always). Bound in `AppBindings.of(heading:)`.
- **Native (written, not compiled here)**: Android `HeadingStreamHandler.kt` (rotation vector + `GeomagneticField` declination) registered in `MainActivity`; iOS `HeadingStreamHandler` (`CLHeading.trueHeading`) in `AppDelegate.swift`.
- **l10n**: 59 new keys, en + ar (Egyptian tone, draft).

## Evidence (this session, Linux)
- **Done-test** `apps/mobile/test/features/passport/passport_done_test.dart` (4/4): `azenfelnas://app/calc/<id>#asr` resolves to the entry; a shared link recomputes on a device without that schedule and matches; a link this device does not reproduce shows the import-mismatch message; an unknown ID is not found. **Qibla golden vectors**: `packages/geo_salah_core/test/api/calculate_qibla_test.dart` 5/5, every vector within 1e-9° and 1 µm of GeographicLib.
- Every new `UiState` variant has a widget test: `passport_states_test.dart` (loading, ready, ready RTL, 3 × importMismatch, notFound), `qibla_states_test.dart` (4 variants + no place). `HeadingSource` contract suite runs against the fake and the channel adapter (`heading_source_contract_test.dart`).
- `dart run melos run ci` **SUCCESS** (final tree): format, analyze (`--fatal-infos`), arch_lint 0 violations (577 files), req_index 0 problems (1382 files); tests: app 278 (237 before), `geo_salah_core` 326 (321 before), other packages unchanged.
- Go, lab, schemas, data pipelines not touched → not run. No Android SDK / Xcode / Kotlin / Swift toolchain here: the native heading code is unbuilt.

## REQ IDs proved by named tests
REQ-DOM-030 (golden vectors, Cairo/Jakarta, bearing range, every Qibla state carries the bearing), REQ-DOM-004 (done-test, resolve, import match/mismatch, schedule inputs hash), REQ-DOM-020 (Qibla and sensitivity determinism), REQ-SEC-010 (Calculation link extras allowed, all others refused), REQ-UX-001 (Passport confidence chip), REQ-UX-020 (Qibla turn semantics label), REQ-UX-030 (Passport RTL).

## §15 rows and ADRs
- **D78** Accuracy Passport and Qibla mechanics (engine port, golden vectors, heading channel, thresholds, states, link format, D76 routing update, clipboard sharing, privacy note).
- No new dependency (GeographicLib is ported code, recorded in `LICENSES.md`).

## Owed / open
- **Device (owner)**: Qibla on a physical Android and iPhone: heading vs a known landmark bearing, true-north conversion, calibration overlay, accuracy mapping (the 10/20/35° status mapping and the 15° bar are engineering defaults, D78); Android build of `HeadingStreamHandler.kt` (also blocked by the inherited `compileSdk` issue below); iOS build and SwiftLint of `AppDelegate.swift`. Passport deep links from outside the app (`azenfelnas://app/calc/…?i=…#asr`) on both platforms.
- **Privacy**: confirm that a user-copied link with 6-decimal coordinates is acceptable under REQ-PRIV-001 (D78), or choose a notice / manual-only links.
- **Product / Content**: Passport and Qibla copy (en, ar draft), 15° readiness bar, whether to add a share sheet (`share_plus`, needs an ADR-011 line).
- **Sharia board**: none decided here; the Qibla screen shows a geodesic bearing only (no "facing" tolerance beyond whole-degree display rounding).
- **Not done, carried**: `SyncPackages` on app open, bundled fonts (D75), RTL/phase goldens for new screens (REQ-UX-030 golden images), pigeon (S20 replaces `dm/heading`), screen-rotation remapping for the Android heading.
- **Inherited CI blockers** (unchanged from S17): `dart` gen step vs the D68 cycle, gitleaks false positive at `ci-lab.yml:47`, `ios` runner lacks SwiftLint 0.65.1, `android` compileSdk 37 for `permission_handler_android`.

## Inputs for S19 (native spike, physical devices — owner)
S19 needs physical devices and is owner-only (routine rules): write the spike plan and code skeletons for Android exact alarm → FGS audio and iOS AlarmKit, mark results OWED. Inputs: ADR-012/013, §8.1–§8.3, S07 outputs; the `dm/heading` channel pattern here and `BackupExclusionChannel` (S16) show the native registration points.
