# S27 hand-over (beta readiness: rollback drill, runbooks, checklist, ceremony, audits) → S28

Branch `slice/s27-beta-readiness`, cut from `slice/s26-control-plane` at `908f199`. No PR (owner rule of 2026-10-22, S17 hand-over). Setup: `docs/handover/cloud-environment.md`; its script worked as written. Mechanics and defaults are in §15 **D87**.

## Built
- **Rollback re-plans, prepare then commit:**
  - `RollBackAndReplan` (`apps/mobile/lib/features/packages/application/roll_back_and_replan.dart`) plans first, then flips the pointer.
  - `PlanSchedule` and `PlanSubject` support it, plus `LoadRuntimeData(candidate:)`.
  - The new port `ApplySchedulePlan` (application layer) has the `PlanStore` contract: whole-document replace, older generation refused.
  - `PlanFailure.writeRefused` maps to `PLAN_WRITE_FAILED`.
- **S27 done-test** `apps/mobile/test/features/packages/rollback_drill_test.dart` covers:
  - the signed CDN rollback: a new version, higher sequence;
  - the on-device rollback;
  - an unloadable previous version, which changes nothing;
  - a refused plan, where the host keeps its plan whole and the next start re-plans.
- **Fake contract:** `FakePlanHost` passes the contract in `plan_host_contract_test.dart`.
- **Accessibility audit (automated):** `test/app/accessibility_audit_test.dart` (32 cases) and the "loaded Home" group in `home_states_test.dart` (40 cases).
  - **Found and fixed:** the Home place bar overflowed by 17 px at 200 % text. It is now a `Wrap`.
- **`release-package.yml`:** new `priority` and `rollback_of` inputs.
- **Docs:**
  - `docs/runbooks/` (README with the alert-catalogue map and the six §19.4 runbooks: tzdb, rollback, key rotation and compromise, Hijri, wrong time, control-plane restore).
  - `docs/release/{checklist,key-ceremony,beta-internal-tracks,accessibility-audit}.md`.
  - `docs/security/threat-model-review-s27.md`.
  - ADR-002 and ADR-009 S27 notes.

## Evidence (this session, Linux)
- `dart run melos run ci`: **SUCCESS**. App: **470 passed + 1 skipped** (was 391 + 1; +79 new). arch_lint and req_index are green.
- `schemas/tools/validate_fixtures.sh`: exit 0 (167 ok); no schema changed.
- Go, the engine and the lab are untouched, so they were not re-run. The workflow YAML parses.

## REQ IDs proved
- REQ-DIST-002: the CDN rollback restores the prior plan entry for entry.
- REQ-PKG-001: on-device rollback; an unloadable previous version leaves the pointer and plan unchanged.
- REQ-ALM-035: plan-host contract; a refused plan keeps the host plan whole.
- REQ-UX-020: the guideline sweep.

## Done-test status
- "Rollback drill restores prior schedule atomically": **automated half passes**. The manual drill on a canary device is OWED.
- "§18.6 beta exit criteria": written as `docs/release/checklist.md` §A with status. The 72 h device suite, screen-reader sessions, declarations, keys and sign-offs are **OWED**.

## OWED (owner)
- **Key ceremony** (`docs/release/key-ceremony.md`), then `production_root_keys.dart` and `promote-package` beta/production options.
- **Store tracks:** Play internal and TestFlight internal (`beta-internal-tracks.md`), the upload key, and the declarations.
- **Accessibility:** screen-reader sessions (ar/en, TalkBack/VoiceOver).
- **Manual rollback drill** on a canary device.
- **Named runbook owners** and the sign-off table.
- **Security decisions** in the threat-model review: the telemetry throttle, the SBOM, and the `note` field.
- **Carried:** every S26/S25 owed item (`terraform apply`, secrets, App Attest root CA, devices).

## Open (engineering)
- `ApplySchedulePlan` pigeon adapter: the native `applyPlan` host wiring and replanning on package activation in `AppBindings`. No caller in `di.dart` yet.
- Alerts: Postgres disk, attestation-failure rate, IANA tag watch, scheduled verification canary (D87).
- SBOM per release (REQ-SEC-040).
- The `hijri` package type (the Hijri runbook stops at capturing the source).

## §17.8 self-review
1. **One reason to change per type:** yes. Plan, roll back and apply are separate use cases and ports.
2. **Layer boundaries:** the arch lint caught a domain → contracts import, and the port moved to application. There is no new wiring outside tests.
3. **Typing:** no `dynamic`, `!` or casts. The test JSON is pattern-checked.
4. **Failures:** typed; `PLAN_WRITE_FAILED` is already mapped by `DescribeFailure`.
5. **Contracts:** the new port is documented and contract-tested.
6. **Hard-coded values:** nothing religious. The drill removes a seed profile and invents none.
7. **Test names:** named by REQ, with fakes only at ports.
8. **Contract changes:** no schema changed; ADRs and D87 are updated.

## Inputs for S28 (widgets, Travel Mode, Ramadan UX, ops dashboard)
- `PlanSchedule` gives one entry point for plan days. Widgets read `Snapshot` (`build_snapshot.dart`).
- Ramadan UX depends on the profile `ramadan` adjustments and the missing `hijri` package (D87).
- The ops dashboard can start from the S26 OTel/SLO resources and the open alerts list in `docs/runbooks/README.md`.
