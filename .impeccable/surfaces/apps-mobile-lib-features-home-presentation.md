---
version: 1
slug: "apps-mobile-lib-features-home-presentation"
primary_target: "apps/mobile/lib/features/home/presentation"
related_targets: ["apps/mobile/lib/app"]
---

# Home surface brief (Azen Fel Nas)

Scope: the app shell (bottom navigation) and Home; the same world extends to Qibla, Athan, Settings, Passport, Timeline, Onboarding, Manual place. Mode: Operate.
Audience and task: Arabic-first worshippers (DESIGN.md §18.1 personas) glancing at the next prayer, its time and how long is left, several times a day, in daylight and in the dark, often with large text.
Constraints: every §18.4 UiState kept; status copy from §18.5; WCAG AA in every hour light; RTL first; no religious value in code.

## Direction contract
THESIS: The day is a mihrab: the Sun's path from sunrise to sunset is drawn as a pointed niche that frames the next prayer, gilded where the day has passed. It refuses the category default of a green header over a stack of identical time cards.
OWN-WORLD: Rawdah Garden of the Madinah Mushaf: pearl marble ground with a faint gold girih of eight-point stars, Rawdah emerald fields, metallic gold hairlines with diamond terminals and eight-point rosettes, a surah-header cartouche with pointed ends. Amiri Naskh for prayer names and times; IBM Plex Sans Arabic for UI text.
STORY: The worshipper sees which prayer is next and in how many minutes, sees where the day stands on the arch, trusts the times (one quiet confidence line, tap any time for its Passport), and moves to Qibla or Athan from the bar.
FIRST VIEWPORT: Top 430 dp is the hour-light field: place and Hijri date with the moon phase; the mihrab arch with prayer diamonds at their real instants, the Sun at now; inside the niche the cartouche "صلاة الظهر" and the time in Amiri bold ~74 sp; countdown and a gold progress line from the previous prayer. A gold rule; then the pearl list of six prayers with light swatches, next one washed in the hour light. Floating emerald navigation bar with gold rim: mihrab Home, star-compass Qibla (needle at the real bearing), minaret Athan with readiness ring, rosette Settings; active tab inside a glowing gold mihrab.
FORM: Rawdah Garden (Mushaf Madinah tuning A2), user-pinned after a bolder re-roll and four type pairings; Amiri chosen. seed: seed:461d9bb913a8a477
SIGNATURE: prayer-hour light. The field and the active-tab glow take the light of the current interval: night lapis before Fajr and after Isha, dawn teal, Rawdah emerald forenoon and midday, honey gold after Asr, rose amber after Maghrib.
FINISH: unreviewed and undocumented is unfinished; this build ends with the finish review, the verdict, DESIGN.md, and every shipping raster carrying its provenance
