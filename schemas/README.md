# schemas/

JSON Schema (draft 2020-12) is the contract for every JSON document that crosses a language or process boundary (ADR-023). Change the schema first, then the models, then the fixtures.

| Schema | Source in `DESIGN.md` | Models (round-tripped against the fixtures) |
|---|---|---|
| `prayer_profile.v1` | Appendix A (copied verbatim) | Dart `geo_salah_core` (moved from `geo_salah_profiles` in S07, §15 D51) · Go `tools/gsctl/internal/schema/profile` |
| `schedule_plan.v1` | §7.7, Appendix B | Dart `dm_contracts` · Kotlin `athan-core` · Swift `AthanKit` |
| `snapshot.v1` | Appendix I | Dart `dm_contracts` · Kotlin `athan-core` · Swift `AthanKit` |
| `event_log.v1` | Appendix J | Dart `dm_contracts` · Kotlin `athan-core` · Swift `AthanKit` |
| `tuf_metadata.v1` | §9.1, Appendix C | Dart `dm_packages` · Go `tools/gsctl/internal/schema/tuf` |
| `telemetry_aggregate.v1` | Appendix L | Dart `dm_contracts` · Go `services/control-plane/internal/schema/telemetry` |
| `calculation_trace.v1` | Appendix M, §6.4 ¶11 | Dart `geo_salah_core` · Python `lab` |
| `bench_request.v1`, `bench_failure.v1` | §6.1, §9.4, §15 D29 (engine bench JSONL contract) | Python `lab` · Dart `geo_salah_core` bench CLI (S05, extended S06) |
| `benchmark_cities.v1` | Appendix H, §15 D30 (`lab/benchmarks/cities.v1.json`) | Python `lab` |
| `lab_reference.v1` | §9.4, ADR-019 (one line of the frozen reference JSONL) | Python `lab` |
| `discrepancy_report.v1` | §6.7, §9.4 | Python `lab` |
| `pipeline_manifest.v1` | §17.6 (inputs, tools and outputs by sha256) | Python `lab` · Python `data-pipelines` · Go `tools/gsctl/internal/schema/pipeline` (S10, §15 D69) |
| `tz_transition_oracle.v1` | §13 S10, §15 D67 (DST transition oracle) | Python `data-pipelines` (producer); `dm_civil_time` tests read it field by field (test-only consumer) |
| `hijri_package.v1` | §9.5 | Dart `dm_hijri` (Python pipeline models with the `hijri` pipeline) |
| `gazetteer_package.v1` | §9.5 | Dart `dm_contracts` (Python pipeline models in S12) |
| `athan_audio_manifest.v1` | §9.5 | Dart `dm_contracts` |
| `tz_polygons.v1.ksy`, `country_polygons.v1.ksy` | §9.5 | Dart readers in S11 |

Each language models the schemas it produces or consumes (§15 D24).

## Wire conventions (§15 D21)

- Optional members are **absent**, never `null`. The exception is `prayer_profile.v1`, where Appendix A defines nullable members; those are always written, as `null` when unset.
- Enum values are `SCREAMING_SNAKE_CASE` unless the source section fixes another form: Appendix A rule types and rounding modes, Appendix G sky phases, Appendix L platform and counters, and §9.1/§9.5 lowercase values keep their documented spelling.
- Instants are UTC epoch milliseconds (`*UtcMs`); calendar days are `YYYY-MM-DD` strings (REQ-TIME-001).

## Fixtures

`fixtures/<schema>/valid/*.json` must validate. They are in canonical form: decoding and re-encoding through every model reproduces them exactly.

`fixtures/<schema>/invalid/*.json` must be rejected. Each is a valid fixture with exactly one mutation. When the mutation guards a requirement, the file name starts with its REQ ID, e.g. `REQ-ALM-042_pre_reminder_not_allowed.json`.

Fixture values are shape test data, not prayer profiles: they use the user-assigned country code `ZZ`, `zz.fixture.*` profile ids and `example.invalid` URLs, and they are never loaded as data (§0.2 rule 1). TUF fixtures carry the dev root public keys with placeholder signatures; signed test vectors arrive with `gsctl` in S09.

## Checks

```bash
schemas/tools/validate_fixtures.sh          # ajv-cli 5.0.0 + ajv-formats 3.0.1: valid accepted, invalid rejected, profiles/*/*.yaml valid
uvx check-jsonschema==0.38.2 --check-metaschema schemas/*.schema.json
node schemas/tools/check_ksy.cjs            # kaitai-struct-compiler 0.11.0 compiles the binary layouts
```

`ci-schemas` runs all three. The round-trips run with each language's tests: `melos run ci` (Dart), `./gradlew :athan-core:testDebugUnitTest` (Kotlin), `swift test` in `apps/mobile/ios/AthanKit` (Swift), and `go test ./...` in each Go module.
