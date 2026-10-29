import 'package:daily_muslim/features/qibla/domain/shadow_times.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The Qibla shadow times of a place (§6.6, REQ-DOM-031) with the §15 D91
/// presentation defaults: the local day from the pinned TZDB, then the
/// following days up to eight in all when it has none; 1° windows;
/// moments with a Sun above 75° or a window under 2 min flagged as hard to
/// use; nothing within 1 km of the Kaaba. Presentation choices, not
/// religious values. Pure.
final class FindShadowTimes {
  /// Reads local days and times with [_tzdb].
  const new(this._tzdb);

  final PinnedTzDatabase _tzdb;

  static const double _toleranceDeg = 1;
  static const int _searchDays = 8;
  static const double _highSunDeg = 75;
  static const int _briefWindowMs = 2 * 60000;
  static const double _nearKaabaM = 1000;

  /// The shadow times for [observer] as of [nowUtcMs].
  ShadowTimes call(Observer observer, {required int nowUtcMs}) {
    if (const CalculateQibla()(observer).distanceM < _nearKaabaM) {
      return const ShadowTimesNearKaaba();
    }
    final zoneId = observer.zoneId;
    final today = _tzdb.localDateTimeOf(zoneId, nowUtcMs).date;
    for (var offset = 0; offset < _searchDays; offset++) {
      final date = today.plusDays(offset);
      final from = _tzdb.startOfDayUtcMs(zoneId, date);
      final to = _tzdb.startOfDayUtcMs(zoneId, date.plusDays(1));
      if (from == null || to == null) continue;
      final alignments = const FindQiblaSunAlignments()(
        observer: observer,
        fromUtcMs: from,
        toUtcMs: to,
        toleranceDeg: _toleranceDeg,
      );
      if (alignments.isNotEmpty) {
        return ShadowTimesFound(
          date: date,
          isToday: offset == 0,
          times: [
            for (final alignment in alignments)
              _time(alignment, zoneId, nowUtcMs),
          ],
        );
      }
    }
    return const ShadowTimesNone();
  }

  ShadowTime _time(QiblaSunAlignment alignment, String zoneId, int nowUtcMs) {
    final windowMs = alignment.windowEndUtcMs - alignment.windowStartUtcMs;
    return ShadowTime(
      kind: alignment.kind,
      localTime: _hhmm(alignment.utcMs, zoneId),
      windowStart: _hhmm(alignment.windowStartUtcMs, zoneId),
      windowEnd: _hhmm(alignment.windowEndUtcMs, zoneId),
      hardToUse: alignment.sunAltitudeDeg >= _highSunDeg
          ? ShadowDifficulty.highSun
          : windowMs < _briefWindowMs
          ? ShadowDifficulty.briefWindow
          : null,
      passed: alignment.windowEndUtcMs < nowUtcMs,
    );
  }

  String _hhmm(int utcMs, String zoneId) {
    final local = _tzdb.localDateTimeOf(zoneId, utcMs);
    return '${_two(local.hour)}:${_two(local.minute)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
