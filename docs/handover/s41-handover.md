# S41 hand-over: owner reviews 2 and 3, the first run and the look (DESIGN.md §15 D100, D101)

Branch `slice/s41-ux-polish`, cut from `slice/s40-uae-seed`.

## What changed
- **Splash:** deep emerald launch screen (Android, iOS), then a 1.4 s in-app intro (mark, gold girih, gold line) that fades into the app; never blocks a tap.
- **Welcome:** language choice fixed at the top, buttons fixed at the bottom: switching language moves nothing. Feature marks under the text. *Find my location* is the one main action.
- **Place found, not asked for:** a location fix is named after the nearest city ("Prayer times for Cairo"); if location fails, the phone's time zone offers its city in one tap; the city search lists the zone's cities before anything is typed; Arabic names for Arabic readers; flags instead of coordinates.
- **Green for on:** switches, boxes, radios and the chosen segment.
- **Bars:** every list scrolls clear of the system navigation bar and the floating tab bar.
- **Header (D101):** the place's name in a chip (the device location named after its city), no "pinned/manual/approximate" words, no underlined link; plainer no-profile notice.
- **Theme names (D101):** "Dynamic (changes with prayer times)" / «ديناميكي (يتغيّر مع أوقات الصلاة)», «داكن», «حسب الجهاز».
- **Opening (D101):** full-screen animated mihrab (arch draws, lamp lights, mark rises, light sweep), held until the first screen is ready, tap to skip.
- **Opening (D112, replaces D101/D106's):** to the owner's motion reference: the native launch is the logo's green only; the approved logo fades in (97 → 100 %), a glow at the lantern, then the sunrise, a light along the horizon line, then a 450 ms crossfade into the real first screen (about 1.95 s once the logo is on screen). Reduced motion and link launches: still logo, 180 ms fades. Verified on the Android 16 emulator: cold launch, resume, deep link, Remove animations, airplane mode, a 720×1280 screen. 15 intro widget tests.

## Owed
- Phone check: the opening (D112) on a real cold start (frame rate, since the emulator drops frames; how long the plain green shows before the logo), Android 8–11's launch window, the welcome screen in both languages, the zone suggestion with location off, the scroll ends on every tab with 3-button and gesture navigation.
- iOS: the `dm/device_zone` channel and the launch colour are written but not built (needs a Mac).
