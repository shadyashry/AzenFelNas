/// Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState,
/// provenance and PrayerProfile value types (DESIGN.md §6).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `calculation_trace.v1` wire model and shared wire codes
/// since S02 and the `TzDatabase` port the engine consumes (S04). Since S05 it
/// exposes the §6.2 domain types, the `CalculateDay` use case (Sunrise,
/// Dhuhr and Maghrib from the transit and horizon rules), the Calculation ID
/// and the trace writer. The astronomical core (`src/astro`, `src/solver`)
/// and the lab bench (`src/bench`, `bin/bench.dart`) stay internal.
library;

export 'package:geo_salah_core/src/api/calculate_day.dart';
export 'package:geo_salah_core/src/api/engine_version.dart';
export 'package:geo_salah_core/src/model/adjustment_kind.dart';
export 'package:geo_salah_core/src/model/adjustment_step.dart';
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
export 'package:geo_salah_core/src/model/provenance.dart';
export 'package:geo_salah_core/src/model/result_flag.dart';
export 'package:geo_salah_core/src/model/tz_database.dart';
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
