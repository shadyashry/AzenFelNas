import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/fasting_day.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Home's Ramadan card (US-23, REQ-RAM-001, §15 D88). The day it concerns is
/// today until today's Maghrib, then tomorrow, so the card shows the next
/// fast after iftar. Which events bound the fast is presentation: Fajr to
/// Maghrib as the profile computed them, Imsak shown when the profile has it;
/// nothing is offset or invented here (§0.2 rule 1).
final class BuildFastingDay {
  /// The builder.
  const new();

  /// The card for [views] and their Hijri states [hijri] (index for index,
  /// from the local today) at [nowUtcMs].
  FastingDay call({
    required List<DayView> views,
    required List<HijriState> hijri,
    required int nowUtcMs,
  }) {
    final index = _dayIndex(views, nowUtcMs);
    if (index >= hijri.length || !hijri[index].ramadanAtDawn) {
      return const NotFasting();
    }
    final ramadan = RamadanDate(
      day: hijri[index].dateAtDawn.day,
      confidence: hijri[index].confidence,
    );
    final rows = views[index].rows;
    final begins = _timed(rows, PrayerEvent.fajr);
    final ends = _timed(rows, PrayerEvent.maghrib);
    if (begins == null || ends == null) return FastingUnknown(ramadan);
    return FastingWindow(
      ramadan: ramadan,
      begins: begins,
      ends: ends,
      imsak: _timed(rows, PrayerEvent.imsak),
    );
  }

  static int _dayIndex(List<DayView> views, int nowUtcMs) {
    if (views.length < 2) return 0;
    final maghrib = _timed(views.first.rows, PrayerEvent.maghrib);
    final passed = switch (maghrib?.displayedUtcMs) {
      final int at => at <= nowUtcMs,
      null => false,
    };
    return passed ? 1 : 0;
  }

  static TimeRowView? _timed(List<TimeRowView> rows, PrayerEvent event) {
    for (final row in rows) {
      if (row.event == event && row.displayedUtcMs != null) return row;
    }
    return null;
  }
}
