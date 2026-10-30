# Downloadable Athan voices: provenance and licences (DESIGN.md §15 D111)

Checked on 2026-10-30 from each file's Wikimedia Commons page, the Commons API (licence metadata, file history,
upload log), the uploaders' user and talk pages and the block log. Nobody was contacted, nothing was bought and no
agreement was accepted. `CC-BY-3.0-legalcode.txt` is the licence text, fetched from
https://creativecommons.org/licenses/by/3.0/legalcode.txt (sha256 `e6bc9e9c…48b8e76`).

## Integrated

### `malmo_fajr_2012`: Fajr Athan, Islamic Center Malmö, Eid al-Fitr 2012

| | |
|---|---|
| Source page | https://commons.wikimedia.org/wiki/File:Eid_al-Fitr_Fajr_azan_at_Malm%C3%B6_Mosque_-_19_August_2012.webm |
| Original | https://www.youtube.com/watch?v=0IHfm4Y82xA ("Islamic Center Malmo, Ezani Sabahut, Besim Azemi, Gryningsbön Azan, Qendra Islame Malmo Suedi") |
| Creator, as the source states it | Islamic Center Malmö (the mosque's YouTube channel `islamiccentermalmo`). The title names Besim Azemi but does not say he is the muezzin, so the app does not name a performer. |
| Uploader to Commons | Rafic.Mufid, 2018-05-28, with video2commons |
| Recorded | 2012-08-19 (Eid al-Fitr 1433, the dawn prayer) |
| Licence | CC BY 3.0 (YouTube's "Creative Commons Attribution licence (reuse allowed)"), confirmed by Commons' `{{YouTubeReview}}` with an archive of the YouTube page of 2020-02-12 |
| Allows | redistribution (also commercial), offline download, adaptation (taking the audio, trimming, gain) with attribution, a licence link and a notice of changes; no share-alike, so the app's code licence is unaffected |
| Retrieved | 2026-10-30; 78 385 315 bytes, sha1 `bc75d5cee271efb67f03d3f35474a9362fce103f` (= Commons), sha256 `899a3325aafb03e09381b3e40149e88d06b00b40ce2b1eeb09d63e594c9c1742` |
| Original audio | Opus 48 kHz stereo, 247.56 s, copied out of the WebM unchanged (`originals/malmo_fajr_2012.opus` in the build directory) |
| Processing | first 4.5 s (room noise below −38 dB) removed; −2.2 dB to −16.0 LUFS integrated; AAC-LC 96 kbps 48 kHz stereo `.m4a`; nothing else |
| App file | `malmo_fajr_2012.m4a`, 2 975 655 bytes, 243.05 s, sha256 `a51cd54c043cc5af7d669811245f91a0c7c90086865c608998a6adf44f8559dc`, true peak −4.7 dBTP; decodes with no error; rebuilt byte for byte by `dm-pipelines athan-voices build` |
| Measured, not heard | no clipping (flat factor 0, peak −2.5 dBFS in the source); floor about −50 dB between phrases; 14 sung phrases with 2–5 s pauses, consistent with a Fajr Athan; a 3.5 s unidentified sound at 4.75 s before the first phrase (kept: only silence is trimmed); the file ends 6.5 s into the last phrase while still at −29 dB, so the source may cut the final phrase |
| Listening review | **not done** (no listening possible where this was built). The catalog marks it `PENDING`: dev and lab builds only, and offered for Fajr only. |
| Attribution shown | the voice row (licence and creator, linking to the licences page) and the licences page (`attributions.v1.json`), also `LICENSES.md` |

## Excluded

| Candidate | Stated licence | Why excluded |
|---|---|---|
| `File:Beautiful_adhan.ogg` (Adam-synagda, "own work", 2022-04-29, 154 s) | CC0 | The account is a blocked sock puppet of Hadysylmy (blocked 2022-02-20 for abusing multiple accounts) and was itself blocked indefinitely in November 2022 after repeated copyright deletions. A sibling account's Athan-family upload (`File:Iqama.ogg`) was deleted as "clearly not a recording of own voice; no permission". The "own work" claim cannot be relied on. It had been bundled as the dev/lab test sound (D94); it is removed. |
| `File:Azan.ogg` (Andrewler, "own work", 2022-09-03, 183 s) | CC BY-SA 4.0 | Same sock-puppet family (Andrewler is tagged a sock of Hadysylmy and is the account whose `File:Iqama.ogg` was deleted as not own voice, alongside other copyright deletions). Unreliable provenance. |
| `File:The_Adhan_-_Muslim_Call_to_Prayer_-_Aaqib_Azeez.mp3` (User:Atcovi) | CC BY-SA 4.0 | The 2022 "own work" upload (235 s) was overwritten on 2025-12-11 by a different 86 s recording ("An Adhan that adheres to the Sunnah…") and renamed to add "Aaqib Azeez". The page does not say who Aaqib Azeez is, whether the uploader recorded the new file, or who the performer is; a web search found nothing. Unresolved. |
| aladhan.com downloads; Alafasy, al-Nafees, Abdul Basit and other famous voices | — | A download button is not permission; no documented permission for an exact recording. Not used. The licensed Egyptian sheikhs of D93 remain the plan for launch voices. |
