import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Derives the local wall times of engine days for display (REQ-TIME-020):
/// each displayed instant is read in the context's zone with the app's
/// pinned TZDB. Pure.
final class BuildDayViews {
  /// Reads local time with [_tzdb].
  const new(this._tzdb);

  final PinnedTzDatabase _tzdb;

  /// The views of [days] in [zoneId].
  List<DayView> call(List<DayResult> days, String zoneId) => [
    for (final day in days)
      DayView(
        date: day.day,
        calculationId: day.calculationId,
        rows: [for (final time in day.times) _row(time, zoneId)],
      ),
  ];

  /// `HH:mm` of [utcMs] in [zoneId].
  String localTime(int utcMs, String zoneId) {
    final local = _tzdb.localDateTimeOf(zoneId, utcMs);
    final minutes = local.millisecondOfDay ~/ 60000;
    return '${_two(minutes ~/ 60)}:${_two(minutes % 60)}';
  }

  TimeRowView _row(PrayerTime time, String zoneId) {
    final displayed = time.displayedUtcMs;
    return TimeRowView(
      event: time.event,
      localTime: displayed == null ? null : localTime(displayed, zoneId),
      dayOffset: time.dayOffset ?? 0,
      confidence: time.confidence,
      displayedUtcMs: displayed,
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
