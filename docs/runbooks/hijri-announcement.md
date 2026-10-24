# Hijri announcement (REQ-OPS-002: ≤ 6 h)

**Trigger:** an official month announcement (e.g. Ramadan, Shawwal) by a launch country's authority. **Owner:** Backend/Data; **Sharia board** accountable for the source (§23.1).

> **Gap (S27):** the `hijri` package type has no reader in this build (REQ-PKG-006). The app shows the tabular month with the user's ± day override (US-07) and labels it accordingly. Until the `hijri` package lands, this runbook ends at step 2 and the in-app override is the user path. The open item is §15 D87.

1. **Capture the official source:** the authority's publication (URL, time, wording). Never a news site alone.
2. **Record** it in the incident note and the Hijri source register (Sharia board).
3. *(when the package exists)* Update the `hijri` package data, run its tests, publish `urgent` to `lab` and confirm in the lab that the Ramadan rule activates (e.g. the `ramadan` adjustments of the profile), then promote.
4. **Verify** on a canary device: the Hijri date and any Ramadan-specific Isha rule.
