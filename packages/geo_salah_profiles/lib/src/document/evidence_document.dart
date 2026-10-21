import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_profiles/src/document/evidence_source_document.dart';

part 'evidence_document.freezed.dart';
part 'evidence_document.g.dart';

/// Evidence behind a profile (ADR-008).
@freezed
abstract class EvidenceDocument with _$EvidenceDocument {
  /// Creates a [EvidenceDocument].
  const factory({
    /// Sources.
    required List<EvidenceSourceDocument> sources,

    /// Benchmark set id.
    required String benchmarkSet,

    /// Holdout report id; always written, `null` when absent.
    required String? holdoutReport,

    /// Benchmark report id; always written, `null` when absent.
    required String? benchmarkReportId,
  }) = _EvidenceDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$EvidenceDocumentFromJson(json);
}
