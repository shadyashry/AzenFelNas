import 'package:json_annotation/json_annotation.dart';

/// Per-event rounding mode (ADR-005).
@JsonEnum()
enum RoundingModeCode {
  /// Round up to the minute.
  ceil,

  /// Round down to the minute.
  floor,

  /// Round to the nearest minute.
  nearest,
}
