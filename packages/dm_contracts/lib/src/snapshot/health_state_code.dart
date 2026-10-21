import 'package:json_annotation/json_annotation.dart';

/// Athan Health state (§8.3).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum HealthStateCode {
  /// Ready.
  ready,

  /// Limited.
  limited,

  /// Not ready.
  notReady,

  /// Unknown.
  unknown,
}
