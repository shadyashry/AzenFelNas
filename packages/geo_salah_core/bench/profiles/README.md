# Bench profiles (stand-ins until S07)

Profile **data** read by the engine bench (`bin/bench.dart`), the golden corpus tool and the tests (`DESIGN.md` §15 D48). No religious value is written in Dart (§0.2 rule 1). Each file is an Appendix A `prayer_profile.v1` document cut down to the members the engine reads in S06. S07's `geo_salah_profiles` loader and `profiles/engine/engine.default.yaml` replace this directory. Nothing here ships in the app, and the profile stays `DRAFT_UNVERIFIED` (Appendix E).

## `engine.default.json`

| Member | Value | Source |
|---|---|---|
| `version` | `0000.0.1` | Sentinel that no published profile uses (S05 used `0000.0.0` with three events, §15 D40) |
| `status` | `DRAFT_UNVERIFIED` | Appendix E |
| `authority.type` | `ENGINE_DEFAULT` | §6.5, ADR-007 |
| `rules.fajr`, `rules.isha` | `solarAltitude`, 18° | §6.5: "`engine.default` (`ENGINE_DEFAULT`, Fajr/Isha 18°, k = 1, scope: all)" |
| `rules.asr` | `shadowFactor`, k = 1 | §6.5 (same sentence) |
| `rules.sunrise`, `rules.maghrib` | `horizon` at the §6.2 defaults (34′ + 16′) | §6.5 rule types, ADR-003 |
| `rules.dhuhr` | `transit`, no `offsetMinutes` | §6.5 rule type; an absent offset is 0 (Appendix A) |
| `rules.imsak` | `null` (not calculated) | §6.5 gives no Imsak rule for `engine.default` |
| `horizon.elevationPolicy` | `NONE` | ADR-003, §15 D3 |
| `rounding` | `default: ceil`, `sunrise: floor` | ADR-005, §15 D4 |
| `evidence.benchmarkReportId` | `null` | No benchmark report exists |

Members the S06 engine does not read are omitted rather than invented: `highLatitude.chain` (S08), `adjustments` (none, so no offsets), scope, validity dates, approvals and evidence sources (S07). The reader (`lib/src/bench/bench_profile_reader.dart`) rejects unknown members.
