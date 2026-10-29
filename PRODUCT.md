# Product

<!-- impeccable:product-schema 1 -->

## Platform

android

## Users
Arabic-speaking Muslims who pray five times a day and need to know, and be woken for, the next prayer. Launch starts Arabic-first in Egypt and the Gulf; English is secondary. The `DESIGN.md` §18.1 personas are binding:
- **Omar**, 34, Cairo commuter on a mid-range Android phone, Arabic UI: the times must match the mosque Adhan he hears, and the Fajr alarm must be reliable.
- **Noura**, 41, Riyadh parent on an iPhone with Focus on at night: she needs an alarm that breaks Focus and honesty about whether it will ring.
- **Yusuf**, 22, student travelling between Egypt and Norway: correct Isha after midnight, a visible high-latitude fallback.
- **Hajja Fatma**, 68, Alexandria, low vision, Arabic only: a big readable next prayer, screen reader, few taps.
- **Ahmed**, 29, Dubai engineer, sceptical: wants to see why a minute is what it is.

The core jobs are glancing at the next prayer, trusting the Athan alarm, and finding the Qibla.

## Product Purpose
An offline-first prayer times, Athan and Qibla app for iOS and Android: free, no account, no ads, no paid runtime dependency. Success is a user who trusts the minute shown and the alarm set, because the app proves both instead of asserting them.

## Positioning
The app competes on verifiable trust, not content (`DESIGN.md` §2). Five pillars:
1. **Explainable minute:** tap any time and see exactly how it was computed (Accuracy Passport, shareable Calculation ID).
2. **Honest alarm:** the app never says Ready when the OS might silence it (Athan Health with an `Unknown` state, an Athan Test that asks "did you hear it?").
3. **Typed truth:** Estimated never looks like Verified (sealed confidence labels).
4. **Sky-synced theme:** the app looks like the sky outside the window (sky phase drives the Home surface).
5. **Local-first privacy:** no account, no ads, the location never leaves the phone.

## Operating Context
Used several times a day in short glances: before leaving home, at work, in the car, at night before sleep, and during Ramadan for Imsak and Maghrib. It is used in bright daylight, in dark rooms at Fajr, and by older users with large text. The Qibla is found indoors, where magnetometers often fail; a sensor-free Sun-alignment method exists (`DESIGN.md` §6.6). The app must work fully offline, and the time a user sees must match the authority their mosque follows.

## Capabilities and Constraints
- **Screens (`DESIGN.md` §18.4):** Onboarding, Home, Day timeline, Accuracy Passport, Athan settings, Athan Health, Athan Test, Qibla, Manual place, Packages and change notes, Settings / Privacy / Attributions. V1 adds widgets and Travel Mode.
- **Built in Flutter.** One shared design on Android and iOS; only native behaviours differ (permission dialogs, back gesture, alarm surfaces, widgets). Android is the primary launch platform; iOS ships the same design.
- **Every `UiState` variant in §18.4 is kept.** Status copy (Calculated, Authority aligned, Verified, Estimated, Observed, Unknown, Expected) comes only from the shared §18.5 constants, and prohibited-word tests guard it.
- **Hard limits:** no religious value in code; no network host other than `cdn.azenfelnas.app` and `api.azenfelnas.app`; no raw coordinates in logs.
- **Open decisions (not decided):**
  - Brand: whether the domain and bundle identifiers follow the new name. Today the display name changes, while hosts and identifiers stay `azenfelnas.app`.
  - Arabic copy review; the copy is a draft in Egyptian tone.
  - Sharia approval of every profile; the seeds stay `DRAFT_UNVERIFIED`.

## Brand Commitments
- **Name:** Azen Fel Nas, Arabic أذّن في الناس ("proclaim to the people", Quran 22:27). It replaces "أذّن في الناس" as the name users see.
- **Voice:** calm, precise and honest. Say "Unknown" with a reason rather than invent a value, and never overclaim accuracy or alarm reliability.
- **Typefaces already chosen** (`DESIGN.md` §7.9): IBM Plex Sans Arabic and Inter.

## Evidence on Hand
- Accuracy Lab results against JPL DE440s, and the golden corpus for 49 cities (`lab/`, `packages/geo_salah_core/test/golden/`).
- No testimonials, user counts, store ratings or authority endorsements exist. Do not fabricate them.
- Profiles are `DRAFT_UNVERIFIED`; no authority alignment may be claimed until the Sharia board approves.

## Product Principles
1. **Trust is shown, not claimed.** Every time, alarm state and direction can be traced to its evidence.
2. **Unknown beats invented.** An honest gap is better UI than a confident guess.
3. **The next prayer first.** Home answers "what is next and when" at a glance, even at 200 % text.
4. **Quiet by default.** The sky is the one expressive surface; content screens stay calm and readable.
5. **Private by construction.** Nothing in the UI asks for more than the task needs.

## Accessibility & Inclusion
WCAG 2.2 AA contrast in every sky phase, light and dark (REQ-UX-010). RTL-first layouts with mirror-safe icons (REQ-UX-030). Dynamic type to 200 %, targets of at least 44 pt, semantics on every time row, non-colour status cues, and reduced motion that stops the sky animation (REQ-UX-020). Low-vision older users (Hajja Fatma) are a primary audience, not an edge case.
