# S38 hand-over: owner review of messages, taps and the compass (DESIGN.md §15 D98)

Branch `slice/s38-ux-compass`, cut from `main` at `6157c01`.

## What changed
- **No codes on screen:** notices say what to do; the code is on a long press of the title, for support.
- **One style:** notices and the location steps use the app's Rawdah look (gold border, Naskh title, medallion).
- **Fewer taps:** the welcome screen asks for the place directly (language, *Use approximate location*, *Choose a place*); the place screen leads with *Use approximate location*; coordinates are a small link.
- **Compass:** screen-rotation and tilt compensation, gyroscope-free fallback, smoothing, calibration status as accuracy, a fluorescent green line and a haptic tap when the phone faces the Qibla within 3°, a large turn instruction.

## Evidence
- `melos run ci` green.
- Android 16 emulator, release: welcome with language + location + place; location off → Rawdah step *Location is not available* with *Turn on location*, no code; place screen leads with *Use approximate location*; Qibla shows the large *Turn N° right*, accuracy ±10° from the calibration status and the hold-flat hint, and the dial turns with the sensor. The emulator's fused sensor cannot be steered to the bearing, so the green line is verified by widget tests only.

## Owed
- A map picker needs self-hosted map tiles (only our two hosts may be contacted).
- Phone check of the compass in portrait, landscape and upright, and of the haptic tap.
