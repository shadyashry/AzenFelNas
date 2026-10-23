# ADR-012 · Android: `SCHEDULE_EXACT_ALARM` + `setAlarmClock` + foreground media service; direct-boot aware

- **Status:** `[DECIDED · revisit D5]`
- **Source:** `DESIGN.md` §4 ADR-012 (binding index). This file is the long-form record; where they differ, `DESIGN.md` wins (ADR-000).

## Context

Stub generated in slice S01 from the `DESIGN.md` §4 index entry. Long-form context is added when this ADR is next amended.

## Decision

No `USE_EXACT_ALARM` / `USE_FULL_SCREEN_INTENT`. Runtime `canScheduleExactAlarms()`; `POST_NOTIFICATIONS` runtime permission (API 33+). Inexact fallback is `Limited`. The exact-alarm → foreground-service start path is validated in slice S19 with its fallback.

## Trade-offs

- **Win:** —
- **Lose:** —

## Consequences

See the `DESIGN.md` sections referenced above.

**S19 (2026-10-23).** The spike for this ADR's open question is ADR-025: code, receipt protocol, scenario matrix and go/no-go criteria are in place; the physical-device run is OWED, so the conservative state in ADR-025 ("Decision per outcome") applies until it reports.

**S21 (2026-10-23).** `athan-core` implements the decision: `setAlarmClock` for Athans, `setExactAndAllowWhileIdle` for other entries, `setAndAllowWhileIdle` without exact alarms (Health `LIMITED(inexactFallback)`), a `mediaPlayback` foreground service with `USAGE_ALARM`, direct-boot-aware receivers, and the D79 notification fallback when the service start is refused. Mechanics: `DESIGN.md` §15 D81. Device proof: `docs/test-plans/s21-android-athan-device-suite.md` (OWED).

## REQ tags

REQ-ALM-001, REQ-ALM-002, REQ-ALM-020 … REQ-ALM-027, REQ-ALM-040, REQ-ALM-041, REQ-ALM-042

## Tests

`apps/mobile/android/athan-core/src/test` (JVM: arming window, reconcile, presentation, channels, health, events, manifest rules); the device suite above.

## Supersedes

—
