import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';

/// The sites 1 km north, south, east and west of a site on the WGS84
/// ellipsoid: the runtime ±1 km N/E perturbation of §6.7.
///
/// A metre north is `1 / M(φ)` radians of latitude and a metre east
/// `1 / (N(φ)·cos φ)` radians of longitude, with `M` and `N` the meridional
/// and prime-vertical radii of curvature. A shifted latitude beyond ±90° is
/// left out; a shifted longitude is wrapped into [−180°, 180°]. Geodesy
/// only, no religious value. Pure and deterministic.
final class PerturbedSites {
  /// The perturbation.
  const new();

  /// The shift, metres (§6.7).
  static const double distanceM = 1000;

  static const double _semiMajorAxisM = 6378137; // WGS84 a
  static const double _flattening = 1 / 298.257223563; // WGS84 f
  static const double _eccentricitySquared = _flattening * (2 - _flattening);

  /// The perturbed sites of [site]: north, south, east, west.
  List<TopocentricSite> of(TopocentricSite site) {
    final sinPhi = site.sinLatitude;
    final w = 1 - _eccentricitySquared * sinPhi * sinPhi;
    final meridional =
        _semiMajorAxisM * (1 - _eccentricitySquared) / (w * math.sqrt(w));
    final primeVertical = _semiMajorAxisM / math.sqrt(w);
    final dLatDeg = radToDeg(distanceM / meridional);
    final dLonDeg = radToDeg(
      distanceM / (primeVertical * site.cosLatitude),
    );
    return [
      for (final lat in [
        site.latitudeDeg + dLatDeg,
        site.latitudeDeg - dLatDeg,
      ])
        if (lat.abs() <= 90)
          TopocentricSite.of(
            latitudeDeg: lat,
            longitudeDeg: site.longitudeDeg,
          ),
      for (final lon in [
        site.longitudeDeg + dLonDeg,
        site.longitudeDeg - dLonDeg,
      ])
        TopocentricSite.of(
          latitudeDeg: site.latitudeDeg,
          longitudeDeg: _wrap(lon),
        ),
    ];
  }

  static double _wrap(double lonDeg) => switch (lonDeg) {
    > 180 => lonDeg - 360,
    < -180 => lonDeg + 360,
    _ => lonDeg,
  };
}
