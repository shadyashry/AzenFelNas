# Downloadable Athan voices: provenance and licences (DESIGN.md §15 D111, D112)

Checked on 2026-10-30 from each source page (Wikimedia Commons API and file histories, Internet Archive item
metadata and the uploader's other items, uploaders' talk pages and the Commons block log). Nobody was contacted,
nothing was bought and no agreement was accepted. `CC0-1.0-legalcode.txt` is the CC0 text
(https://creativecommons.org/publicdomain/zero/1.0/legalcode.txt, sha256 `a2010f34…a7c547cf0499`). The Public Domain
Mark has no legal code; its deed is https://creativecommons.org/publicdomain/mark/1.0/.

Measurements below are from ffmpeg (loudness, peaks, 100 ms RMS phrase segmentation). **No recording has been
listened to here**; both voices are `PENDING` (dev and lab builds only) until the owner listens.

## Integrated (standard Athan, offered for every prayer)

### `mirza_isha_2013`: Moazzambeg Mirza (Ahmedabad, 2013)

| | |
|---|---|
| Source | https://archive.org/details/IshaAzanByMoazzambegMirza07092013 ("Isha Azan by Moazzambeg Mirza (07-09-2013) in Muhammadi Masjid Jamiyat ul-Ahle Hadees, Sarkhej, Ahmedabad") |
| Creator, as the source states it | Moazzambeg Mirza, the muezzin. The same account publishes his own watercolours and sketches (8 items), all with the same mark, so the performer is the publisher. |
| Licence | Public Domain Mark 1.0, applied by the performer himself. PDM states "no known copyright restrictions"; it is not a formal waiver like CC0, so **Legal is to confirm** that the performer's own mark is enough (owed). |
| Retrieved | 2026-10-30; 4 405 187 bytes, sha1 `8b53beed…dcf4001fefe4b9c3` (= archive.org), sha256 `ba756b8e…9f270470b` |
| Original audio | MP3 44.1 kHz stereo, 272.4 s (the stream copied out unchanged) |
| Measured | integrated −13.8 LUFS, peak −0.2 dBFS, no clipped runs; floor −46 dB between phrases (signal to floor about 30 dB); 13 sung phrases of 10–17 s from 13.3 s to 260.8 s with 3–8 s silences, then a faint 5 s sound (≤ −24 dB) |
| Processing | first 12.8 s removed (room tone with two faint handling sounds ≤ −25 dB, before the first phrase); −2.2 dB to −16.0 LUFS; AAC-LC 96 kbps 44.1 kHz stereo |
| App file | 3 169 859 bytes, 259.5 s, sha256 `70e66812…00ba4859`, peak −2.2 dBTP, decodes with no error, rebuilt byte for byte |

### `icr_friday_2024`: Asim Javed (ICR, 2024)

| | |
|---|---|
| Source | https://archive.org/details/icr-friday-prayer-1st-adhan-17th-may-2024-9th-dhul-qadah-1445-by-asim-javed ("ICR Friday 1st Adhan … Called by: Asim Javed") |
| Creator, as the source states it | Asim Javed, the muezzin. The same account publishes the centre's Friday khutbahs and prayers (348 items, CC0), so the publisher is the centre's own archive and the muezzin himself. |
| Licence | CC0 1.0: any use, including redistribution in an app and offline download, no attribution required (given anyway). |
| Retrieved | 2026-10-30; 77 525 766 bytes, sha1 `0d251a22…4c8db542` (= archive.org), sha256 `c0b18b25…4abd839f` |
| Original audio | WAV PCM 32-bit 44.1 kHz stereo, 219.7 s (lossless; copied out unchanged) |
| Measured | integrated −11.5 LUFS, peak −2.3 dBFS, no clipped runs; floor −38 dB; 12 phrases of 9–15 s, then about 20 s that differ from the phrases (a longer, uneven section, possibly the closing phrase drawn out or a supplication); the first phrase starts 0.1 s into the file, so its first syllable may be cut by the source |
| Processing | nothing trimmed; −4.5 dB to −16.0 LUFS; AAC-LC 96 kbps 44.1 kHz stereo |
| App file | 2 683 486 bytes, 219.7 s, sha256 `37727d79…d301936d1`, peak −6.9 dBTP, decodes with no error, rebuilt byte for byte |

## Removed after the owner's review

| Voice | Why |
|---|---|
| `malmo_fajr_2012` (Islamic Center Malmö, Eid al-Fitr 2012, CC BY 3.0, via Commons) | Integrated in D111; the owner listened and found it "not accurate and not clear" (2026-10-30). Removed from the catalog and the pipeline pins. |

## Excluded

| Candidate | Licence stated | Why excluded |
|---|---|---|
| Commons `File:Beautiful_adhan.ogg`, `File:Azan.ogg` | CC0, CC BY-SA 4.0 | Uploaders are blocked sock puppets of one user whose other Athan upload was deleted as "not a recording of own voice". Also the former bundled test sound (removed in D111). |
| Commons `File:The_Adhan_-_Muslim_Call_to_Prayer_-_Aaqib_Azeez.mp3` | CC BY-SA 4.0 | Overwritten in 2025 by a different recording and renamed; performer and recorder unstated. |
| Commons `File:Adhan, Great Mosque of Mecca - Jan 21, 2013.webm` (YouTube CC BY, licence reviewed) | CC BY 3.0 | Incomplete: 11 phrases, the last cut by the end of the video (197 s). Cutting or joining is not allowed. |
| Commons `File:Maghrib Adhan at the Masjid al Haram, Mecca - 25 Feb, 2012.webm` | CC BY 3.0 | Crowd recording: phrases only about 8 dB above the background. Not clear. |
| Commons `File:Time of Adhan, Great Mosque of Mecca - Jan 6, 2018 .webm` | CC BY 3.0 | Not downloaded (279 MB video); a visitor's recording in the Haram, the same crowd problem expected. Can be checked later. |
| Internet Archive ICR Friday 2nd Athan (Asim Javed, CC0) | CC0 | Same good provenance, but the short Friday second Athan: fast, floor only 17 dB below the voice. |
| Commons `File:33937 ejaz215 call-to-prayer-from-the-prophet-s-mo.ogg` (from Freesound) | CC BY 3.0 | The Freesound page no longer shows the sound or its licence; "from the Prophet's mosque" suggests a broadcast capture with no sign the uploader owns it. |
| Commons `File:Call to prayer by Sabah Fakhry.mp3` | "PD-Old" | A 1985 recording by a singer who died in 2021: the public-domain claim is wrong. |
| Internet Archive "Makkah Azan", "28MayFajrAdhanMakkah", "Adhan Recordings from Doha", "Adhan From Egypt Abdulnasser Harak", "Azaan of World Mosques", al-Suraihi, Naif and similar | PD Mark / CC0 by anonymous uploaders | Re-uploads of broadcast or famous recordings by people who do not own them; a mark or a waiver from a non-owner is not permission. |
| Commons `Llamada a oración Mezquita Hassan II.wav`, `Athan in Ramadan.wav`, `Athan during Ramadan 2.wav`, `Adhan in Istanbul.webm`, `Hminsec150 Konya.webm`, radio aporee field recordings | CC BY-SA 4.0, CC0, CC BY 3.0 | Ambient field recordings (sea, wind, talk, traffic) or partial clips (37–84 s). Not clear or not complete. |
| Commons `Islamic call to worship.oga` | CC BY-SA 4.0 | A spoken talk about the Athan, not an Athan. |
| Commons/YouTube Isfahan and other Shia-form recordings | CC BY 3.0, CC BY-SA 4.0 | Different Athan wording from the form used by the app's users; not offered. |
| aladhan.com downloads; Alafasy, al-Nafees, Abdul Basit and other famous voices | — | A download button is not permission; no documented permission for an exact recording. D93's licensed Egyptian sheikhs remain the launch plan. |
