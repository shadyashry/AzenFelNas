import 'package:json_annotation/json_annotation.dart';

/// Base event of an interval rule.
@JsonEnum()
enum IntervalBaseCode {
  /// Maghrib (base of `intervalAfter`).
  maghrib,

  /// Fajr (base of `intervalBefore`).
  fajr,
}
