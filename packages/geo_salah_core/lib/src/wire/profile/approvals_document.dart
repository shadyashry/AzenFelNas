import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/wire/profile/accuracy_approval_document.dart';
import 'package:geo_salah_core/src/wire/profile/religious_approval_document.dart';

part 'approvals_document.freezed.dart';
part 'approvals_document.g.dart';

/// Approvals; both always written, `null` when missing.
@freezed
abstract class ApprovalsDocument with _$ApprovalsDocument {
  /// Creates a [ApprovalsDocument].
  const factory({
    /// Religious approval.
    @JsonKey(includeIfNull: true) required ReligiousApprovalDocument? religious,

    /// Accuracy approval.
    @JsonKey(includeIfNull: true) required AccuracyApprovalDocument? accuracy,
  }) = _ApprovalsDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$ApprovalsDocumentFromJson(json);
}
