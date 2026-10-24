# ADR-011 · Flutter architecture: feature-first Clean Architecture, Riverpod 3, drift, pigeon, go_router

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-011 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

See §7 and §5.4.

## Trade-offs

- **Win:** typed platform contracts, reactive SQLite, testable use cases.
- **Lose:** code-gen steps (accepted).

## Pinned versions (slice S01, 2026-10-21)

Exact versions pinned in S01 under the §5.4 rule: latest stable ≥ floor, never floated; upgrades are their own PR. Where a toolchain constraint forced a lower version, the reason is given and recorded in `DESIGN.md` §15.

| Area | Tool / library | Floor (§5.4) | Pinned | Pinned in |
|---|---|---|---|---|
| Mobile | Flutter / Dart | 3.35 / 3.9 | **3.47.7 / 3.13.5** | `.tool-versions`, `pubspec.yaml` `environment`, CI |
| Dart | melos | 7 | **8.9.0** | root `pubspec.yaml`, `pubspec.lock` |
| Dart | very_good_analysis | 9 | **11.0.0** | `dm_lints`, `pubspec.lock` |
| Dart | analyzer (dm_lints) | — | **13.3.0** (14.6.0 needs test_api ≥ 0.7.13; Flutter 3.47.7 pins 0.7.12 — D18) | `dm_lints`, `pubspec.lock` |
| Dart | test | — | **1.31.1** (same constraint — D18) | package pubspecs, `pubspec.lock` |
| Dart | glados | 1 | **1.1.7** | `dm_core_types`, `pubspec.lock` |
| Dart | crypto | 3 | **3.0.7** (BSD-3-Clause; direct dependency of `geo_salah_core` from S05 for the Calculation ID — §15 D38) | `geo_salah_core`, `pubspec.lock` |
| Dart | meta | — | **1.19.0** | `dm_core_types`, `pubspec.lock` |
| Dart | cryptography | 2.7 | **2.9.0** (Apache-2.0; pure-Dart `DartEd25519` for TUF-lite verification in `dm_packages`, added S09 — §15 D63). `crypto` 3.0.7 also becomes a direct dependency of `dm_packages` there | `dm_packages`, `pubspec.lock` |
| Dart | path · yaml | — | **1.9.1 · 3.1.4** | `dm_lints`, `pubspec.lock` |
| Dart | timezone | 0.10 | **0.11.2** (BSD-2-Clause; **dev dependency** of `dm_civil_time`: the encoder tool and the differential-test oracle. The app reads the `.tzf` payload with `dm_civil_time`'s own reader, so neither `timezone` nor its transitive `http` ships in the pure set — §15 D66, added S10) | `dm_civil_time`, `pubspec.lock` |
| Dart | freezed · freezed_annotation · json_serializable · json_annotation · build_runner | 3 · — · 6.9 · — · — | **4.0.1 · 3.1.0 · 6.15.2 · 4.12.0 · 2.16.1** (freezed 4.0.3 and build_runner 2.17.1 need analyzer ≥ 14, blocked by the Flutter `test_api` pin — D18; added S02) | package pubspecs, `pubspec.lock` |
| Dart | drift · drift_dev · sqlite3 | 2.28 · — · — | **2.35.2 · 2.35.1 · 3.7.1** (MIT; `drift` is a direct dependency of the app from S12 for the gazetteer tables, `drift_dev` a dev dependency run by `melos run gen`, `sqlite3` transitive — its build hook bundles SQLite (public domain) for host tests and devices; `drift_flutter` waits for S16 — §15 D72) | `apps/mobile/pubspec.yaml`, `pubspec.lock` |
| Dart | geolocator · permission_handler · permission_handler_platform_interface | 14 · 12 · — | **14.1.1 · 13.0.2 · 4.4.1** (MIT; app dependencies from S13 for the `contexts` adapters. 14.1.2 was published 3 days before adoption, so the previous patch is pinned. Transitive: federated `geolocator_*` / `permission_handler_*` (MIT), `plugin_platform_interface`, `package_info_plus`, `win32`, `xdg_directories` (BSD-3-Clause), `uuid` (MIT); `dbus`, `gsettings`, `geoclue` (MPL-2.0, Linux desktop only, never in mobile builds) — §15 D73) | `apps/mobile/pubspec.yaml`, `pubspec.lock` |
| Dart | riverpod · flutter_riverpod | 3.0 | **3.4.3** (MIT; app dependency from S16, plain providers without `riverpod_generator` — §15 D76) | `apps/mobile`, `pubspec.lock` |
| Dart | go_router | 16 | **18.1.1** (BSD-3-Clause; app dependency from S16; routes validated by `RoutePolicy` — §15 D76) | `apps/mobile`, `pubspec.lock` |
| Dart | drift_flutter · path_provider | — | **0.3.1 · 2.1.6** (MIT · BSD-3-Clause; app dependencies from S16 to open `dm.sqlite` / `places.sqlite` under the app support directory; they pull `sqlite3_flutter_libs` 0.6.0+eol and `sqlcipher_flutter_libs` 0.7.0+eol, empty stubs, and `jni`/`objective_c` (BSD-3-Clause) for `path_provider` — §15 D76) | `apps/mobile`, `pubspec.lock` |
| Dart | intl · flutter_localizations | 0.20 | **0.20.3** (BSD-3-Clause; the version `flutter_localizations` of Flutter 3.47.7 requires; ARB codegen with `flutter gen-l10n` from S16 — §15 D76) | `apps/mobile/l10n.yaml`, `pubspec.lock` |
| Dart | geo_salah_profiles · dm_hijri (workspace) | — | **0.2.0 · 0.1.0** (this repository's licence; pure-Dart app dependencies from S17 for `ParseProfileSetPayload`/`ResolveProfile`/`CheckProfileChannel` and `BuildHijriState` — §15 D77) | `apps/mobile/pubspec.yaml` |
| Android | Gradle | 8.14 | **9.8.2** (sha256-pinned wrapper) | `gradle-wrapper.properties`, `.tool-versions` |
| Android | AGP | 8.11 | **9.4.1** | `settings.gradle.kts`, `libs.versions.toml` |
| Android | Kotlin | 2.2 | **2.4.21** | `settings.gradle.kts`, `libs.versions.toml` |
| Android | compileSdk / targetSdk / minSdk | 36 / 36 / 26 | **36 / 36 / 26** | `libs.versions.toml` |
| Android | kotlinx.serialization · coroutines | 1.9 · 1.10 | **1.12.0 · 1.11.0** | `libs.versions.toml` |
| Android | WorkManager · Glance | 2.10 · 1.1 | **2.12.0 · 1.2.0** | `libs.versions.toml` |
| Android | detekt · ktlint | 1.23 · 1.5 | **1.23.8 · 1.8.0** (CLI jars, sha256-pinned in `ci-android`; wired S02) | `ci-android.yml`, `config/detekt.yml`, `.editorconfig` |
| Android | JUnit · Robolectric | 5.13 · 4.15 | **JUnit Jupiter 6.1.3 · 4.17** | `libs.versions.toml` |
| Android | kotlinx.serialization Gradle plugin · JUnit platform launcher | — | **2.4.21 · 6.1.3** (added S02) | `settings.gradle.kts`, `libs.versions.toml` |
| Android | JDK | — | **Temurin 21.0.11** (no floor; current LTS on the dev machine — D18) | `.tool-versions`, CI |
| iOS | Xcode / Swift | 26 / 6.2 | **26.3 / tools 6.2** (newest Xcode on `macos-15` — D18) | `ci-ios.yml`, `Package.swift` |
| iOS | deployment target | 18.0 | **18.0** | `Package.swift` |
| iOS | SwiftLint · SwiftFormat | 0.59 · 0.56 | **0.65.1 · 0.64.0** | `ci-ios.yml` |
| Go | Go | 1.25 | **1.27.3** | `go.mod`, `go.work`, `.tool-versions`, CI |
| Go | golangci-lint | 2.4 | **2.15.0** | `ci-go.yml` |
| Go (first use) | sqlc · goose · zerolog · otel-go | 1.29 · 3.24 · 1.34 · 1.37 | **1.31.1 · 3.29.0 · 1.35.1 · 1.47.0** | `go.sum` with their first user |
| Go | go.yaml.in/yaml/v3 | — | **3.0.5** (MIT + Apache-2.0; maintained successor of `gopkg.in/yaml.v3`, no transitive modules; `gsctl` reads `profiles/*.yaml`, added S09 — §15 D60) | `tools/gsctl/go.mod`, `go.sum` |
| Go | github.com/minio/minio-go/v7 | — | **7.3.0** (Apache-2.0; transitive: klauspost/compress BSD-3 + MIT, klauspost/cpuid MIT, klauspost/crc32 BSD-3, minio/crc64nvme Apache-2.0, minio/md5-simd Apache-2.0, google/uuid BSD-3, rs/xid MIT, dustin/go-humanize MIT, cespare/xxhash MIT, zeebo/xxh3 BSD-2, tinylib/msgp MIT, philhofer/fwd MIT, gopkg.in/ini.v1 Apache-2.0, golang.org/x/{crypto,net,sys,text} BSD-3; the S3 client of `gsctl`'s R2 adapter, maintained, works against R2; 7.4.x was < 2 weeks old; added S25 — §15 D85) | `tools/gsctl/go.mod`, `go.sum` |
| Infra | Terraform · cloudflare · google providers | — | **1.16.5 · 5.27.0 · 8.6.0** (BUSL-1.1 CLI used as a tool only, MPL-2.0 providers; exact pins + lock file; added S25 — §15 D85) | `infra/terraform/*/versions.tf`, `.terraform.lock.hcl`, `ci-infra.yml` |
| Go | go-jsonschema | 0.20 | not adopted — evaluated at 0.24.1 in S02, see ADR-023 amendment / §15 D24 | — |
| Python | Python · uv | 3.13 · 0.8 | **3.15.0 · 0.13.4** | `.python-version`, `.tool-versions`, `[tool.uv] required-version`, CI |
| Python | ruff · mypy · pytest · hypothesis | 0.13 · 1.17 · — · 6 | **0.17.1 · 2.4.0 · 9.1.1 · 6.170.5** | `pyproject.toml`, `uv.lock` |
| Python (lab) | pydantic · skyfield · jplephem | 2.11 · 1.53 · 2.22 | **2.14.1 · 1.55 · 2.24** (added S03) | `lab/pyproject.toml`, `lab/uv.lock` |
| Python (lab) | numpy · tzdata | — | **2.5.4 · 2026.5** (IANA 2026e) (no floor; pinned because they affect reference output, added S03) | `lab/pyproject.toml`, `lab/uv.lock` |
| Python (data-pipelines) | pydantic | 2.11 | **2.14.1** (MIT; wire models generated from `schemas/` like the lab's, added S10 — §15 D66) | `data-pipelines/pyproject.toml`, `data-pipelines/uv.lock` |
| Data (data-pipelines) | IANA tz release (data + `zic` source) | — | **2026e**, 53 files sha256-pinned, git commit `039ef27c…` (public domain; §15 D66, added S10) | `data-pipelines/config/tzdata.v1.toml` |
| Python (data-pipelines) | shapely · numpy | — | **2.2.0 · 2.5.4** (BSD-3-Clause; numpy also 0BSD/MIT/Zlib/CC0 parts; shapely 2.2.0 is the first release with CPython 3.15 wheels; polygon simplification, grid index and the lookup oracle — §15 D70, added S11) | `data-pipelines/pyproject.toml`, `data-pipelines/uv.lock` |
| Python (data-pipelines, dev) | types-shapely | — | **2.1.0.20260728** (Apache-2.0; typeshed stubs for `mypy --strict`, added S11) | `data-pipelines/pyproject.toml` |
| Data (data-pipelines) | timezone-boundary-builder `timezones.geojson.zip` | — | **2026e** (matches the IANA pin), sha256-pinned (ODbL-1.0: attribution, produced database under ODbL — §10; §15 D70, added S11) | `data-pipelines/config/polygons.v1.toml` |
| Data (data-pipelines) | Natural Earth `ne_10m_admin_0_map_units.geojson` | — | **5.1.2**, sha256-pinned (public domain; §15 D70, added S11) | `data-pipelines/config/polygons.v1.toml` |
| Data (data-pipelines) | GeoNames `cities15000` via the `geonamescache` wheel | — | **3.0.2** (uploaded 2026-07-28), sha256-pinned (data CC BY 4.0, attribution; package code MIT and not shipped; download.geonames.org is denied here — §15 D72, added S12) | `data-pipelines/config/gazetteer.v1.toml` |
| Python (lab tool) | datamodel-code-generator | — | **0.86.0** with its dependencies locked on CPython 3.14.8 (§15 D27, added S03) | `lab/tools/codegen/uv.lock` |
| Data (lab) | JPL `de440s.bsp` | 1849–2150 | sha256 `c1c7feea…49f2`, fetched by URL (§15 D28) | `lab/config/harness.v1.toml` |
| Python (first use) | shapely | 2.1 | pinned at latest stable in its first slice (S11) | `uv.lock` |
| Schemas | ajv-cli · ajv-formats · check-jsonschema | 5 · — · 0.33 | **5.0.0 · 3.0.1 · 0.38.2** | `ci-schemas.yml`, `schemas/tools/validate_fixtures.sh` |
| Schemas | kaitai-struct-compiler · js-yaml | — | **0.11.0 · 5.5.0** (CI only, added S02) | `ci-schemas.yml` |
| CI | Node.js (ajv-cli only) | — | **22.22.0** (no floor — D18) | `ci-schemas.yml`, `.tool-versions` |
| CI | gitleaks | — | **8.30.1** (sha256-verified binary) | `ci-dart.yml` |
| CI | GitHub Actions | — | pinned by commit SHA with the release tag as a comment | `.github/workflows/*` |

"First use" rows are the versions to add when the dependency is first needed; nothing pins them before then because no lockfile entry can exist without a user.

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

—

## Tests

- `packages/dm_lints/test/arch_checker_test.dart` — feature-layer direction rules (§7.1).
- `melos run ci` — strict analysis of every package.

## Supersedes

—
