# Licenses and attributions

Placeholder created in slice S01. This file is **generated per release** (`DESIGN.md` §10.4, `REQ-SEC-040`) from the SBOM and the data-source attributions below; do not edit release sections by hand.

## Data sources (planned, ADR-015)

| Source | Licence | Obligation |
|---|---|---|
| timezone-boundary-builder (`tz_polygons`) | ODbL | attribution; produced database published under ODbL |
| Natural Earth admin-0 1:10m (`country_polygons`) | Public domain | attribution (courtesy) |
| GeoNames `cities15000` + alternate names (`gazetteer`) | CC BY 4.0 | attribution |
| IANA tz database (`tzdata`) | Public domain | — |

## Accuracy Lab (development only, not shipped in the app)

| Source | Licence | Obligation |
|---|---|---|
| JPL DE440s planetary ephemeris (`de440s.bsp`) | U.S. Government work (JPL/NASA) | fetched by URL with a sha256 pin; not redistributed (`DESIGN.md` §15 D28) |
| MET Norway Sunrise API 3.0 values in `lab/tests/data/published_sun_events_2026.json` | NLOD 2.0 / CC BY 4.0 | attribution: "MET Norway" (`DESIGN.md` §15 D31) |

## Fonts (planned, §7.9)

IBM Plex Sans Arabic, Inter — SIL Open Font License 1.1.

## Software dependencies

Generated from the SBOM per release.
