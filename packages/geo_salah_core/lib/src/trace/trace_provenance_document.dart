import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/hijri_confidence_code.dart';

part 'trace_provenance_document.freezed.dart';
part 'trace_provenance_document.g.dart';

/// Versions and hash that identify how a day was calculated (§6.2
/// `Provenance`).
@freezed
abstract class TraceProvenanceDocument with _$TraceProvenanceDocument {
  /// Creates a [TraceProvenanceDocument].
  const factory({
    /// Engine version.
    required String engineVersion,

    /// ΔT model id.
    required String deltaTModel,

    /// Prayer profile id.
    required String profileId,

    /// Prayer profile version.
    required String profileVersion,

    /// Pinned TZDB version.
    required String tzdbVersion,

    /// Lowercase hex SHA-256 of the canonical inputs.
    required String inputsHash,

    /// Hijri confidence of the day.
    required HijriConfidenceCode hijriConfidence,
  }) = _TraceProvenanceDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TraceProvenanceDocumentFromJson(json);
}
