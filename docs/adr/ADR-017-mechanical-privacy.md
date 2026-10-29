# ADR-017 · Privacy controls are mechanical

- **Status:** `[DECIDED]`
- **Source:** `DESIGN.md` §4 ADR-017 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Places in a separate `places.sqlite` excluded from backup; country-level packages; CDN logs without IP retention > 24 h; diagnostics round coordinates to 0.01°; CI egress allow-list test (`cdn.azenfelnas.app`, `api.azenfelnas.app` only); no crash SDK by default.

## Trade-offs

- **Win:** —
- **Lose:** —

## Consequences

See the `DESIGN.md` sections referenced above.

## REQ tags

REQ-PRIV-001, REQ-PRIV-003, REQ-PRIV-004, REQ-PRIV-005, REQ-PRIV-006, REQ-ALM-036

## Tests

Mechanics in `DESIGN.md` §15 D76 (backup exclusion) and D84 (S24 gates).

- `apps/mobile/test/privacy/egress_allow_list_test.dart` — REQ-PRIV-006
- `apps/mobile/test/privacy/android_manifest_privacy_test.dart` — `AD_ID` removal, permission allow-list
- `apps/mobile/test/privacy/event_log_schema_scan_test.dart` — REQ-PRIV-001
- `apps/mobile/test/privacy/ios_privacy_manifest_test.dart` — REQ-ALM-036
- `apps/mobile/test/features/settings/diagnostic_bundle_test.dart`, `diagnostics_page_test.dart` — REQ-PRIV-005
- `apps/mobile/test/features/storage/places_backup_exclusion_test.dart` — REQ-PRIV-003
- `ci-android` merged-manifest `AD_ID` step

## Supersedes

—
