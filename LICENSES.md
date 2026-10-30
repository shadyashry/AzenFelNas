# Licenses and attributions

Placeholder created in slice S01. This file is **generated per release** (`DESIGN.md` §10.4, `REQ-SEC-040`) from the SBOM and the data-source attributions below; do not edit release sections by hand.

## Data sources (planned, ADR-015)

| Source | Licence | Obligation |
|---|---|---|
| timezone-boundary-builder (`tz_polygons`; release 2026e from S11) | ODbL | attribution; produced database published under ODbL |
| Natural Earth admin-0 map units 1:10m (`country_polygons`; release 5.1.2 from S11) | Public domain | attribution (courtesy) |
| GeoNames `cities15000` + alternate names (`gazetteer`; read from the `geonamescache` 3.0.2 wheel from S12, §15 D72) | CC BY 4.0 | attribution ("Contains data from GeoNames, geonames.org, CC BY 4.0") on the attribution screen |
| IANA tz database and `zic` (`tzdata`; release 2026e from S10, pinned in `data-pipelines/config/tzdata.v1.toml`) | Public domain | — |

## Athan audio (bundled in `apps/mobile/assets/athan/`)

| Source | Licence | Obligation |
|---|---|---|
| `test_cc0_adhan.m4a`: Wikimedia Commons `File:Beautiful_adhan.ogg` by Adam-synagda (own work, 2022-04-29), trimmed, normalised and re-encoded | CC0 1.0 | none; a **test sound**, offered on `dev` and `lab` only and removed before 1.0.0 (`DESIGN.md` §15 D94). Licensed recordings follow `docs/release/athan-audio-licensing.md` (D93) |

## Accuracy Lab (development only, not shipped in the app)

| Source | Licence | Obligation |
|---|---|---|
| JPL DE440s planetary ephemeris (`de440s.bsp`) | U.S. Government work (JPL/NASA) | fetched by URL with a sha256 pin; not redistributed (`DESIGN.md` §15 D28) |
| MET Norway Sunrise API 3.0 values in `lab/tests/data/published_sun_events_2026.json` | NLOD 2.0 / CC BY 4.0 | attribution: "MET Norway" (`DESIGN.md` §15 D31) |

## Offline Quran package (downloaded after install, not bundled; DESIGN.md §15 D106)

| Source | Licence | Obligation |
|---|---|---|
| Madinah Mushaf, riwayat Hafs, digital edition 1441, King Fahd Glorious Quran Printing Complex (`dm.qurancomplex.gov.sa/Download/1441-AI-hafs.zip`, sha256 `280c5d71…2d9eef`, as published by the Complex); rendered unchanged to lossless WebP | KFGQPC usage rights (`dm.qurancomplex.gov.sa/rights/`): free use in software inside and outside Saudi Arabia | attribute the Complex; never imply endorsement; written confirmation for redistribution from our CDN is **owed** (Legal) |
| KFGQPC Hafs Uthmanic script v3.0 (`fonts.qurancomplex.gov.sa/fonts/KFGQPC-Hafs-V30.zip`): the font file and the text of its Word file (verses, page and line breaks) | font EULA in the font's name table: use, copy, distribute; no modification, no sale | ship the font byte for byte; confirmation that the text may feed a search index is **owed** (Legal) |
| Tanzil.net Quran metadata (`quran-data.xml`), juz starts only | CC BY 3.0 | attribution |

Build tools only (not shipped): pypdfium2 5.14.0 (Apache-2.0 / BSD-3-Clause; PDFium BSD-3-Clause) and Pillow 13.0.0 (MIT-CMU) in `data-pipelines`.

## Fonts (bundled in `packages/dm_ui/fonts`, §7.9, §15 D89)

Amiri, IBM Plex Sans Arabic, Inter — SIL Open Font License 1.1; each licence sits beside its font files (`OFL-*.txt`).

The brand mark's lettering is Aref Ruqaa (SIL OFL 1.1), rendered into the logo and icon rasters; the font and its licence are in `design/brand/fonts`.

## Software dependencies

Generated from the SBOM per release.

## Ported code

| Source | Licence | Obligation |
|---|---|---|
| GeographicLib 2.0 `Geodesic` inverse (C. F. F. Karney, 2011–2022), ported to Dart in `packages/geo_salah_core/lib/src/astro/geodesic.dart` (S18, §6.6) | MIT/X11 | keep the copyright notice in the ported file and in the app's licence page |
| GeographicLib 2.0 Python, used only to generate `packages/geo_salah_core/test/qibla/qibla_vectors.json` (`tool/qibla_vectors.py`, not shipped) | MIT/X11 | — |
