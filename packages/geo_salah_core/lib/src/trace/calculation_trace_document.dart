import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/trace_inputs_document.dart';
import 'package:geo_salah_core/src/trace/trace_provenance_document.dart';
import 'package:geo_salah_core/src/trace/trace_time_document.dart';

part 'calculation_trace_document.freezed.dart';
part 'calculation_trace_document.g.dart';

/// Wire form of `calculation_trace.v1` (Appendix M): a serialised day result
/// with provenance, per-event detail and the inputs of its Calculation ID.
@freezed
abstract class CalculationTraceDocument with _$CalculationTraceDocument {
  /// Creates a [CalculationTraceDocument].
  const factory({
    /// Schema version; 1.
    required int schemaVersion,

    /// `GS-` + 16 base32 characters (§6.4 ¶11).
    required String calculationId,

    /// Prayer day, `YYYY-MM-DD`.
    required String day,

    /// Calculation inputs.
    required TraceInputsDocument inputs,

    /// Provenance.
    required TraceProvenanceDocument provenance,

    /// Events of the day.
    required List<TraceTimeDocument> times,
  }) = _CalculationTraceDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$CalculationTraceDocumentFromJson(json);
}
