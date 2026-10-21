import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:meta/meta.dart';

/// An observer's geodetic position, with the SPA parallax terms (paper
/// §3.12.2–§3.12.4) precomputed.
///
/// The engine builds it with `elevationM = 0`: ADR-003 keeps observer
/// elevation in provenance only, and the Accuracy Lab places observers on the
/// WGS84 ellipsoid at 0 m (§15 D25). A non-zero elevation exists to reproduce
/// the paper's worked example.
@immutable
final class TopocentricSite {
  /// The site at geodetic [latitudeDeg] (north positive, `[−90, 90]`) and
  /// [longitudeDeg] (east positive, `[−180, 180]`), [elevationM] metres
  /// above the ellipsoid.
  ///
  /// Throws [RangeError] for a latitude or longitude out of range.
  factory of({
    required double latitudeDeg,
    required double longitudeDeg,
    double elevationM = 0,
  }) {
    if (!(latitudeDeg >= -90 && latitudeDeg <= 90)) {
      throw RangeError.value(latitudeDeg, 'latitudeDeg', 'not in [-90, 90]');
    }
    if (!(longitudeDeg >= -180 && longitudeDeg <= 180)) {
      throw RangeError.value(
        longitudeDeg,
        'longitudeDeg',
        'not in [-180, 180]',
      );
    }
    final phi = degToRad(latitudeDeg);
    final u = math.atan(_oneMinusFlattening * math.tan(phi)); // eq. 34
    final height = elevationM / _equatorialRadiusM;
    return TopocentricSite._(
      latitudeDeg: latitudeDeg,
      longitudeDeg: longitudeDeg,
      sinLatitude: math.sin(phi),
      cosLatitude: math.cos(phi),
      x: math.cos(u) + height * math.cos(phi), // eq. 35
      y: _oneMinusFlattening * math.sin(u) + height * math.sin(phi), // eq. 36
    );
  }

  const new _({
    required this.latitudeDeg,
    required this.longitudeDeg,
    required this.sinLatitude,
    required this.cosLatitude,
    required this.x,
    required this.y,
  });

  static const double _oneMinusFlattening = 0.99664719;
  static const double _equatorialRadiusM = 6378140;

  /// Geodetic latitude `φ`, degrees.
  final double latitudeDeg;

  /// Longitude `σ`, degrees east.
  final double longitudeDeg;

  /// `sin φ`.
  final double sinLatitude;

  /// `cos φ`.
  final double cosLatitude;

  /// `x = ρ·cos φ′` (eq. 35), in Earth equatorial radii.
  final double x;

  /// `y = ρ·sin φ′` (eq. 36), in Earth equatorial radii.
  final double y;
}
