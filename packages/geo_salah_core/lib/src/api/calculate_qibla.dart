import 'package:geo_salah_core/src/astro/geodesic.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/qibla_result.dart';

/// `GeoSalahEngine.calculateQibla` (§6.3): the Qibla of an observer (§6.6,
/// REQ-DOM-030), the initial azimuth of the shortest WGS84 geodesic to the
/// [Kaaba] (Karney's algorithm, accurate to round-off everywhere, nearly
/// antipodal points included), relative to true north.
///
/// The bearing at the Kaaba itself is undefined; it is reported as `0` with
/// distance `0`. No I/O, clock or randomness: equal arguments give equal
/// results.
final class CalculateQibla {
  /// The use case.
  const new();

  /// The [QiblaResult] from [observer]'s WGS84 coordinates.
  QiblaResult call(Observer observer) {
    final solution = Geodesic.wgs84.inverse(
      observer.latitudeDeg,
      observer.longitudeDeg,
      Kaaba.latitudeDeg,
      Kaaba.longitudeDeg,
    );
    final azimuth = solution.distanceM == 0 ? 0.0 : solution.azimuth1Deg;
    final bearing = azimuth < 0 ? azimuth + 360 : azimuth;
    return QiblaResult(
      bearingDeg: bearing >= 360 ? 0 : bearing,
      distanceM: solution.distanceM,
      kaabaRefVersion: Kaaba.refVersion,
    );
  }
}
