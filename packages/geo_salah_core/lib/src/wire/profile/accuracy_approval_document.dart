import 'package:freezed_annotation/freezed_annotation.dart';

part 'accuracy_approval_document.freezed.dart';
part 'accuracy_approval_document.g.dart';

/// Accuracy approval.
@freezed
abstract class AccuracyApprovalDocument with _$AccuracyApprovalDocument {
  /// Creates a [AccuracyApprovalDocument].
  const factory({
    /// Reviewer.
    required String reviewer,

    /// Approval date, `YYYY-MM-DD`.
    required String date,
  }) = _AccuracyApprovalDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$AccuracyApprovalDocumentFromJson(json);
}
