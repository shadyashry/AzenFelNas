/// Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState,
/// provenance and PrayerProfile value types (DESIGN.md §6).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `calculation_trace.v1` wire model and shared wire codes
/// since S02 and the `TzDatabase` port the engine consumes (S04). Since S05 it
/// exposes the §6.2 domain types, the Calculation ID and the trace writer;
/// since S06 the `CalculateDay` and `CalculateRange` use cases for every
/// event (altitude, transit, shadow-factor, horizon and interval rules,
/// per-event rounding, flags, the ordering guard and the confidence
/// mapping); since S07 the full §6.2 `PrayerProfile`, its `prayer_profile.v1`
/// wire model and `PrayerProfileMapper` (moved here from `geo_salah_profiles`
/// so the engine bench and the app share one mapping, §15 D51); since S08
/// Ramadan rule replacement and the high-latitude chain with typed
/// fallbacks (§6.4 ¶6–¶7); since S15 `ComputeSolarState` and the Appendix G
/// `SkyPhase` bands for the Sky theme; since S18 `CalculateQibla` (Karney
/// geodesic, §6.6). The astronomical core (`src/astro`, `src/solver`), the rule
/// solvers and policies (`src/rules`, `src/policy`) and the lab bench
/// (`src/bench`, `bin/bench.dart`) stay internal.
library;

export 'package:geo_salah_core/src/api/calculate_day.dart';
export 'package:geo_salah_core/src/api/calculate_qibla.dart';
export 'package:geo_salah_core/src/api/calculate_range.dart';
export 'package:geo_salah_core/src/api/compute_solar_state.dart';
export 'package:geo_salah_core/src/api/engine_version.dart';
export 'package:geo_salah_core/src/model/adjustment_kind.dart';
export 'package:geo_salah_core/src/model/adjustment_step.dart';
export 'package:geo_salah_core/src/model/authority_type.dart';
export 'package:geo_salah_core/src/model/confidence_label.dart';
export 'package:geo_salah_core/src/model/day_result.dart';
export 'package:geo_salah_core/src/model/elevation_datum.dart';
export 'package:geo_salah_core/src/model/elevation_sample.dart';
export 'package:geo_salah_core/src/model/elevation_source.dart';
export 'package:geo_salah_core/src/model/engine_failure.dart';
export 'package:geo_salah_core/src/model/event_origin.dart';
export 'package:geo_salah_core/src/model/event_rule.dart';
export 'package:geo_salah_core/src/model/high_latitude_method.dart';
export 'package:geo_salah_core/src/model/hijri_confidence.dart';
export 'package:geo_salah_core/src/model/hijri_date.dart';
export 'package:geo_salah_core/src/model/hijri_state.dart';
export 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
export 'package:geo_salah_core/src/model/no_event_reason.dart';
export 'package:geo_salah_core/src/model/observer.dart';
export 'package:geo_salah_core/src/model/observer_source.dart';
export 'package:geo_salah_core/src/model/prayer_event.dart';
export 'package:geo_salah_core/src/model/prayer_profile.dart';
export 'package:geo_salah_core/src/model/prayer_time.dart';
export 'package:geo_salah_core/src/model/profile_status.dart';
export 'package:geo_salah_core/src/model/provenance.dart';
export 'package:geo_salah_core/src/model/qibla_result.dart';
export 'package:geo_salah_core/src/model/reference_mode.dart';
export 'package:geo_salah_core/src/model/reference_point.dart';
export 'package:geo_salah_core/src/model/result_flag.dart';
export 'package:geo_salah_core/src/model/rounding_mode.dart';
export 'package:geo_salah_core/src/model/sky_phase.dart';
export 'package:geo_salah_core/src/model/solar_state.dart';
export 'package:geo_salah_core/src/model/tz_database.dart';
export 'package:geo_salah_core/src/profile/prayer_profile_mapper.dart';
export 'package:geo_salah_core/src/trace/adjustment_kind_code.dart';
export 'package:geo_salah_core/src/trace/adjustment_step_document.dart';
export 'package:geo_salah_core/src/trace/calculation_id.dart';
export 'package:geo_salah_core/src/trace/calculation_inputs.dart';
export 'package:geo_salah_core/src/trace/calculation_trace_document.dart';
export 'package:geo_salah_core/src/trace/calculation_trace_writer.dart';
export 'package:geo_salah_core/src/trace/confidence_label_document.dart';
export 'package:geo_salah_core/src/trace/event_origin_document.dart';
export 'package:geo_salah_core/src/trace/hijri_confidence_code.dart';
export 'package:geo_salah_core/src/trace/hijri_date_document.dart';
export 'package:geo_salah_core/src/trace/no_event_reason_code.dart';
export 'package:geo_salah_core/src/trace/result_flag_code.dart';
export 'package:geo_salah_core/src/trace/trace_hijri_inputs_document.dart';
export 'package:geo_salah_core/src/trace/trace_inputs_document.dart';
export 'package:geo_salah_core/src/trace/trace_provenance_document.dart';
export 'package:geo_salah_core/src/trace/trace_time_document.dart';
export 'package:geo_salah_core/src/wire/high_latitude_method_document.dart';
export 'package:geo_salah_core/src/wire/prayer_event_code.dart';
export 'package:geo_salah_core/src/wire/profile/accuracy_approval_document.dart';
export 'package:geo_salah_core/src/wire/profile/adjustments_document.dart';
export 'package:geo_salah_core/src/wire/profile/approvals_document.dart';
export 'package:geo_salah_core/src/wire/profile/authority_document.dart';
export 'package:geo_salah_core/src/wire/profile/authority_type_code.dart';
export 'package:geo_salah_core/src/wire/profile/compatibility_document.dart';
export 'package:geo_salah_core/src/wire/profile/elevation_policy_code.dart';
export 'package:geo_salah_core/src/wire/profile/evidence_document.dart';
export 'package:geo_salah_core/src/wire/profile/evidence_source_document.dart';
export 'package:geo_salah_core/src/wire/profile/high_latitude_document.dart';
export 'package:geo_salah_core/src/wire/profile/horizon_document.dart';
export 'package:geo_salah_core/src/wire/profile/interval_base_code.dart';
export 'package:geo_salah_core/src/wire/profile/prayer_profile_document.dart';
export 'package:geo_salah_core/src/wire/profile/profile_scope_document.dart';
export 'package:geo_salah_core/src/wire/profile/profile_status_code.dart';
export 'package:geo_salah_core/src/wire/profile/reference_mode_code.dart';
export 'package:geo_salah_core/src/wire/profile/reference_point_document.dart';
export 'package:geo_salah_core/src/wire/profile/religious_approval_document.dart';
export 'package:geo_salah_core/src/wire/profile/rounding_mode_code.dart';
export 'package:geo_salah_core/src/wire/profile/rule_document.dart';
export 'package:geo_salah_core/src/wire/profile/rules_document.dart';
