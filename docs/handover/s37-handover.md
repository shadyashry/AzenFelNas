# S37 hand-over: first phone feedback (DESIGN.md §15 D97)

Branch `slice/s37-phone-feedback`, cut from `main` at `5b0ce16`.

## What changed
- **Language:** the welcome screen offers العربية / English, preselected from the phone.
- **Location off:** *Turn on location* opens the phone's location settings and the app retries on return; a blocked permission gets *Open settings*.
- **Cairo times:** the Egyptian, Saudi and UAE seed profiles are in effect from 2026-10-01 (were 2026-11-01). Cairo on 2026-10-29 now matches the published Survey Authority table within 1 minute (Fajr was 7 min late, Isha 3 min).
- **Qibla:** the dial follows the phone even when the compass reports coarse accuracy, with the calibration hint shown.

## Evidence
- `melos run ci` green; gsctl Go tests green; `gsctl validate` dev and lab.
- New tests: Cairo vs the published times, calibrating dial, location button and return-retry, language choice.
- Android 16 emulator, release build: welcome in Arabic via the new choice; location off → *شغّل الموقع* → location settings → back → the app retried by itself; Cairo Home without the engine-default notice (Maghrib 18:11, Isha 19:29); Qibla 136.1°, accuracy ±10° (was ±0°), the turn hint following the virtual sensor.
- Plan/snapshot fixtures regenerated: Fajr −7/−8 min, Isha −2/−3 min, nothing else.

## Owed
- The ±1 minute on Sunrise/Maghrib is the rounding mode (Sharia board, data only).
- Phone check of the compass and the location flow.
