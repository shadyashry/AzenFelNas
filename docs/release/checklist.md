# Release go/no-go checklist (DESIGN.md §20; MVP beta exit §18.6)

Copy this file into the release PR and tick each box with a link to its evidence. A box without evidence is a **no-go**. Status as of S27 (2026-10-24) is shown in brackets, with **OWED** for owner actions that cannot be done from the repository.

## A. §18.6 MVP beta exit criteria
- [ ] **§12 gates green** on the release commit: `melos run ci`, the Go modules (vet, `test -race`, golangci-lint), lab, schemas, `ci-android`, `ci-ios`, `ci-infra`. [Linux gates green in S27; `ci-ios`/`ci-android` on GitHub runners: check the run]
- [ ] **72 h device suite on tier-1 devices** using `docs/test-plans/s21-android-athan-device-suite.md`, `s22-ios-athan-device-suite.md` and `s23-athan-ui-device-suite.md`. [**OWED**: physical devices]
- [ ] **0 open P1/P2** issues. [check the tracker]
- [ ] **Accessibility audit passed**: the automated sweep (`docs/release/accessibility-audit.md`) plus the screen-reader sessions. [automated: passed; sessions **OWED**]
- [ ] **Privacy gates green**: egress allow-list, manifest/`PrivacyInfo` tests, no `AD_ID`, coordinate ban (REQ-PRIV-001..007). [green in `melos run ci`]
- [ ] **Must scope**: E1–E7; Android exact Athan; iOS AlarmKit + notification path; seed profiles on `lab`. [built S10–S24; device verification **OWED**]

## B. §20 go/no-go
- [ ] **Rollback drill** on `lab`. Automated: `rollback_drill_test.dart` passes. Manual: package-rollback.md on a canary device, with the time taken recorded. [automated: passed; manual **OWED**]
- [ ] **Declarations filed**: Play Data safety, the exact-alarm note, the Apple nutrition label, `ITSAppUsesNonExemptEncryption = NO`, App Review notes, age rating (`docs/privacy/store-privacy-declarations.md`). [**OWED**]
- [ ] **Sharia approvals present** for every profile on `production` (ADR-008, `docs/governance/signoff.md`). Beta ships seed profiles on `lab` only. [**OWED** for GA]
- [ ] **Production keys exist** (`docs/release/key-ceremony.md`) and the app embeds the production root for `beta`/`production`. [**OWED**]
- [ ] **Runbook owners named** in `docs/runbooks/README.md`. [**OWED**: names]
- [ ] **Support ready**: the support e-mail, 15 FAQ articles (ar/en) and the triage rota (§21). [**OWED**]
- [ ] **Threat-model review signed** by Security (`docs/security/threat-model-review-s27.md`). [**OWED**]
- [ ] **Tracks**: internal → closed beta → open beta (not in Ramadan) → production; phased rollout Android 5/25/100 % over 3 days, iOS 7 days (`docs/release/beta-internal-tracks.md`). [**OWED**]
- [ ] **Version**: `MAJOR.MINOR.PATCH` with a monotonic build number set in `apps/mobile/pubspec.yaml`. [check]

## C. Sign-off
| Role | Name | Date | Go / No-go |
|---|---|---|---|
| Product (R) | | | |
| Business (A) | | | |
| QA | | | |
| Security | | | |
| Accuracy lead | | | |
