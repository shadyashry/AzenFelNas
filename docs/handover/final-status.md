# Final status: S01–S28 (DESIGN.md §13)

Every slice is on its own stacked branch, `origin/slice/sNN-*`, each cut from the previous one. S01–S08 are also on `main` (`ceb0a69`). From S18 on there are no PRs, per the owner rule of 2026-10-22 recorded in the S17 hand-over; review the branches directly. "Automated" means the part of the done-test that Linux can run passed in that slice's session, as recorded in its hand-over. Nothing device-, store- or cloud-side was simulated or claimed.

| Slice | Branch | PR | Done-test |
|---|---|---|---|
| S01–S08 | `slice/s01-monorepo-runway` … `slice/s08-highlat-hijri` | merged to `main` | on `main` (S01–S08 history) |
| S09 | `slice/s09-gsctl-tuf` | — | passed (`s09-handover.md`) |
| S10 | `slice/s10-tzdata` | #1 (closed) | passed: DST suite, 41 zones |
| S11 | `slice/s11-polygons` | — | passed: 0 of 4 000 points disagree |
| S12 | `slice/s12-gazetteer` | — | passed |
| S13 | `slice/s13-contexts` | #2 (draft, open) | passed |
| S14 | `slice/s14-packages-client` | #3 (draft, open) | passed |
| S15 | `slice/s15-dm-ui` | #4 (draft, open) | passed: 40 contrast cases |
| S16 | `slice/s16-app-shell` | #5 (draft, open) | passed (device half of REQ-PRIV-003 owed) |
| S17 | `slice/s17-onboarding-home` | #6 (draft, open; may be closed per the rule) | passed |
| S18 | `slice/s18-passport-qibla` | — | passed |
| S19 | `slice/s19-native-spike` | — | **OWED**: the device run is the done-test (ADR-025) |
| S20 | `slice/s20-schedule-plan` | — | passed (iOS budget fitting) |
| S21 | `slice/s21-android-athan` | — | automated passed; **72 h device suite OWED** |
| S22 | `slice/s22-ios-athan` | — | automated passed (`swift test` on Linux); **device suite OWED** |
| S23 | `slice/s23-athan-ui` | — | automated passed (probe sweeps); device suite U0–U8 OWED |
| S24 | `slice/s24-privacy-hardening` | — | automated passed; device egress test OWED (RC) |
| S25 | `slice/s25-distribution-infra` | — | `lab-e2e.sh` passed against SeaweedFS; `terraform apply` OWED |
| S26 | `slice/s26-control-plane` | — | automated passed (Postgres in Docker); deploy OWED |
| S27 | `slice/s27-beta-readiness` | — | automated rollback drill passed; manual canary drill and beta exit OWED |
| S28 | `slice/s28-v1` | — | automated widget correctness passed (Dart, Kotlin, Swift); on-device widgets OWED |

## OWED, grouped by owner action
- **Physical devices:**
  - The S19 ADR-025 spike.
  - The S21 Android 72 h suite and the S22 iOS suite.
  - The S23 UI suite U0–U8.
  - The device half of S16 REQ-PRIV-003.
  - The S24 egress test.
  - The S27 manual rollback drill and screen-reader sessions.
  - The S28 widgets on a launcher and home screen.
  - REQ-PERF-001 on a Galaxy A50.
- **Android build (blocked here by `dl.google.com`):** `./gradlew :athan-core:testDebugUnitTest :app:assembleDebug lint`. This is the first compile of the Glance UI (S28) and the first run of the merged-manifest `AD_ID` CI step (S24).
- **macOS / Xcode:**
  - Link AthanKit into Runner and wire `AppDelegate` (S22/S23).
  - Add the `PrayerTimesWidget` extension target (S28).
  - Run `ci-ios`.
- **Cloud accounts:**
  - `terraform apply` for distribution (S25) and the control plane, dashboard and alerts (S26/S28).
  - GitHub secrets.
  - The App Attest root CA.
  - Allow `ssd.jpl.nasa.gov` so the lab ephemeris tests run in the cloud environment.
- **Keys and stores:**
  - The S27 key ceremony, then `production_root_keys.dart` and the beta/production promotion options.
  - The Play internal track and TestFlight internal.
  - The upload key and store declarations.
- **Sharia and legal:**
  - Approval of every profile; the seeds stay `DRAFT_UNVERIFIED`.
  - Sign-off on the status copy.
  - The Ramadan window presentation (D88).
  - The ODbL publication of `tz_polygons` and the attribution review.
- **Product, Content and Security:**
  - Review of the Arabic copy.
  - The travel prompt policy (D88).
  - The threat-model decisions: telemetry throttle, SBOM and the `note` field (S27).
  - Named runbook owners and the sign-off table.
- **Data:** seed `minAppVersion "1.0.0"` against app 0.1.0, which blocks testers on `lab` (S25).

## Open engineering items
- From D87/D88: the IANA tag watch, the scheduled verification canary, the Hijri-boundary alert and the `hijri` package type, the SBOM per release, and a native tz-change trigger for Travel Mode.
