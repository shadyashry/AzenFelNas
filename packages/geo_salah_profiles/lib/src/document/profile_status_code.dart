import 'package:json_annotation/json_annotation.dart';

/// Profile lifecycle status (§6.2 `ProfileStatus`).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ProfileStatusCode {
  /// Illustrative data; `dev`/`lab` only.
  draftUnverified,

  /// Awaiting approvals.
  candidate,

  /// Religious and accuracy approvals present.
  approved,

  /// No longer in use.
  retired,
}
