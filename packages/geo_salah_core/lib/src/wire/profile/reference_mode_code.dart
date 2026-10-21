import 'package:json_annotation/json_annotation.dart';

/// Where the engine calculates (ADR-006).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ReferenceModeCode {
  /// At the observer's coordinate.
  exactCoordinate,

  /// At the authority's reference point.
  authorityReferencePoint,
}
