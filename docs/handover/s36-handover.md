# S36 hand-over: known issues closed (DESIGN.md §15 D96)

Branch `slice/s36-known-issues`, cut from `main` at `68695aa`.

## What changed
- **Setup asks for exact alarms** after notifications, and says so first; Home then reads *Ready*.
- **Athan Health refreshes when the app returns** from system settings.
- **First start no longer freezes:** payload checks, gazetteer decoding and payload hashing run on background isolates in the app (`CheckPayload`, `DecodeGazetteerPayload` async; new `HashPayload` port in `dm_packages`; adapters take a `RunPayloadWork`, in place in widget tests).
- **Place search** runs as you type; lines show the country and rounded coordinates instead of numeric region codes; titles and saved labels use the primary name, with the matched spelling in brackets when it differs.

## Evidence
- `melos run ci` green: app 522 tests (+1 S12 benchmark in the new `test:perf` step), `dm_packages` 78.
- Android 16 emulator, release build: welcome screen answers 4 s after first frame (was frozen for 30 s); setup → notifications → *Alarms & reminders* → Home *Ready*; search as you type; Arabic Home, Athan, Settings and search.

## Still open
- A physical phone (hearing the Athan, OEM battery policies, 72 h suite); iOS needs macOS.
- Until 2026-11-01 the seed profiles are not in effect (D77).
