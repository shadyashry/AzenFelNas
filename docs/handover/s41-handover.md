# S41 hand-over: owner review 2, the first run and the look (DESIGN.md §15 D100)

Branch `slice/s41-ux-polish`, cut from `slice/s40-uae-seed`.

## What changed
- **Splash:** deep emerald launch screen (Android, iOS), then a 1.4 s in-app intro (mark, gold girih, gold line) that fades into the app; never blocks a tap.
- **Welcome:** language choice fixed at the top, buttons fixed at the bottom: switching language moves nothing. Feature marks under the text. *Find my location* is the one main action.
- **Place found, not asked for:** a location fix is named after the nearest city ("Prayer times for Cairo"); if location fails, the phone's time zone offers its city in one tap; the city search lists the zone's cities before anything is typed; Arabic names for Arabic readers; flags instead of coordinates.
- **Green for on:** switches, boxes, radios and the chosen segment.
- **Bars:** every list scrolls clear of the system navigation bar and the floating tab bar.

## Owed
- Phone check: splash on a cold start, the welcome screen in both languages, the zone suggestion with location off, the scroll ends on every tab with 3-button and gesture navigation.
- iOS: the `dm/device_zone` channel and the launch colour are written but not built (needs a Mac).
