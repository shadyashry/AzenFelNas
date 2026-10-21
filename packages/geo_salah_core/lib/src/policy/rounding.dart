import 'package:geo_salah_core/src/model/rounding_mode.dart';
import 'package:meta/meta.dart';

/// One event's displayed instant (§6.4 ¶9, ADR-005).
@immutable
final class Rounded {
  /// [displayedUtcMs], with [nearBoundary] when the input was within
  /// [PerEventRounding.nearBoundaryMs] of a minute boundary.
  const new({required this.displayedUtcMs, required this.nearBoundary});

  /// The displayed instant, on a local minute boundary.
  final int displayedUtcMs;

  /// Whether `nearRoundingBoundary` applies.
  final bool nearBoundary;

  @override
  bool operator ==(Object other) =>
      other is Rounded &&
      other.displayedUtcMs == displayedUtcMs &&
      other.nearBoundary == nearBoundary;

  @override
  int get hashCode => Object.hash(displayedUtcMs, nearBoundary);

  @override
  String toString() => 'Rounded($displayedUtcMs, near: $nearBoundary)';
}

/// Per-event rounding to the displayed minute (§6.4 ¶9, ADR-005,
/// REQ-DOM-003): the last step of an event, applied once, whose output feeds
/// no other calculation.
///
/// Minutes are **local** minutes: the instant is shifted by the zone's UTC
/// offset at that instant, rounded, and shifted back, so a zone whose offset
/// is not a whole number of minutes still shows whole local minutes (§15
/// D43). The mode is profile data (§0.2 rule 1). Pure and deterministic.
final class PerEventRounding {
  /// The rounding step.
  const new();

  static const int _minuteMs = 60000;

  /// ADR-005: `nearRoundingBoundary` when `|instant − minute boundary|` is
  /// below this, milliseconds.
  static const int nearBoundaryMs = 500;

  /// [utcMs] rounded by [mode] in a zone [offsetSeconds] ahead of UTC.
  Rounded round(
    int utcMs,
    RoundingMode mode, {
    required int offsetSeconds,
  }) {
    final offsetMs = offsetSeconds * 1000;
    final local = utcMs + offsetMs;
    final intoMinute = local % _minuteMs; // in [0, 60000)
    final down = local - intoMinute;
    final roundedLocal = switch (mode) {
      RoundingMode.ceil => intoMinute == 0 ? local : down + _minuteMs,
      RoundingMode.floor => down,
      RoundingMode.nearest =>
        intoMinute < _minuteMs ~/ 2 ? down : down + _minuteMs,
    };
    return Rounded(
      displayedUtcMs: roundedLocal - offsetMs,
      nearBoundary:
          intoMinute < nearBoundaryMs ||
          _minuteMs - intoMinute < nearBoundaryMs,
    );
  }
}
