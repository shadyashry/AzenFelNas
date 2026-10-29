import 'package:geo_salah_core/src/api/calculate_qibla.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/qibla_sun_alignment.dart';
import 'package:geo_salah_core/src/qibla/qibla_sun_search.dart';

/// The moments when the Sun shows the Qibla (§6.3
/// `findQiblaSunAlignments`, §6.6, REQ-DOM-031): the sensor-free Qibla.
///
/// At an alignment the Sun's topocentric azimuth equals the [CalculateQibla]
/// bearing (face the Sun; shadows point away from the Qibla) or its
/// reciprocal (shadows point to the Qibla), with the Sun above the geometric
/// horizon. The shadow of any vertical object — a plumb line, a door frame,
/// a pole — then lies on the Qibla line, so a user can mark the direction
/// with no compass, magnetometer or camera. On the *raṣd al-qibla* days the
/// Sun passes over the Kaaba and every observer in daylight gets a
/// `sunTowardQibla` alignment at the same instant; this use case is the
/// same geometry for every day and place.
///
/// **Inputs**: the instants searched are `[fromUtcMs, toUtcMs)`, at most
/// [maxSpanMs] long (a caller passes its local day's bounds from its pinned
/// TZDB); `toleranceDeg` in `(0, maxToleranceDeg]` sizes each alignment's
/// window. Both are presentation choices, not religious values (§15 D91).
///
/// **Outputs**: the alignments in time order, possibly none (the Sun never
/// reaches the bearing in daylight, polar night). Instants are truncated to
/// 1 ms. Near the Kaaba the bearing itself carries no meaning; the caller
/// decides from `QiblaResult.distanceM` whether to offer this at all.
///
/// Throws [ArgumentError] for an empty or too long interval or a tolerance
/// out of range, and [RangeError] outside the SPA's years. Pure: no I/O,
/// clock or randomness (REQ-DOM-020).
final class FindQiblaSunAlignments {
  /// The use case.
  const new();

  /// The longest interval searched in one call: 8 days.
  static const int maxSpanMs = 8 * 24 * 3600000;

  /// The widest window tolerance, degrees.
  static const double maxToleranceDeg = 10;

  /// The alignments for [observer] in `[fromUtcMs, toUtcMs)`.
  List<QiblaSunAlignment> call({
    required Observer observer,
    required int fromUtcMs,
    required int toUtcMs,
    required double toleranceDeg,
  }) {
    if (!(fromUtcMs < toUtcMs && toUtcMs - fromUtcMs <= maxSpanMs)) {
      throw ArgumentError(
        'Interval [$fromUtcMs, $toUtcMs) is empty or longer than $maxSpanMs ms',
      );
    }
    if (!(toleranceDeg > 0 && toleranceDeg <= maxToleranceDeg)) {
      throw ArgumentError.value(
        toleranceDeg,
        'toleranceDeg',
        'not in (0, $maxToleranceDeg]',
      );
    }
    final qibla = const CalculateQibla()(observer);
    return QiblaSunSearch(
      TopocentricSite.of(
        latitudeDeg: observer.latitudeDeg,
        longitudeDeg: observer.longitudeDeg,
      ),
      qiblaBearingDeg: qibla.bearingDeg,
    ).find(fromUtcMs: fromUtcMs, toUtcMs: toUtcMs, toleranceDeg: toleranceDeg);
  }
}
