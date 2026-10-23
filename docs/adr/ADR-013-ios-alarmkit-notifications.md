# ADR-013 · iOS: AlarmKit on iOS 26+, local notifications on iOS 18; absolute-instant triggers; 64-slot budget

- **Status:** `[DECIDED · revisit D6]`
- **Source:** `DESIGN.md` §4 ADR-013 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

Support matrix iOS 18 / 26 / 27. The notification path reports `Scheduled (unverifiable)` and never `Ready`. iOS notification Athan is a ≤ 29 s clip; AlarmKit long-audio behaviour validated in S19. Critical-alerts entitlement is **not** requested for MVP.

## Trade-offs

- **Win:** —
- **Lose:** —

## Consequences

See the `DESIGN.md` sections referenced above.

**S19 (2026-10-23).** The spike for this ADR's open question is ADR-025: code, receipt protocol, scenario matrix and go/no-go criteria are in place; the physical-device run is OWED, so the conservative state in ADR-025 ("Decision per outcome") applies until it reports.

**S22 (2026-10-23).** `AthanKit` implements the decision (`DESIGN.md` §15 D82): AlarmKit `.fixed(Date)` alarms for Athans on iOS 26+ once authorised, `UNTimeIntervalNotificationTrigger` from absolute instants otherwise, one window cut to 64 − 1 slots, clips from the manifest's `iosClip` in `Library/Sounds/`. Health never reports `READY` on the notification path (`deliveryVerified` is always `false` there) and not on AlarmKit until ADR-025 reports GO. Device suite: `docs/test-plans/s22-ios-athan-device-suite.md` (OWED).

## REQ tags

REQ-ALM-030, REQ-ALM-031, REQ-ALM-032, REQ-ALM-033, REQ-ALM-034, REQ-ALM-035, REQ-ALM-036

## Tests

`apps/mobile/ios/AthanKit/Tests/AthanKitTests` (`swift test`: reconcile, window, health, clips, Test, events, Runner configuration); the device suite above.

## Supersedes

—
