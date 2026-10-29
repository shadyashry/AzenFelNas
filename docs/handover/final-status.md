# Final status: S01–S28 (DESIGN.md §13) and S29–S35

Every slice is on its own branch, `origin/slice/sNN-*`, and since 2026-10-29 **every slice is merged into `main`** (`0a7a496`); the owner approved each merge in the session. From S18 on there are no PRs, per the owner rule of 2026-10-22 recorded in the S17 hand-over. "Automated" means the part of the done-test that Linux can run passed in that slice's session, as recorded in its hand-over. Nothing device-, store- or cloud-side was simulated or claimed.

| Slice | Branch | PR | Done-test |
|---|---|---|---|
| S01–S08 | `slice/s01-monorepo-runway` … `slice/s08-highlat-hijri` | — | passed |
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
| S29 | `slice/s29-screen-design` | — | Rawdah Garden screens, brand mark, Nabawi Night dark mode (D89); `melos run ci` green, contrast suite in both schemes; device look OWED |
| S30 | `slice/s30-brand-rename` | — | Azen Fel Nas ids, hosts, scheme and copy (D90); `melos run ci`, Go tests and 168 schema fixtures green; native builds OWED |
| S31 | `feat/qibla-sun-alignment`, `slice/s31-qibla-shadow-times` | — | sensor-free Qibla: engine `FindQiblaSunAlignments` (REQ-DOM-031) and the shadow times on the Qibla screen (D91); `melos run ci` green; on-device check OWED |
| S32 | `slice/s32-android-build` | — | first Android compile (D92): compileSdk 37, debug-manifest fix; all Android CI steps green on Windows |
| S33 | `slice/s33-athan-audio-licensing` | — | licensing plan for the classic Egyptian sheikhs (D93) |
| S34 | `slice/s34-athan-plan-wiring` | — | daily Athan armed end to end: plan wiring, bundled audio install, defaults, CC0 test sound (D94); on-device ringing OWED |
| S35 | `slice/s35-test-readiness` | — | test readiness (D95): release-start crash fixed, notification and exact-alarm prompts, Athan switches, LocationManager; verified on an Android 16 emulator (release build, Athan Test, reboot); physical phone OWED |

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
  - The S29 screens, dark mode, launcher icon and splash, and the S31 compass and shadow times, on a real phone.
- **Android build:** done in S32 on Windows (D92): athan-core 84 unit tests, `flutter build apk --debug`, the merged-manifest `AD_ID` check, ktlint, detekt and lint all pass. S35 (D95) fixed the release-start crash and added a release-build CI check; `android/key.properties` now supplies the upload key, which the owner still has to create.
- **macOS / Xcode:**
  - Link AthanKit into Runner and wire `AppDelegate` (S22/S23).
  - Add the `PrayerTimesWidget` extension target (S28).
  - Run `ci-ios`.
- **Domain (S30, D90):** register `azenfelnas.app`; DNS and TLS for `cdn.azenfelnas.app` and `api.azenfelnas.app`.
- **Cloud accounts:**
  - `terraform apply` for distribution (S25) and the control plane, dashboard and alerts (S26/S28).
  - GitHub secrets.
  - The App Attest root CA.
  - Allow `ssd.jpl.nasa.gov` so the lab ephemeris tests run in the cloud environment.
- **Keys and stores:**
  - The S27 key ceremony, then `production_root_keys.dart` and the beta/production promotion options.
  - The Play internal track and TestFlight internal.
  - The upload key and store declarations.
  - Register the new ids (D90): Play `app.azenfelnas`, App Store `app.azenfelnas` with App Group `group.app.azenfelnas.shared`; new provisioning profiles.
- **Sharia and legal:**
  - Approval of every profile; the seeds stay `DRAFT_UNVERIFIED`.
  - Sign-off on the status copy.
  - The Ramadan window presentation (D88).
  - The ODbL publication of `tz_polygons` and the attribution review.
- **Product, Content and Security:**
  - Athan audio (D93): license the classic Egyptian sheikhs' recordings per `docs/release/athan-audio-licensing.md` (lawyer, National Media Authority, heirs, Sharia board); until then dev and lab builds play the CC0 test Athan (D94), and the test sound must leave before 1.0.0 (a test enforces it).
  - Review of the Arabic copy, including the S29 strings and the S31 shadow-time strings (Egyptian colloquial).
  - The travel prompt policy (D88).
  - The threat-model decisions: telemetry throttle, SBOM and the `note` field (S27).
  - Named runbook owners and the sign-off table.
- **Data:** seed `minAppVersion "1.0.0"` against app 0.1.0, which blocks testers on `lab` (S25).

## Open engineering items
- From D87/D88: the IANA tag watch, the scheduled verification canary, the Hijri-boundary alert and the `hijri` package type, the SBOM per release, and a native tz-change trigger for Travel Mode.
