import 'dart:math' as math;

import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/earth_heliocentric.dart';
import 'package:geo_salah_core/src/astro/julian_date.dart';
import 'package:geo_salah_core/src/astro/nutation.dart';
import 'package:meta/meta.dart';

/// The Sun's apparent geocentric position at one instant: SPA (Reda & Andreas
/// 2008) §3.1–§3.10, implemented from the paper (ADR-019, §6.4 ¶1).
///
/// Valid for years −2000 to 6000 (the paper's range, uncertainty ±0.0003°);
/// [ApparentSun.at] throws [RangeError] outside it (§15 D35). Pure and
/// deterministic: no clock, no I/O; equal inputs give bit-identical outputs
/// on one platform.
@immutable
final class ApparentSun {
  /// The apparent Sun at [utcMs] (UTC epoch milliseconds, fractional allowed)
  /// with ΔT = TT − UT of [deltaTSeconds].
  ///
  /// Throws [RangeError] when [utcMs] lies outside years −2000 to 6000.
  factory at(double utcMs, {required double deltaTSeconds}) {
    if (utcMs < _firstValidUtcMs || utcMs > _lastValidUtcMs) {
      throw RangeError.range(
        utcMs,
        _firstValidUtcMs.toInt(),
        _lastValidUtcMs.toInt(),
        'utcMs',
        'outside the SPA validity range (years -2000 to 6000)',
      );
    }
    final time = JulianDate.fromUtcMs(utcMs, deltaTSeconds: deltaTSeconds);
    final earth = EarthHeliocentric.at(time.julianEphemerisMillennium);
    final nutation = Nutation.at(time.julianEphemerisCentury);
    final epsilon =
        _meanObliquityArcsec(time.julianEphemerisMillennium / 10) / 3600 +
        nutation.obliquityDeg; // eq. 25
    final aberration = -20.4898 / (3600 * earth.radiusAu); // eq. 26
    final geocentricLongitude = limitTo360(earth.longitudeDeg + 180); // eq. 13
    final geocentricLatitude = -earth.latitudeDeg; // eq. 14
    final lambda =
        geocentricLongitude + nutation.longitudeDeg + aberration; // eq. 27
    final jc = time.julianCentury;
    final meanSiderealTime = limitTo360(
      280.46061837 +
          360.98564736629 * time.daysSinceJ2000 +
          0.000387933 * jc * jc -
          jc * jc * jc / 38710000,
    ); // eq. 28
    final apparentSiderealTime =
        meanSiderealTime +
        nutation.longitudeDeg * math.cos(degToRad(epsilon)); // eq. 29
    final lambdaRad = degToRad(lambda);
    final epsilonRad = degToRad(epsilon);
    final betaRad = degToRad(geocentricLatitude);
    final rightAscension = limitTo360(
      radToDeg(
        math.atan2(
          math.sin(lambdaRad) * math.cos(epsilonRad) -
              math.tan(betaRad) * math.sin(epsilonRad),
          math.cos(lambdaRad),
        ),
      ),
    ); // eq. 30
    final declination = radToDeg(
      math.asin(
        math.sin(betaRad) * math.cos(epsilonRad) +
            math.cos(betaRad) * math.sin(epsilonRad) * math.sin(lambdaRad),
      ),
    ); // eq. 31
    return ApparentSun._(
      earth: earth,
      nutation: nutation,
      trueObliquityDeg: epsilon,
      apparentLongitudeDeg: lambda,
      apparentSiderealTimeDeg: apparentSiderealTime,
      rightAscensionDeg: rightAscension,
      declinationDeg: declination,
    );
  }

  const new _({
    required this.earth,
    required this.nutation,
    required this.trueObliquityDeg,
    required this.apparentLongitudeDeg,
    required this.apparentSiderealTimeDeg,
    required this.rightAscensionDeg,
    required this.declinationDeg,
  });

  /// UTC epoch milliseconds of −2000-01-01 and 6001-01-01 (proleptic
  /// Gregorian), the paper's stated validity range.
  static const double _firstValidUtcMs = -125281123200000;
  static const double _lastValidUtcMs = 127206115200000;

  /// The Earth's heliocentric position (`L`, `B`, `R`).
  final EarthHeliocentric earth;

  /// The nutation (`Δψ`, `Δε`).
  final Nutation nutation;

  /// The true obliquity of the ecliptic `ε`, in degrees (eq. 25).
  final double trueObliquityDeg;

  /// The apparent Sun longitude `λ`, in degrees (eq. 27).
  final double apparentLongitudeDeg;

  /// The apparent sidereal time at Greenwich `ν`, in degrees (eq. 29).
  final double apparentSiderealTimeDeg;

  /// The geocentric right ascension `α`, in degrees, `[0, 360)` (eq. 30).
  final double rightAscensionDeg;

  /// The geocentric declination `δ`, in degrees (eq. 31).
  final double declinationDeg;

  /// The observer local hour angle `H = ν + σ − α` for east longitude
  /// [longitudeDeg] `σ`, in degrees, `[0, 360)`, measured westward (eq. 32).
  double hourAngleDeg(double longitudeDeg) => limitTo360(
    apparentSiderealTimeDeg + longitudeDeg - rightAscensionDeg,
  );

  /// The mean obliquity `ε0` in arcseconds for `U = JME / 10` (eq. 24).
  static double _meanObliquityArcsec(double u) {
    const coefficients = [
      84381.448,
      -4680.93,
      -1.55,
      1999.25,
      -51.38,
      -249.67,
      -39.05,
      7.12,
      27.87,
      5.79,
      2.45,
    ];
    var total = 0.0;
    for (var k = coefficients.length - 1; k >= 0; k--) {
      total = total * u + coefficients[k];
    }
    return total;
  }
}
