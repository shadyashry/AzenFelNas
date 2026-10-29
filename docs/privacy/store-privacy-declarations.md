# Store privacy declarations — DRAFT (S24)

Status: **DRAFT for the Privacy and Legal owners**; nothing here has been filed. Basis: `DESIGN.md` §9.6, §20 (declarations), ADR-014, ADR-017, REQ-PRIV-001…007 and the mechanical gates in `apps/mobile/test/privacy/` (§15 D84). Re-check every answer against the build that is submitted (S27).

## What the app does with data (facts the answers rest on)

| Data | Where it lives | Leaves the device? |
|---|---|---|
| Approximate location (coarse fix, ADR-014) or a typed/searched place | `places.sqlite`, excluded from OS backup (REQ-PRIV-003) | No app egress path carries it. Package downloads are country-level or global (REQ-PRIV-004); see open question Q1. |
| Prayer times, Hijri date, Qibla | computed on the device | No |
| Settings, event log (Appendix J, no coordinates by schema) | `dm.sqlite` | No |
| Diagnostic report (redacted, 0.01°, no identifiers; REQ-PRIV-005) | assembled on demand, shown in full | Only if the user copies it and pastes it somewhere themselves; the app sends nothing. |
| Package sync | HTTPS GET to `cdn.azenfelnas.app` only (REQ-PRIV-006), no cookies or identifiers | The request itself (IP address seen by the CDN; CDN logs keep no IP > 24 h, ADR-017). |
| Aggregate telemetry (Appendix L) | off in beta (D11); opt-in only later | When opted in: daily aggregate counts with no identifier (REQ-PRIV-001). |
| Attestation (REQ-PRIV-007, later slices) | — | `sha256(attestationKeyId + dailySalt)`, retained ≤ 24 h. |

No advertising identifier (the manifest removes `AD_ID` and the AdServices permissions), no analytics, crash, ads or attribution SDK (gated by `egress_allow_list_test.dart`), no account, no tracking (`NSPrivacyTracking = false`).

## Google Play — Data safety form (draft answers)

- **Does your app collect or share any of the required user data types?** No (draft). Rationale: location is processed only on the device ("processed ephemerally / on-device" is not collection); the diagnostic report leaves only through a user-initiated paste outside the app.
- **Is all of the user data collected by your app encrypted in transit?** Yes — HTTPS only; cleartext is never enabled (gated).
- **Do you provide a way for users to request that their data is deleted?** Not applicable (no data collected); uninstalling removes all local data.
- Telemetry, when it ships (post-beta, opt-in): re-answer as "App activity → Other actions", not shared, optional, for analytics — **Privacy owner to decide** before the first build that contains it.
- Permissions declared (release): `ACCESS_COARSE_LOCATION`, `INTERNET`, `SCHEDULE_EXACT_ALARM`, `POST_NOTIFICATIONS`, `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `RECEIVE_BOOT_COMPLETED`, `WAKE_LOCK`, `VIBRATE` — exactly the allow-list in `android_manifest_privacy_test.dart`. Exact-alarm policy note: user-scheduled, time-critical prayer alarm (§20).

## Apple — App Privacy ("nutrition label") draft

- **Data Not Collected** (draft). Same rationale as Play; diagnostics are user-initiated and leave via the clipboard only.
- `PrivacyInfo.xcprivacy` (Runner): no tracking, no tracking domains, no collected data types; required-reason APIs `UserDefaults` (CA92.1) and `FileTimestamp` (C617.1). `ios_privacy_manifest_test.dart` fails if Swift code starts calling another required-reason API category without declaring it.
- Location usage string: when-in-use only (ADR-014).
- `ITSAppUsesNonExemptEncryption = NO` (§20): HTTPS via the OS only.

## Open questions (owners)

- **Q1 (Privacy):** a country-level package download reveals the package's country to the CDN (and its IP log ≤ 24 h). Is that "approximate location collected" for Play/Apple? Default in this draft: no, because the request carries no location and the country is the package's, not a device reading; alternative: declare approximate location, "not shared", "app functionality".
- **Q2 (Privacy):** Calculation links carry 6-decimal coordinates when the user copies one (D78) — user-initiated, outside app egress; confirm the "not collected" reading.
- **Q3 (Legal):** privacy-policy URL and text (§24) must exist before submission; the app shows it offline.
- **Q4 (Product):** device model is `null` in the diagnostic report (no dependency reads it, D84); add one only if support needs it.
