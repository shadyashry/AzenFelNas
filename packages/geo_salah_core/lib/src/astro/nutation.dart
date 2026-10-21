import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/spa_terms.dart';
import 'package:meta/meta.dart';

/// Nutation in longitude `Δψ` and in obliquity `Δε` (SPA paper §3.4,
/// Table A4.3).
///
/// Pure and deterministic: a function of the Julian ephemeris century only.
@immutable
final class Nutation {
  /// The nutation at Julian ephemeris century [jce] (`JCE`, eq. 7).
  factory at(double jce) {
    final jce2 = jce * jce;
    final jce3 = jce2 * jce;
    // Eqs. 15–19, in degrees.
    final x = [
      297.85036 + 445267.111480 * jce - 0.0019142 * jce2 + jce3 / 189474,
      357.52772 + 35999.050340 * jce - 0.0001603 * jce2 - jce3 / 300000,
      134.96298 + 477198.867398 * jce + 0.0086972 * jce2 + jce3 / 56250,
      93.27191 + 483202.017538 * jce - 0.0036825 * jce2 + jce3 / 327270,
      125.04452 - 1934.136261 * jce + 0.0020708 * jce2 + jce3 / 450000,
    ];
    var longitude = 0.0;
    var obliquity = 0.0;
    for (final (y0, y1, y2, y3, y4, a, b, c, d) in nutationTerms) {
      final argument = degToRad(
        x[0] * y0 + x[1] * y1 + x[2] * y2 + x[3] * y3 + x[4] * y4,
      );
      longitude += (a + b * jce) * math.sin(argument); // eq. 20
      obliquity += (c + d * jce) * math.cos(argument); // eq. 21
    }
    // Eqs. 22–23: 0.0001″ → degrees.
    return Nutation._(longitude / 36000000, obliquity / 36000000);
  }

  const new _(this.longitudeDeg, this.obliquityDeg);

  /// `Δψ` in degrees.
  final double longitudeDeg;

  /// `Δε` in degrees.
  final double obliquityDeg;
}
