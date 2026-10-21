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
| Dart | meta | — | **1.19.0** | `dm_core_types`, `pubspec.lock` |
| Dart | path · yaml | — | **1.9.1 · 3.1.4** | `dm_lints`, `pubspec.lock` |
| Dart (first use) | freezed · freezed_annotation · json_serializable · json_annotation · build_runner | 3 · — · 6.9 · — · — | **4.0.3 · 3.1.0 · 6.15.2 · 4.12.0 · 2.17.1** | added with their first user |
| Dart (first use) | riverpod · flutter_riverpod | 3.0 | **3.4.3** | added in S16 |
| Android | Gradle | 8.14 | **9.8.2** (sha256-pinned wrapper) | `gradle-wrapper.properties`, `.tool-versions` |
| Android | AGP | 8.11 | **9.4.1** | `settings.gradle.kts`, `libs.versions.toml` |
| Android | Kotlin | 2.2 | **2.4.21** | `settings.gradle.kts`, `libs.versions.toml` |
| Android | compileSdk / targetSdk / minSdk | 36 / 36 / 26 | **36 / 36 / 26** | `libs.versions.toml` |
| Android | kotlinx.serialization · coroutines | 1.9 · 1.10 | **1.12.0 · 1.11.0** | `libs.versions.toml` |
| Android | WorkManager · Glance | 2.10 · 1.1 | **2.12.0 · 1.2.0** | `libs.versions.toml` |
| Android | detekt · ktlint | 1.23 · 1.5 | **1.23.8 · 1.8.0** | `libs.versions.toml` (wired in S21) |
| Android | JUnit · Robolectric | 5.13 · 4.15 | **JUnit Jupiter 6.1.3 · 4.17** | `libs.versions.toml` |
| Android | JDK | — | **Temurin 21.0.11** (no floor; current LTS on the dev machine — D18) | `.tool-versions`, CI |
| iOS | Xcode / Swift | 26 / 6.2 | **26.3 / tools 6.2** (newest Xcode on `macos-15` — D18) | `ci-ios.yml`, `Package.swift` |
| iOS | deployment target | 18.0 | **18.0** | `Package.swift` |
| iOS | SwiftLint · SwiftFormat | 0.59 · 0.56 | **0.65.1 · 0.64.0** | `ci-ios.yml` |
| Go | Go | 1.25 | **1.27.3** | `go.mod`, `go.work`, `.tool-versions`, CI |
| Go | golangci-lint | 2.4 | **2.15.0** | `ci-go.yml` |
| Go (first use) | sqlc · goose · zerolog · otel-go · go-jsonschema | 1.29 · 3.24 · 1.34 · 1.37 · 0.20 | **1.31.1 · 3.29.0 · 1.35.1 · 1.47.0 · 0.24.1** | `go.sum` with their first user |
| Python | Python · uv | 3.13 · 0.8 | **3.15.0 · 0.13.4** | `.python-version`, `.tool-versions`, `[tool.uv] required-version`, CI |
| Python | ruff · mypy · pytest · hypothesis | 0.13 · 1.17 · — · 6 | **0.17.1 · 2.4.0 · 9.1.1 · 6.170.5** | `pyproject.toml`, `uv.lock` |
| Python (first use) | pydantic · skyfield · jplephem · shapely | 2.11 · 1.53 · 2.22 · 2.1 | pinned at latest stable in their first slice (S02/S03/S11) | `uv.lock` |
| Schemas | ajv-cli · check-jsonschema | 5 · 0.33 | **5.0.0 · 0.38.2** | `ci-schemas.yml` |
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
