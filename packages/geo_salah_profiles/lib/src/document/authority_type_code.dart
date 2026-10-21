import 'package:json_annotation/json_annotation.dart';

/// Kind of authority behind a profile (ADR-007).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AuthorityTypeCode {
  /// Government authority.
  government,

  /// Recognised religious body.
  recognizedBody,

  /// Community convention.
  communityConvention,

  /// Engine default; no local authority.
  engineDefault,
}
