import 'package:json_annotation/json_annotation.dart';

/// Wire form of `AdjustmentKind` (§6.2).
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum AdjustmentKindCode {
  /// Profile per-event minute offset.
  perEventOffset,

  /// Ramadan rule replaced the event rule.
  ramadanRuleReplacement,

  /// High-latitude method applied.
  highLatitudeFallback,

  /// Per-event rounding, applied last.
  rounding,
}
