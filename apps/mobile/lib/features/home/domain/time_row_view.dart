import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// One event of a day as the screens show it: the local wall time derived
/// with the pinned TZDB at the edge (REQ-TIME-020), never stored.
@immutable
final class TimeRowView {
  /// The row of [event].
  const new({
    required this.event,
    required this.localTime,
    required this.dayOffset,
    required this.confidence,
    required this.displayedUtcMs,
  });

  /// The event.
  final PrayerEvent event;

  /// `HH:mm` in Western digits, or `null` when the event has no time.
  final String? localTime;

  /// −1, 0 or +1 against the prayer day ("+1" after midnight, US-04).
  final int dayOffset;

  /// The label the engine gave (REQ-DOM-050); shown on every row (REQ-UX-001).
  final ConfidenceLabel confidence;

  /// The displayed instant, `null` for a `NoEvent`.
  final int? displayedUtcMs;

  @override
  bool operator ==(Object other) =>
      other is TimeRowView &&
      other.event == event &&
      other.localTime == localTime &&
      other.dayOffset == dayOffset &&
      other.confidence == confidence &&
      other.displayedUtcMs == displayedUtcMs;

  @override
  int get hashCode =>
      Object.hash(event, localTime, dayOffset, confidence, displayedUtcMs);
}
