import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/spa_terms.dart';
import 'package:meta/meta.dart';

/// The Earth's heliocentric longitude `L`, latitude `B` and radius vector `R`
/// (SPA paper §3.2, Table A4.2).
///
/// Pure and deterministic: a function of the Julian ephemeris millennium only.
@immutable
final class EarthHeliocentric {
  /// The position at Julian ephemeris millennium [jme] (`JME`, eq. 8).
  factory at(double jme) => EarthHeliocentric._(
    limitTo360(radToDeg(_series(earthLongitudeTerms, jme))),
    radToDeg(_series(earthLatitudeTerms, jme)),
    _series(earthRadiusTerms, jme),
  );

  const new _(this.longitudeDeg, this.latitudeDeg, this.radiusAu);

  /// `L` in degrees, limited to `[0, 360)` (steps 3.2.4–3.2.6).
  final double longitudeDeg;

  /// `B` in degrees (step 3.2.7).
  final double latitudeDeg;

  /// `R` in astronomical units (step 3.2.8).
  final double radiusAu;

  /// `(X0 + X1·JME + X2·JME² + …) / 10⁸` where `Xk` sums the rows of series k
  /// (eqs. 9–11).
  static double _series(List<List<PeriodicTerm>> series, double jme) {
    var total = 0.0;
    for (var k = series.length - 1; k >= 0; k--) {
      total = total * jme + sumOfTerms(series[k], jme);
    }
    return total / 1e8;
  }

  /// `Σ A·cos(B + C·JME)` over [terms] (eqs. 9–10); exposed for the paper's
  /// Table A5.1 partial sums.
  static double sumOfTerms(List<PeriodicTerm> terms, double jme) {
    var sum = 0.0;
    for (final (a, b, c) in terms) {
      sum += a * math.cos(b + c * jme);
    }
    return sum;
  }
}
