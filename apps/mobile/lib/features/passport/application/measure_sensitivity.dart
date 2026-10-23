import 'dart:math' as math;

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The Passport sensitivity line (§6.7 perturbation, US-08): how much each
/// raw instant moves when the observer moves 1 km north, south, east or
/// west, the largest of the four in ms.
///
/// Four extra `CalculateDay` runs with the same profile, day, zone and
/// Hijri state. An event without a time on the base day or on a perturbed
/// day, or a perturbed day that fails, gets no entry. Pure.
final class MeasureSensitivity {
  /// The use case over [_tzdb].
  const new(this._tzdb);

  final TzDatabase _tzdb;

  static const CalculateDay _calculate = CalculateDay();

  /// The perturbation distance, metres (§6.7: ±1 km).
  static const double stepM = 1000;

  /// Metres per degree of latitude on the mean sphere (R = 6 371 008.8 m);
  /// the step is a few hundred metres at most off on the ellipsoid, far
  /// below what the line rounds to.
  static const double metresPerDegree = 6371008.8 * math.pi / 180;

  /// Per event, the largest `|Δ rawUtcMs|` over the four perturbations.
  Map<PrayerEvent, int> call({
    required Observer observer,
    required PrayerProfile profile,
    required DayResult base,
    required HijriState hijri,
  }) {
    const dLat = stepM / metresPerDegree;
    final cosLat = math.cos(observer.latitudeDeg * math.pi / 180);
    final dLon = cosLat < 1e-6 ? 180.0 : math.min<double>(180, dLat / cosLat);
    final raw = {
      for (final time in base.times)
        if (time.rawUtcMs case final int ms) time.event: ms,
    };
    final worst = <PrayerEvent, int>{};
    final missing = <PrayerEvent>{};
    for (final (lat, lon) in [
      (dLat, 0.0),
      (-dLat, 0.0),
      (0.0, dLon),
      (0.0, -dLon),
    ]) {
      final moved = _moved(observer, lat, lon);
      final day = _calculate(
        observer: moved,
        profile: profile,
        day: base.day,
        tzdb: _tzdb,
        hijri: hijri,
      );
      switch (day) {
        case Err():
          return const {};
        case Ok(:final value):
          for (final time in value.times) {
            final before = raw[time.event];
            final after = time.rawUtcMs;
            if (before == null || after == null) {
              missing.add(time.event);
              continue;
            }
            final delta = (after - before).abs();
            worst[time.event] = math.max(worst[time.event] ?? 0, delta);
          }
      }
    }
    return {
      for (final MapEntry(:key, :value) in worst.entries)
        if (!missing.contains(key)) key: value,
    };
  }

  static Observer _moved(Observer observer, double dLat, double dLon) {
    final lat = (observer.latitudeDeg + dLat).clamp(-90.0, 90.0);
    var lon = observer.longitudeDeg + dLon;
    if (lon > 180) lon -= 360;
    if (lon < -180) lon += 360;
    return Observer(
      latitudeDeg: lat,
      longitudeDeg: lon,
      zoneId: observer.zoneId,
      source: observer.source,
      horizontalAccuracyM: observer.horizontalAccuracyM,
      elevation: observer.elevation,
    );
  }
}
