import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Where the day stands on Home's five-prayer arc (§15 D105), from the
/// day's displayed instants only: no time is computed here.
///
/// [progress] runs from 0 at Fajr to 1 at Isha, interpolated between the
/// two prayers around now; before Fajr it is 0 and after Isha 1, so once
/// the next prayer is the following day's Fajr the whole day reads passed
/// and Fajr is ringed. A prayer without a time (a polar day) is skipped.
@immutable
final class PrayerTimeline {
  /// A timeline with [next] ringed and [progress] passed.
  const new({required this.next, required this.progress});

  /// The timeline of [rows] when [nextPrayer] comes next, at [nowUtcMs].
  factory of({
    required List<TimeRowView> rows,
    required TimeRowView? nextPrayer,
    required int nowUtcMs,
  }) {
    final times = [
      for (final event in events)
        rows
            .where((row) => row.event == event)
            .map((row) => row.displayedUtcMs)
            .firstOrNull,
    ];
    final index = nextPrayer == null ? -1 : events.indexOf(nextPrayer.event);
    return PrayerTimeline(
      next: index < 0 ? null : index,
      progress: _progress(times, nowUtcMs),
    );
  }

  /// The arc's prayers, in day order.
  static const List<PrayerEvent> events = [
    PrayerEvent.fajr,
    PrayerEvent.dhuhr,
    PrayerEvent.asr,
    PrayerEvent.maghrib,
    PrayerEvent.isha,
  ];

  /// The index in [events] of the next prayer; `null` when it is none of
  /// them.
  final int? next;

  /// The passed share of the arc, 0 to 1.
  final double progress;

  static double _progress(List<int?> times, int now) {
    final known = [
      for (final (i, t) in times.indexed)
        if (t != null) (i, t),
    ];
    if (known.isEmpty) return 0;
    final last = events.length - 1;
    if (now < known.first.$2) return known.first.$1 / last;
    if (now >= known.last.$2) return known.last.$1 / last;
    for (var k = 0; k + 1 < known.length; k++) {
      final (i, from) = known[k];
      final (j, to) = known[k + 1];
      if (now >= from && now < to && to > from) {
        return (i + (j - i) * (now - from) / (to - from)) / last;
      }
    }
    return 0;
  }

  @override
  bool operator ==(Object other) =>
      other is PrayerTimeline &&
      other.next == next &&
      other.progress == progress;

  @override
  int get hashCode => Object.hash(next, progress);
}
