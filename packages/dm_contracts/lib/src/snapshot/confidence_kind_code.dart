import 'package:json_annotation/json_annotation.dart';

/// Confidence label kind as shown by widgets.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ConfidenceKindCode {
  /// Calculated.
  calculated,

  /// Authority aligned.
  authorityAligned,

  /// Verified.
  verified,

  /// Estimated.
  estimated,

  /// Observed.
  observed,

  /// Unknown.
  unknown,
}
