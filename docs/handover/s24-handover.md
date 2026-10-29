# S24 hand-over (privacy hardening) → S25

Branch `slice/s24-privacy-hardening`, cut from `slice/s23-athan-ui` at `39fb38a`. No PR, per the owner rule of 2026-10-22 (S17 hand-over): review the branch directly. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built (mechanics in §15 D84)
- **Schema first:** `schemas/diagnostic_bundle.v1.schema.json` + 2 valid / 6 invalid fixtures; `validate_fixtures.sh` resolves sibling `$ref`s. Freezed models in `dm_contracts/lib/src/diagnostics/`.
- **Diagnostics export (REQ-PRIV-005):** `AssembleDiagnosticBundle` (event log, Dart-evaluated Health, packages, device, context at integer 0.01° without label/accuracy) and `ExportDiagnosticBundle` (copies exactly the shown text; `DeliverDiagnosticText` port, clipboard adapter). Page `/settings/diagnostics` (in-app only), row in Settings, en/ar drafts.
- **Gates** in `apps/mobile/test/privacy/` (also a named `ci-dart` step): egress allow-list (URL hosts in shipped Dart/Kotlin/Swift/XML/plist, network APIs only in `HttpCdnChannel`, runtime dependency closure free of analytics/crash/ads/HTTP SDKs, CDN channel connections captured at runtime, no cleartext); `AD_ID` + AdServices permissions removed with `tools:node="remove"`, exact release permission allow-list, `ci-android` merged-manifest grep; event-log schema scan (Appendix J allow-list = schema = Dart = Kotlin = Swift fields, no pattern admits a decimal coordinate, closed coordinate-free event/telemetry/diagnostic schemas); iOS privacy manifest (bundled, no tracking/collection, reasons present, required-reason API use ⇒ declared).
- Release manifest now declares `INTERNET` (Flutter only adds it to debug/profile).
- **Store declarations draft:** `docs/privacy/store-privacy-declarations.md` (Play Data safety, Apple App Privacy, open questions Q1–Q4).

## Evidence (this session, Linux)
- `dart run melos run ci`: **SUCCESS** — app **390** tests (360 before, +30), dm_contracts 27 (+7); analyze clean; arch_lint 0 violations in 630 files; req_index 0 problems in 1613 files.
- `schemas/tools/validate_fixtures.sh`: exit 0, 151 ok, 0 FAIL.
- Not run: Gradle (merged-manifest step is new in `ci-android`, unverified here — dl.google.com blocked), Xcode, devices. Go, the lab and Swift sources were not changed.

## REQ IDs proved by named tests
REQ-PRIV-001, REQ-PRIV-005, REQ-PRIV-006, REQ-ALM-036, REQ-ERR-002 (export failure), REQ-SEC-010 (diagnostics route in-app only), REQ-ALM-003 (health.json carries the derived state).

## §15 rows and ADRs
- **D84** (new): bundle format (one JSON document, not a zip), gates and their exclusions, `INTERNET`, store-draft basis. §7.2 bundle line points to D84. ADR-017 long form lists REQ tags and tests. No new dependency.

## Owed / open
- **Owner, Android:** first `ci-android` run of the merged-manifest `AD_ID` step (the path glob `build/app/intermediates/*merged_manifest*` is AGP-version dependent); inherited compileSdk 37 blocker (S17).
- **Owner, RC:** §12 proxy-based egress test on a device build (the CI test is static + adapter-level).
- **Privacy / Legal:** Data safety and App Privacy answers, Q1 (country-level package download vs "approximate location"), Q2 (Calculation links, D78), privacy-policy text (§24). Nothing filed.
- **Product / Content:** diagnostics copy (en/ar drafts), clipboard rather than share sheet, `device.model` = null.
- Still open from S23: no `ApplyAthanPlan` (Health stays `notReady(stalePlan)`; `plan_redacted.json` = `notApplied`).

## Inputs for S25 (distribution infra)
- Only `cdn.azenfelnas.app` (and `api.azenfelnas.app`) may appear in shipped code; the egress test fails on any other host. Channel paths: `HttpCdnChannel` `/<channel>/metadata/<role>.json`, `/<channel>/packages/<type>/<version>/<sha256>.dmpkg`.
- CDN logs must keep no IP > 24 h (ADR-017); the Data safety draft relies on it.
