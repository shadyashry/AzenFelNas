import 'package:geo_salah_core/src/model/event_origin.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/result_flag.dart';

/// The ordering invariant on displayed instants (§6.4 ¶10, REQ-DOM-001):
/// `Imsak ≤ Fajr < Sunrise < Dhuhr < Asr < Maghrib < Isha` within a prayer
/// day.
///
/// It compares each time that has an instant with the next such time in
/// [PrayerEvent] order; events without an instant (`NoEvent`) or absent from
/// the profile are skipped. A tie is allowed between Imsak and Fajr, and
/// between two high-latitude fallbacks that both carry
/// `highLatitudeFallback` (polar fallbacks, S08); every other pair must be
/// strictly increasing (§15 D45). Pure and deterministic.
final class OrderingGuard {
  /// The guard.
  const new();

  /// The first pair of [times] that breaks the order, or `null` when it
  /// holds. [times] are in [PrayerEvent] order.
  (PrayerTime, PrayerTime)? firstViolation(List<PrayerTime> times) {
    final timed = [
      for (final time in times)
        if (time.displayedUtcMs case final int displayed) (time, displayed),
    ];
    for (var i = 1; i < timed.length; i++) {
      final (earlier, earlierMs) = timed[i - 1];
      final (later, laterMs) = timed[i];
      if (earlierMs < laterMs) continue;
      if (earlierMs == laterMs && _mayTie(earlier, later)) continue;
      return (earlier, later);
    }
    return null;
  }

  static bool _mayTie(PrayerTime a, PrayerTime b) =>
      (a.event == PrayerEvent.imsak && b.event == PrayerEvent.fajr) ||
      (_isFlaggedFallback(a) && _isFlaggedFallback(b));

  static bool _isFlaggedFallback(PrayerTime time) =>
      time.origin is Fallback &&
      time.flags.contains(ResultFlag.highLatitudeFallback);
}
