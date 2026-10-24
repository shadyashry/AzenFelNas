# Accessibility audit (S27; §18.6 beta exit, §18.10, REQ-UX-020)

## Automated (done, in CI)
- `apps/mobile/test/app/accessibility_audit_test.dart` covers every routed screen (`/`, settings, attributions, diagnostics, timeline, place, health, qibla) in its first-run state, in **en and ar**, at **100 % and 200 % text**. It checks Flutter's `androidTapTargetGuideline` (48 dp), `iOSTapTargetGuideline` (44 pt), `labeledTapTargetGuideline` and `textContrastGuideline`: **32 cases pass**.
- `apps/mobile/test/features/home/home_states_test.dart`, "loaded Home": the ready Home in all **10 sky phases** × en/ar × 100/200 % passes the same four guidelines (**40 cases**).
- **Finding fixed:** the Home place bar (`_PlaceBar`) overflowed by 17 px at 200 % English text. It is now a `Wrap`, and the button moves below the chip.
- Already in place: the sky-token contrast goldens (REQ-UX-010), the RTL goldens (REQ-UX-030), reduced motion and semantics on every time row (S16/S18 tests).

## Not automated
These parts are **owed** to the owner or QA:
- **Screen-reader sessions** with two users (ar, en) on a physical Android device (TalkBack) and iPhone (VoiceOver), following the scenarios below. Record pass/fail per scenario and attach the notes to the go/no-go.
- The loaded states of Timeline, Passport, Health and Qibla under the screen readers. The automated sweep audits their first-run states only.

| # | Scenario | TalkBack ar | TalkBack en | VoiceOver ar | VoiceOver en |
|---|---|---|---|---|---|
| 1 | Onboarding: choose a place manually | | | | |
| 2 | Home: hear the next prayer, its time and confidence label | | | | |
| 3 | Open Passport from a time row; hear the calculation details | | | | |
| 4 | Enable Athan; grant the permissions; run the Athan Test and answer it | | | | |
| 5 | Timeline: move across days, including a +1 Isha | | | | |
| 6 | Settings: switch language, digits, theme; reduced motion stops the sky animation | | | | |
| 7 | Qibla: hear the bearing and the calibration state | | | | |
| 8 | 200 % system text: every screen above remains usable, with no clipped text | | | | |

Pass = every scenario completes without sighted help, in both languages.
