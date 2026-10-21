import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/observer_source.dart';
import 'package:geo_salah_core/src/model/result_flag.dart';
import 'package:geo_salah_core/src/model/tz_database.dart';

/// The flags the engine derives from a day's inputs and attaches to every
/// time of the day (§6.2 `ResultFlag`, §15 D44):
/// - `dstTransitionDay` when the zone's UTC offset at the start of the local
///   day differs from its offset at the end (one ms before the next local
///   midnight, both at the day's starting offset);
/// - `manualCoordinateResolution` when the observer is a manual place.
///
/// `nearRoundingBoundary` is per event (rounding); the other flags need
/// inputs the engine does not have yet and are set by their owning slices
/// (§15 D44). Pure and deterministic.
final class DayFlags {
  /// The flag source.
  const new();

  static const int _msPerDay = 86400000;

  /// The day-level flags of [day] for [observer], with local time from
  /// [tzdb] (REQ-TIME-020).
  Set<ResultFlag> of({
    required Observer observer,
    required CivilDate day,
    required TzDatabase tzdb,
  }) => {
    if (_hasOffsetTransition(day, observer.zoneId, tzdb))
      ResultFlag.dstTransitionDay,
    if (observer.source == ObserverSource.manual)
      ResultFlag.manualCoordinateResolution,
  };

  static bool _hasOffsetTransition(
    CivilDate day,
    String zoneId,
    TzDatabase tzdb,
  ) {
    final midnightAsUtc = day.epochDay * _msPerDay;
    final startOffsetMs = tzdb.offsetSecondsAt(zoneId, midnightAsUtc) * 1000;
    final start = midnightAsUtc - startOffsetMs;
    return tzdb.offsetSecondsAt(zoneId, start) !=
        tzdb.offsetSecondsAt(zoneId, start + _msPerDay - 1);
  }
}
