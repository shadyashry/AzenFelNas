import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The next prayer after an instant (US-04, §15 D77): the first Fajr, Dhuhr,
/// Asr, Maghrib or Isha whose displayed instant is later. Imsak and sunrise
/// are listed on Home but are not prayers.
@immutable
final class NextPrayer {
  /// [time], which belongs to `days[dayIndex]`.
  const new({required this.time, required this.dayIndex});

  /// The prayer and its instants.
  final PrayerTime time;

  /// Index of its prayer day in the schedule.
  final int dayIndex;

  /// The events that count as prayers.
  static const Set<PrayerEvent> prayers = {
    PrayerEvent.fajr,
    PrayerEvent.dhuhr,
    PrayerEvent.asr,
    PrayerEvent.maghrib,
    PrayerEvent.isha,
  };

  /// The next prayer in [days] after [nowUtcMs], or `null` when none of them
  /// has a later timed prayer.
  static NextPrayer? after(List<DayResult> days, int nowUtcMs) {
    for (var i = 0; i < days.length; i++) {
      for (final time in days[i].times) {
        final displayed = time.displayedUtcMs;
        if (prayers.contains(time.event) &&
            displayed != null &&
            displayed > nowUtcMs) {
          return NextPrayer(time: time, dayIndex: i);
        }
      }
    }
    return null;
  }

  /// Milliseconds from [nowUtcMs] to the prayer's displayed instant.
  int remainingMs(int nowUtcMs) => (time.displayedUtcMs ?? nowUtcMs) - nowUtcMs;

  @override
  bool operator ==(Object other) =>
      other is NextPrayer && other.time == time && other.dayIndex == dayIndex;

  @override
  int get hashCode => Object.hash(time, dayIndex);
}
