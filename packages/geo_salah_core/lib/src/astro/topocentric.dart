import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:meta/meta.dart';

/// The Sun seen from a [TopocentricSite]: parallax-corrected declination and
/// hour angle, and the geometric altitude (SPA paper §3.12–§3.15, §6.4 ¶3).
///
/// [altitudeDeg] is the paper's `e0`: **no atmospheric refraction** is ever
/// applied (ADR-003). Horizon events add refraction and semidiameter through
/// the profile's horizon rule instead. Pure and deterministic.
@immutable
final class TopocentricSun {
  /// Observes a Sun of geocentric [declinationDeg] `δ`, local hour angle
  /// [hourAngleDeg] `H` (westward, any multiple of 360°) and distance
  /// [radiusAu] `R` from [site].
  factory observe(
    TopocentricSite site, {
    required double declinationDeg,
    required double hourAngleDeg,
    required double radiusAu,
  }) {
    final xi = degToRad(8.794 / (3600 * radiusAu)); // eq. 33
    final sinXi = math.sin(xi);
    final h = degToRad(hourAngleDeg);
    final delta = degToRad(declinationDeg);
    final cosDelta = math.cos(delta);
    final denominator = cosDelta - site.x * sinXi * math.cos(h);
    final deltaAlpha = math.atan2(
      -site.x * sinXi * math.sin(h),
      denominator,
    ); // eq. 37
    final topocentricDelta = math.atan2(
      (math.sin(delta) - site.y * sinXi) * math.cos(deltaAlpha),
      denominator,
    ); // eq. 39
    final topocentricH = h - deltaAlpha; // eq. 40
    // Eq. 41; the clamp keeps rounding at the zenith or nadir out of NaN.
    final altitude = math.asin(
      (site.sinLatitude * math.sin(topocentricDelta) +
              site.cosLatitude *
                  math.cos(topocentricDelta) *
                  math.cos(topocentricH))
          .clamp(-1.0, 1.0),
    );
    return TopocentricSun._(
      site: site,
      rightAscensionParallaxDeg: radToDeg(deltaAlpha),
      declinationDeg: radToDeg(topocentricDelta),
      hourAngleDeg: radToDeg(topocentricH),
      altitudeDeg: radToDeg(altitude),
    );
  }

  const new _({
    required this.site,
    required this.rightAscensionParallaxDeg,
    required this.declinationDeg,
    required this.hourAngleDeg,
    required this.altitudeDeg,
  });

  /// The observing site.
  final TopocentricSite site;

  /// The parallax in right ascension `Δα`, degrees (eq. 37).
  final double rightAscensionParallaxDeg;

  /// The topocentric declination `δ′`, degrees (eq. 39).
  final double declinationDeg;

  /// The topocentric hour angle `H′ = H − Δα`, degrees (eq. 40); it keeps the
  /// turn count of the input `H`.
  final double hourAngleDeg;

  /// The geometric topocentric altitude `e0`, degrees, no refraction (eq. 41).
  final double altitudeDeg;

  /// The topocentric azimuth `Φ`, degrees eastward from north, `[0, 360)`
  /// (eqs. 45–46).
  double get azimuthDeg {
    final h = degToRad(hourAngleDeg);
    final gamma = math.atan2(
      math.sin(h),
      math.cos(h) * site.sinLatitude -
          math.tan(degToRad(declinationDeg)) * site.cosLatitude,
    );
    return limitTo360(radToDeg(gamma) + 180);
  }
}
