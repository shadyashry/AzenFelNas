# S17 hand-over (Onboarding + Home + Day timeline + Manual place, all §18.4 states) → S18

Branch `slice/s17-onboarding-home`, cut from `slice/s16-app-shell` at `3900ae5`. Draft PR base `slice/s16-app-shell`. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built
- **Bundled seeds** (`apps/mobile/assets/packages/`): `prayer_profiles` 2026.10.1 (`profiles.json`, byte-identical to `gsctl build` output), `tzdata` 2026e, `tz_polygons` 2026e, `country_polygons` 5.1.2 (pipeline outputs copied byte for byte). `AppBuild.compat` lists the five types with readers; `AppBuild.channel` from `--dart-define=DM_CHANNEL` (default `dev`, unknown → `production`).
- **`geo_salah_profiles`**: `ParseProfileSetPayload` (JSON array → `ParsePrayerProfile` → `ValidateProfileSet`); `PackagePayloadChecks` uses it.
- **`schedule`**: `LoadRuntimeData` (active packages → `RuntimeData`, channel gate via `CheckProfileChannel`), `CalculateSchedule` (7 days from the zone's local today, `ResolveProfile` by country, `BuildHijriState`), `NextPrayer`, `ObserverOf`; providers `runtimeDataProvider`, `contextUseCasesProvider`, `scheduleProvider`, `nowUtcMsProvider`.
- **`contexts`**: `LocateWithPermission`, `ContextUseCases`; Manual place `ManualPlaceState` (idle/searching/results/empty/coordinateEntry/error), controller, view, page (`/place`).
- **`home`**: `HomeState` (loading/ready/needsLocation/needsAttention/noProfile/error) + `HomeState.ofFailure`, `HomePage` (sky header, countdown, place chip, labelled rows, Athan `unknown`), `TimelineState` + `TimelinePage` (`/timeline`), `BuildDayViews` (pinned-TZDB local time, `+1`), `DisplayStyle` (digits setting → `DigitStyle`).
- **`onboarding`**: `OnboardingState` (step welcome/location/place/done, resolving, failed), controller, page, `CompleteFirstRun`, `HomeGate` on `/`.
- **Composition root**: `AppBindings.of` now takes `locator` and `locationAccess` (bootstrap passes the geolocator / permission_handler adapters); contexts stores bound to `PlacesDatabase`.

## Evidence (this session, Linux)
- **Done-test** `test/features/onboarding/first_run_offline_done_test.dart`: fresh in-memory install, no network adapter, location refused → `LOC_PERMISSION_DENIED` → search "Cairo" → pin → Home shows ≥ 6 labelled rows, the manual-place chip and the engine-default notice; second case: granted fix → Home on the device context. **Green, 3/3 repeated runs.**
- Every `UiState` variant has a widget test: `home_states_test.dart` (6 Home variants + `+1`, digits), `timeline_states_test.dart` (3), `onboarding_states_test.dart` (6), `manual_place_states_test.dart` (6 + 2 pinning).
- `dart run melos run ci` **SUCCESS**: format, analyze (`--fatal-infos`), arch_lint 0 violations (556 files), req_index 0 problems (1348 files); tests: app 237 (188 before), `geo_salah_profiles` 32 (+5), `geo_salah_core` 321, `dm_civil_time` 134, `dm_packages` 78, `dm_ui` 63, others unchanged.
- Go, lab, schemas, engine not touched → not run. No Android SDK / Xcode: no device or build run.

## REQ IDs proved by named tests
REQ-PKG-003 (done-test, load_runtime_data_test, parse_profile_set_payload_test), REQ-PKG-006 (prayer_profiles payload check), REQ-TIME-020 (local time from pinned TZDB), REQ-TIME-002 (next prayer, `+1`), REQ-DOM-050 (profile/engine default), REQ-DOM-040 (digits), REQ-UX-001 (labelled rows), REQ-PRIV-002 (manual pin, permission refusal), REQ-ERR-001/002 (failure mapping, codes shown), REQ-SEC-010 (`/timeline`, `/place` not linkable).

## §15 rows and ADRs
- **D77** Onboarding, Home, timeline and manual place mechanics (seeds, channel, runtime data, next-prayer rule, display, state mapping, onboarding flow).
- **ADR-011**: line for the workspace deps `geo_salah_profiles` 0.2.0 and `dm_hijri` 0.1.0 (no external dependency added).

## Owed / open
- **Device (owner)**: REQ-PERF-002 / US-01 timing — `LoadRuntimeData` parses ~11 MB of polygons on the UI isolate at first Home; measure on Galaxy A50 and move to `Isolate.run` if over budget. Real permission dialogs (Android coarse, iOS reduced accuracy) and denial branch; `flutter build apk` / iOS build.
- **Release manager**: S27 must pass `--dart-define=DM_CHANNEL=production|beta`; APK grows ~12 MB from the bundled binaries.
- **Product / Content**: next-prayer rule (Imsak, sunrise excluded), 24 h format, Arabic copy (Egyptian tone, draft). **Sharia**: seed profiles stay `DRAFT_UNVERIFIED`; `eg.egas.standard` starts 2026-11-01, so Cairo shows `engine.default` before then.
- **Not done, carried**: `SyncPackages` on app open (+ connectivity plugin, `CheckClockIntegrity` from `serverDateUtcMs`), bundled fonts (D75), RTL/phase goldens for the new screens (REQ-UX-030), `hijri` package reader, Passport tap-through from rows (S18).
- **Inherited CI blockers** (seen on GitHub CI for this branch's head `a7b4f1f`; none caused by S17): `dart` gen step refuses the D68 cycle `geo_salah_core -> dm_civil_time` (`orderDependents: true`); `secrets` gitleaks false positive at `ci-lab.yml:47` (`bb0082b`; this slice's commits scan clean locally); `ios` runner lacks SwiftLint 0.65.1 (`command not found`); `android` `:app:checkDebugAarMetadata` fails because `permission_handler_android` (added S13) requires compileSdk ≥ 37 while `android/app/build.gradle.kts` uses `flutter.compileSdkVersion` (36). Proposed fix: `compileSdk = 37` (needs an Android SDK to verify; owner/Architect).
- **Owner rule (2026-10-22)**: no PRs. Draft PR #6 was opened for this slice before the rule was seen; the owner may close it and review the branch directly.

## Inputs for S18 (Accuracy Passport + Qibla)
`scheduleProvider` (`Schedule.days[*].calculationId`, `DayResult` provenance), `DayView.calculationId`, `CalculationRoute`/`/calc/:id` placeholder, `RuntimeData` (tzdb, profiles), `ObserverOf`, `HomePage` rows (`TimeRow.onTap` unused yet), `/qibla` placeholder.
