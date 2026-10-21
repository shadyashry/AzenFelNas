import 'package:json_annotation/json_annotation.dart';

/// Horizon elevation policy (ADR-003).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum ElevationPolicyCode {
  /// No dip.
  none,

  /// Deferred to V2.
  aboveLocalTerrain,

  /// Deferred to V2.
  authorityTable,
}
