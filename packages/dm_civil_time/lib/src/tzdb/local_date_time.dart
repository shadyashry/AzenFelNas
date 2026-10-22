import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// A wall-clock reading in a zone: the civil [date], the milliseconds since
/// local midnight and the UTC offset in effect (local = UTC + offset).
///
/// It is derived from a UTC instant with the pinned TZDB and is for display
/// and day boundaries only; behaviour is driven by the UTC instant
/// (REQ-TIME-001, REQ-TIME-020).
/// Invariant: `0 ≤ millisecondOfDay < 86 400 000`.
@immutable
final class LocalDateTime {
  /// Throws [RangeError] when [millisecondOfDay] is outside one day.
  new({
    required this.date,
    required this.millisecondOfDay,
    required this.offsetSeconds,
  }) {
    RangeError.checkValueInInterval(
      millisecondOfDay,
      0,
      millisecondsPerDay - 1,
      'millisecondOfDay',
    );
  }

  /// Milliseconds in a civil day.
  static const int millisecondsPerDay = 86400000;

  /// The local calendar date.
  final CivilDate date;

  /// Milliseconds since local midnight.
  final int millisecondOfDay;

  /// UTC offset in seconds at the instant.
  final int offsetSeconds;

  /// The local hour, 0–23.
  int get hour => millisecondOfDay ~/ 3600000;

  /// The local minute of the hour, 0–59.
  int get minute => millisecondOfDay ~/ 60000 % 60;

  @override
  bool operator ==(Object other) =>
      other is LocalDateTime &&
      other.date == date &&
      other.millisecondOfDay == millisecondOfDay &&
      other.offsetSeconds == offsetSeconds;

  @override
  int get hashCode => Object.hash(date, millisecondOfDay, offsetSeconds);

  @override
  String toString() =>
      'LocalDateTime($date +${millisecondOfDay}ms, '
      'offset ${offsetSeconds}s)';
}
