# S16 hand-over (app shell: DI, router, failure model, drift two DBs, settings, l10n ARB, attributions) → S17

Branch `slice/s16-app-shell`, cut from `slice/s15-dm-ui` at `687fd4c`. Draft PR base `slice/s15-dm-ui`. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built (`apps/mobile`)
- **Storage** (`features/storage/data`): `DmDatabase` (`dm.sqlite`: package, gazetteer, `settings`, `event_log` tables) and `PlacesDatabase` (`places/places.sqlite`: `location_contexts`, `elevation_samples`). The table files stay in their features; the S12/S14 single-purpose databases are folded in. `ForwardOnlyMigration`, `DatabaseFiles` (eager open, `DB_MIGRATION_FAILED`), `DriftEventLog` (5 000-row ring), schema dumps in `drift_schemas/` (`build.yaml`, `dart run drift_dev make-migrations`).
- **Backup exclusion**: Android `res/xml/backup_rules.xml` and `res/xml/data_extraction_rules.xml` + manifest; iOS `BackupExclusionChannel` in `AppDelegate.swift` behind the `ExcludeFromBackup` port.
- **Settings**: every Appendix K key as a typed `SettingKey<T>`, `DriftSettingsStore` (`ReadSetting`/`WatchSetting`/`WriteSetting`), Settings page (language, digits, appearance, reduce motion), Attributions page (`assets/legal/attributions.v1.json` + `showLicensePage`).
- **Shell**: `AppRoute` + `RoutePolicy` (deep-link allow-list), go_router with validating `redirect`, `DescribeFailure` (27 codes → 11 remediations), `NeedsAttentionCard`, `StartupFailureApp`, `StartApp` (`APP_START`, bundled seeds, package GC), placeholder pages for Home/Health/Qibla/Passport.
- **Composition root**: `app/di.dart` (`AppBindings.of`), `app/bootstrap.dart`, `main.dart`; Riverpod 3 plain providers.
- **l10n**: `l10n.yaml`, `lib/l10n/app_{en,ar}.arb` + generated Dart; Android `dailymuslim` intent filter, iOS `CFBundleURLTypes`.
- New dependencies (licences checked, ADR-011 table): flutter_riverpod 3.4.3, go_router 18.1.1, drift_flutter 0.3.1, path_provider 2.1.6, intl 0.20.3 + flutter_localizations, dm_ui (workspace), sqlite3 3.7.1 (dev, already transitive).

## Evidence (this session, Linux)
- **Done-test**: `test/features/storage/migrations_test.dart` (10: every recorded version of both files migrates to current and matches the dump; downgrade and missing step refused, file untouched) and `test/features/storage/places_backup_exclusion_test.dart` (11: manifest + both rule files exclude `places/`, the file sits in the excluded directory, exclusion runs before the file is created, `ExcludeFromBackup` contract over fake/Android/iOS adapters, Swift names match). **Green.**
- `dart run melos run ci` **SUCCESS**: app 188 tests (135 before), `geo_salah_core` 321, `dm_civil_time` 134, `dm_packages` 78, `dm_ui` 63, others unchanged; format, analyze (`--fatal-infos`), arch_lint 0 violations (524 files), req_index 0 problems.
- Go, lab, schemas not touched → not run. No Android SDK / Xcode here: neither `flutter build apk` nor the Swift code was compiled.

## REQ IDs proved by named tests
- **REQ-PRIV-003**: `places_backup_exclusion_test.dart` (static half; device half owed).
- **REQ-ERR-001**: `migrations_test.dart`, `describe_failure_test.dart`.
- **REQ-ERR-002**: `describe_failure_test.dart` (every code mapped), `app_shell_test.dart` (Needs attention shows the code).
- **REQ-SEC-010**: `route_policy_test.dart`, `app_shell_test.dart` deep-link cases.
- **REQ-DATA-001**: `drift_event_log_test.dart` (ring ≤ 5 000). Other retention rules are not implemented yet.
- **REQ-PRIV-001**: event-log row attrs; **REQ-PKG-003**: `start_app_test.dart` (seed import on first start); **REQ-UX-040**: ARB prohibited words.

## §15 rows and ADRs
- **D76** (App shell mechanics): two files, migrations, backup exclusion, event log, setting defaults, DI, link format and routing, failure mapping, l10n, attributions, start-up, and the deferral of `SyncPackages`.
- **ADR-011** long form: dependency rows for S16.

## Owed / open
- **Device (owner)**: Android `adb shell bmgr backupnow` + `adb restore`/D2D check that `files/places/` is absent; iOS backup listing / `URLResourceValues` read-back on a device; deep links `dailymuslim://app/calc/GS-…`, `/health`, `/qibla` on both platforms (does the platform deliver the host?); `flutter build apk` / iOS build (Android SDK and Xcode are not on Linux).
- **Product**: setting defaults (`themeMode=sky`, digits per language), remediation mapping and copy, the share-link format `dailymuslim://app/…` (S18 Passport). **Content**: Arabic ARB copy (Egyptian tone, draft). **Legal**: attribution notices and where the ODbL-produced database is published.
- **S17**: wire `SyncPackages` on app open (needs `ReadNetworkKind` + a connectivity plugin with licence check, `TrustedRoot.fromRootKeysJson` with dev keys on dev/lab, `HttpCdnChannel`), feed `SyncReport.serverDateUtcMs` to `CheckClockIntegrity`; bind `EventLogContextEvents` and the contexts stores to `PlacesDatabase` in `app/di.dart` (`GeolocatorPlatform.instance`, `PermissionHandlerPlatform.instance`); runtime readers via `LoadPackagePayload`; Home on `appStartProvider`; sky header via `ComputeSolarState` → `SkyTheme`; digits setting → `DigitStyle`; reduced-motion override; bundle the fonts (D75).
- **Retention (REQ-DATA-001)**: the purge job (`lastRetentionRunUtcMs`) belongs with the tables it purges (S18/S20).
- **Inherited CI blockers** from S15 (gen `orderDependents`, gitleaks false positive, `swiftlint` on the macOS runner): unchanged, owner/Architect.

## Inputs for S17 (Onboarding + Home + Day timeline + Manual place, all §18.4 states)
- S16 shell: `AppBindings`, `appStartProvider`, settings providers, `NeedsAttentionCard`/`DescribeFailure`, `RoutePolicy`, ARB files; S13 contexts use cases; S15 `dm_ui` components.
