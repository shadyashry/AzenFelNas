# S14 hand-over (`dm_packages` client: verify/stage/activate/rollback, bundled seed import, sync policy) → S15

Branch `slice/s14-packages-client`, cut from `slice/s13-contexts` at `960f284`. Draft PR base `slice/s13-contexts`. Setup: `docs/handover/cloud-environment.md`; its script worked as written.

## Built
- **`packages/dm_packages/lib/src/client/`** (pure set):
  - Domain: `PackageType` (the 7 MVP types), `PackageSource`, `PackageFileState`, `PackageFile`, `ActivePackage`, `AppCompat`, `ChannelTrust`, `BundledSeed`, `TargetChoice`, `StagedPackage`, the sealed `PackageEvent`, `SyncOutcome` and `SyncReport`.
  - Ports (`client/ports/`): `ReadPackageCatalog`, `WritePackageCatalog`, `StorePackageBlobs`, `PackageTrustStore`, `FetchChannel`, `InflatePayload`, `CheckPayload`, `ApplyPackage`, `RecordPackageEvent`, `ReadNetworkKind`, `ReadBundledSeeds`.
  - Use cases: `SyncPackages`, `SelectTargets`, `CheckCompatibility`, `StageTarget`, `ActivateStaged`, `RollBackPackage`, `ImportBundledSeeds`, `LoadPackagePayload`, `CollectPackageGarbage`, plus `SyncPolicy`.
  - `PackageFailure` gains the `incompatible`, `network` and `storage` variants.
- **Verifier changes (`verify/`)**:
  - Root rotation: the new root must carry the old root's threshold and its own, and a lower root version is refused.
  - `TrustedRoot.ofRoot` and `version`.
  - `TrustedSequences` stores each role's file SHA-256, so a file that is served again unchanged at an equal sequence is not counted as a regression.
- **Fakes**: `package:dm_packages/testing.dart` provides `InMemoryPackageCatalog`, `InMemoryPackageBlobs` and `InMemoryTrustStore`.
- **App (`apps/mobile/lib/features/packages/`)**:
  - `PackagesDatabase`, a drift database with `active_packages`, `package_files` and `package_trust`.
  - `DriftPackageCatalog` and `DriftPackageTrustStore`.
  - `IoPackageBlobStore`, `IoGzipInflate`, and `HttpCdnChannel` (`cdn.dailymuslim.app` only, `dart:io`).
  - `AssetBundledSeeds`, which reads `assets/packages/seeds.json`. The gazetteer 3.0.2 asset is now declared in the pubspec.
  - `PackagePayloadChecks` and `EventLogPackageEvents`.
  - `application/ImportingApplyPackage`, which runs the gazetteer import on activation.
- **Dependencies**: none new. `dm_packages` is now an app dependency (internal).

## Evidence (this session, Linux)
- **Done-test** `packages/dm_packages/test/client/package_client_done_test.dart` runs over a channel signed with ephemeral Ed25519 keys (the dev keys are not used):
  - **Tamper**: a flipped `.dmpkg` byte, a `targets.json` edited after signing, a blob changed on disk, and a payload the schema refuses. Each one is refused and the last-known-good stays active.
  - **Downgrade**: replayed older metadata, a lower pointer sequence, and a bundled seed over a downloaded version are all refused.
  - **Expiry warning**: an expired channel still installs and reports 4 warnings plus `FreshnessUnverified`.
  - **Rollback**: a local rollback restores the previous version and re-applies it, and the rolled-back version is not chosen again. A signed `rollbackOf` supersedes the version it rolls back. A failed apply step leaves the previous version active.
  - **Green.**
- **App done-test** `apps/mobile/test/features/packages/packages_done_test.dart`: the real bundled gazetteer imports once through drift, the payload checks and `ImportGazetteer`, giving 34 006 places. **Green.**
- **Gates**:
  - `dart run melos run ci` reports SUCCESS. `dm_packages` has 78 tests (25 before); the app has 135 (100 before); the other packages are unchanged. arch_lint reports 0 violations and req_index 0 problems.
  - Go, the lab, the schemas and the engine were not touched, so their gates were not run.
  - No Android or iOS build is possible here (no Android SDK, no Xcode).

## REQ IDs proved by named tests
- **REQ-PKG-001**: the done-tests and the catalog contract.
- **REQ-PKG-002**: expiry warning, event and `lastVerifiedUtcMs`.
- **REQ-PKG-003**: seed import, idempotence, a newer binary, hash refusal, and the real gazetteer asset.
- **REQ-PKG-004**: 6 h interval, offline, unchanged channel, > 2 MB metered deferral and the urgent override.
- **REQ-PKG-005**: replay and the trust store.
- **REQ-PKG-006**: compat matrix, never downloaded, and types without a reader.
- **REQ-DIST-001/002/003/004**: rotation, rollback, hashes and signatures.
- **REQ-TIME-010**: the CDN `Date` is reported and never judged.
- **REQ-PRIV-001**: package events.
- **REQ-TEST-004**: catalog, trust store and blob store contracts, each run on the adapter and the fake.

## §15 rows and ADRs
- **D74**: package client mechanics, covering unchanged files, root rotation, target choice, check order, sync policy constants, storage additions (`source` and `updated_utc` on `package_files`, `package_trust`) and readers per type.
- **ADR-009**: pointer to D74 and the tests.

## Owed / open
- **S16 (wiring)**:
  - Open `dm.sqlite` with drift_flutter and fold in `PackagesDatabase`.
  - Choose the blob directory under app support storage.
  - Write `ReadNetworkKind`. It needs a connectivity plugin, which means a new dependency with its licence check.
  - Wire `SyncPackages` on app open (never in the alarm path), and `ImportBundledSeeds` plus `CollectPackageGarbage` on start.
  - Feed `SyncReport.serverDateUtcMs` into `CheckClockIntegrity` as `TimeSource.cdnDate`.
  - Embed the root keys: `TrustedRoot.fromRootKeysJson`, using the dev keys on dev/lab.
  - Bind `EventLogPackageEvents` to the event log.
  - Have the runtime readers (tzdata, polygons) load their active payload through `LoadPackagePayload`.
- **Bundled seeds for the other six types (REQ-PKG-003)** belong to the slices that ship them. Add an entry to `seeds.json` and a reader to `PackagePayloadChecks`. `prayer_profiles` also needs a seed policy, because seed profiles are `DRAFT_UNVERIFIED` and load on dev/lab only (§0.2 rule 1).
- **gsctl**: refuse a target whose `effectiveFrom` precedes the one it supersedes within the same type (D74). This is a Release manager and Architect item.
- **Product**: should `effectiveFrom` follow the user's local date instead of the UTC date (D74)? This needs a Sharia/Product review if religious releases depend on it.
- **Device (owner)**: on a physical device, check a real HTTPS fetch from `cdn.dailymuslim.app` once S25/S26 exist, and the large-payload deferral on cellular. Neither is possible here.

## Inputs for S15 (`dm_ui`: tokens (Appendix G), SkyTheme, components, RTL/a11y goldens)
- Appendix G (`packages/dm_ui/tokens/sky.v1.json`) and the existing `packages/dm_ui` skeleton. S14 adds no UI. The "data last verified N days ago" copy (US-17) can read `ChannelTrust.lastVerifiedUtcMs` once S16 wires it.
