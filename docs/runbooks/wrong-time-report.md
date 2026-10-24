# Wrong-time report (§21)

**Trigger:** a correction through `/v1/feedback/corrections` (control plane, D86) or a support e-mail. **Owner:** accuracy lead; first response ≤ 2 business days (≤ 24 h in Ramadan).

1. **Triage** weekly from the corrections table (no identity; coordinates have ≤ 2 decimals). For a support e-mail, ask for the `CalculationId` (Passport → copy).
2. **Reproduce** with the `CalculationId`: it names the inputs hash, engine, profile and TZDB versions. Run `dart run geo_salah_core:bench` with the decoded inputs.
3. **Classify** as one of: engine defect (a test plus a fix, golden-update PR if needed); profile data (a profile PR through the Sharia gate, ADR-008, never a code change: §0.2 rule 1); TZ data (tzdb-emergency.md); user setting or location (reply with guidance); or mosque practice differs (FAQ "Why does my time differ from the mosque by a minute").
4. **Pattern on production in a launch country** (several reports, same profile and day) is SEV1: package-rollback.md.
5. Close with the classification. The review tool for `status`/`reviewed_by` is open (S26 hand-over).
