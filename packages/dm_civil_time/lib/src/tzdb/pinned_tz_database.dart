import 'package:dm_civil_time/src/tzdb/local_date_time.dart';
import 'package:dm_civil_time/src/tzdb/zone_rules.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// The app's pinned TZDB (§6.2 `TzDatabase`, REQ-TIME-020): the active
/// `tzdata` package, never the OS database. Built by `ReadTzfDatabase`.
///
/// Every method is pure and deterministic: equal payload bytes and version
/// give equal answers on every platform. A `zoneId` outside [zoneIds] is a
/// caller error (the resolver only produces zones of the active database)
/// and throws [ArgumentError]; so does a date outside `CivilDate`'s range.
@immutable
final class PinnedTzDatabase implements TzDatabase {
  /// Wraps validated [zones]; use `ReadTzfDatabase` to build one.
  new internal({
    required this.version,
    required Map<String, ZoneRules> zones,
  }) : _zones = Map.unmodifiable(zones);

  static const int _msPerDay = LocalDateTime.millisecondsPerDay;

  final Map<String, ZoneRules> _zones;

  /// The IANA release of the data, e.g. `2026e` (`Provenance.tzdbVersion`).
  @override
  final String version;

  /// Every zone name the database holds (links included), unordered.
  Iterable<String> get zoneIds => _zones.keys;

  @override
  int offsetSecondsAt(String zoneId, int utcMs) =>
      _rules(zoneId).offsetAt(utcMs);

  /// The wall-clock reading of [utcMs] in [zoneId].
  LocalDateTime localDateTimeOf(String zoneId, int utcMs) {
    final offset = _rules(zoneId).offsetAt(utcMs);
    final localMs = utcMs + offset * 1000;
    final epochDay = _floorDiv(localMs, _msPerDay);
    return LocalDateTime(
      date: CivilDate.fromEpochDay(epochDay),
      millisecondOfDay: localMs - epochDay * _msPerDay,
      offsetSeconds: offset,
    );
  }

  /// The UTC instant of the local reading [date] + [millisecondOfDay]
  /// (`0 ≤ millisecondOfDay < 86 400 000`), resolved as PEP 495 `fold = 0`
  /// (§15 D67): a reading that occurs twice (overlap) gives the earlier
  /// instant; a reading that does not occur (gap) is moved forward by the
  /// gap's length.
  int utcMsOfLocal(String zoneId, CivilDate date, int millisecondOfDay) {
    RangeError.checkValueInInterval(
      millisecondOfDay,
      0,
      _msPerDay - 1,
      'millisecondOfDay',
    );
    final localMs = date.epochDay * _msPerDay + millisecondOfDay;
    return localMs - _rules(zoneId).offsetForLocal(localMs) * 1000;
  }

  /// The first instant whose local date in [zoneId] is [date], or `null`
  /// when the zone skipped that calendar day (e.g. `Pacific/Apia`
  /// 2011-12-30). When midnight falls in a gap, the day starts at the
  /// transition.
  int? startOfDayUtcMs(String zoneId, CivilDate date) {
    final rules = _rules(zoneId);
    final candidate = utcMsOfLocal(zoneId, date, 0);
    final reading = localDateTimeOf(zoneId, candidate);
    if (reading.date == date && reading.millisecondOfDay == 0) {
      return candidate;
    }
    final transition = rules.transitionAtOrBefore(candidate);
    if (transition == null) return null;
    return localDateTimeOf(zoneId, transition).date == date ? transition : null;
  }

  ZoneRules _rules(String zoneId) =>
      _zones[zoneId] ??
      (throw ArgumentError.value(zoneId, 'zoneId', 'not in TZDB $version'));

  static int _floorDiv(int a, int b) {
    final q = a ~/ b;
    return (a % b != 0 && (a < 0) != (b < 0)) ? q - 1 : q;
  }
}
