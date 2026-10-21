/// Geo Salah Engine: ephemeris, solver, rules, rounding, Qibla, SolarState,
/// provenance and PrayerProfile value types (DESIGN.md §6).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Holds the `calculation_trace.v1` wire model and shared wire codes
/// since S02; the engine arrives in S04.
library;

export 'package:geo_salah_core/src/trace/adjustment_kind_code.dart';
export 'package:geo_salah_core/src/trace/adjustment_step_document.dart';
export 'package:geo_salah_core/src/trace/calculation_trace_document.dart';
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
