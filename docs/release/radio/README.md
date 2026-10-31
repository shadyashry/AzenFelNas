# Quran radio: sources and permission (DESIGN.md §15 D122)

Checked on **2026-10-31**. Re-check before each store release.

## Provider and API

| What | Where | Notes |
|---|---|---|
| API documentation | `https://www.mp3quran.net/eng/api` | Radios: `https://mp3quran.net/api/v3/radios`, optional `language` (`ar` default, `eng`, …) and `last_updated_date` ("records added after this date"). No key, no rate limit and no usage terms are stated. |
| Endpoint the app calls | `https://www.mp3quran.net/api/v3/radios?language=ar` and `?language=eng` | The bare host answers `301` to `www.`; the app calls `www.` directly. Answer: `{"radios": [{"id", "name", "url", "recent_date"}]}`; 177 entries, the same ids and URLs in both languages. |
| Stream host | `https://backup.qurango.net/radio/<name>` | `audio/mpeg`, 128 kb/s (Icecast headers). One entry (id 109082, "Holy Quran from Saudia Arabia") streams from `stream.radiojar.com`; it is another broadcaster and is **left out**. Streams answered `500` intermittently during the check (e.g. `mahmoud_khalil_alhussary`), then `200`; the app's retries and the *Unavailable* state cover that. |

The app uses the full list on every refresh: `last_updated_date` reports only additions, not changes or removals.

## Permission

MP3Quran's privacy page, Arabic `https://www.mp3quran.net/ar/privacy` and English `https://www.mp3quran.net/eng/privacy` (no date shown), has one rights clause, the same in both languages:

> "we allow any visitor or developer to copy any material or use any link" (English page, «Copyrights»)

Limits of that clause: it does not name audio, radio, streams, the API or third-party apps; "material" and "the websites" are undefined; it sits in a privacy policy, not a licence or terms of use; the two language versions list slightly different sister sites (`quranqo.net` / `qurango.net`).

How the app stays within it:

- only MP3Quran's own stations are listed and played (HTTPS on `mp3quran.net` / `qurango.net`), straight from its servers;
- nothing is recorded, downloaded or rehosted; buffering is temporary;
- a discreet credit on the Radio screen («Audio by MP3Quran» / «الصوت من MP3Quran») and in Settings → Attributions;
- no claim of affiliation with MP3Quran or any reciter, and no programme or reciter-on-air claim beyond the station's name.

**Owed:** Legal confirms this reading before a store release, or asks MP3Quran for written confirmation.

## Featured stations

`apps/mobile/assets/radio/featured_stations.json` (`radio_featured.v1`). Each entry applies only while the live list gives the id the same stream path.

| Id | Stream path | Shown as | Catalog names (en / ar) |
|---|---|---|---|
| 108 | `/radio/mix` | General recitations / تلاوات متنوعة | "-Main Radio-" / «العامة - متنوعة لمختلف القراء» |
| 74 | `/radio/mahmoud_khalil_alhussary` | catalog name | "Radio Mahmoud Khalil Al-Hussary" / «محمود خليل الحصري» |
| 69 | `/radio/mohammed_siddiq_alminshawi` | catalog name | "Radio Mohammed Siddiq Al-Minshawi" / «محمد صديق المنشاوي» |
| 32 | `/radio/abdulbasit_abdulsamad` | catalog name | "Radio Abdulbasit Abdulsamad" / «عبدالباسط عبدالصمد» |

The same reciters have other stations with the same name (74/75/76 Al-Hussary: plain, `_mojawwad`, `_warsh`; 69/70 Al-Minshawi; 30/31/32 Abdulbasit). The app tells them apart only by what the stream path states («Mujawwad recitation», «Warsh narration»). The API does not state the riwaya of the plain stations, so the reference's «Hafs» is not shown.

The two API answers of the check day are kept as test fixtures: `apps/mobile/test/fixtures/mp3quran_radios_{ar,eng}_2026-10-31.json`.
