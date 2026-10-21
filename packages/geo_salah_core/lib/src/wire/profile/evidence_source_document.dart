import 'package:freezed_annotation/freezed_annotation.dart';

part 'evidence_source_document.freezed.dart';
part 'evidence_source_document.g.dart';

/// One evidence source.
@freezed
abstract class EvidenceSourceDocument with _$EvidenceSourceDocument {
  /// Creates a [EvidenceSourceDocument].
  const factory({
    /// Title.
    required String title,

    /// URL.
    required String url,

    /// Retrieval date, `YYYY-MM-DD`.
    required String retrievedOn,

    /// SHA-256 of the retrieved document.
    required String sha256,
  }) = _EvidenceSourceDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$EvidenceSourceDocumentFromJson(json);
}
