import 'package:freezed_annotation/freezed_annotation.dart';

part 'religious_approval_document.freezed.dart';
part 'religious_approval_document.g.dart';

/// Signed religious approval (ADR-008).
@freezed
abstract class ReligiousApprovalDocument with _$ReligiousApprovalDocument {
  /// Creates a [ReligiousApprovalDocument].
  const factory({
    /// Reviewer.
    required String reviewer,

    /// Reviewer qualification.
    required String qualification,

    /// Approval date, `YYYY-MM-DD`.
    required String date,

    /// What was approved, e.g. `rules`, `rounding`.
    required List<String> scope,
  }) = _ReligiousApprovalDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$ReligiousApprovalDocumentFromJson(json);
}
