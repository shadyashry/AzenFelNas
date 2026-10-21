import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/interpolation.dart';
import 'package:geo_salah_core/src/astro/sun_sample.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/astro/topocentric.dart';
import 'package:geo_salah_core/src/solver/altitude_source.dart';
import 'package:meta/meta.dart';

/// The interpolated Sun around one prayer day (§6.4 ¶2).
///
/// Declination, equation of time and distance are evaluated exactly at five
/// instants 12 h apart, `anchor − 24 h … anchor + 24 h`, and interpolated with
/// [CubicHermiteSeries]. The engine anchors the grid at the day's solar-noon
/// guess, so the whole culmination segment `[A₋, A₊]` (about ±12 h around the
/// upper transit) lies inside it, with central-difference slopes at both of
/// its interpolation knots (§15 D33). The hour angle is
/// `H = 15°·UT_h − 180° + σ + E`, exact at the samples by construction of `E`
/// ([ExactSun]).
///
/// Five SPA evaluations build a model; every other query is cheap, except the
/// `exact…` ones, which cost one SPA evaluation each. Immutable, pure and
/// deterministic.
@immutable
final class SolarDayModel implements AltitudeSource {
  /// The model of [exact] sampled around [anchorUtcMs], reusing samples
  /// already in [cache] (values are identical either way).
  ///
  /// Throws [RangeError] when a sample falls outside the SPA validity range.
  factory around(
    ExactSun exact, {
    required double anchorUtcMs,
    SunSampleCache? cache,
  }) {
    final start = anchorUtcMs - 2 * _stepMs;
    SunSample sample(double utcMs) =>
        cache?.sampleAt(exact, utcMs) ?? exact.sampleAt(utcMs);
    final samples = [for (var k = 0; k < 5; k++) sample(start + k * _stepMs)];
    CubicHermiteSeries series(double Function(SunSample) select) =>
        CubicHermiteSeries.fromSamples(
          startMs: start,
          stepMs: _stepMs,
          values: [for (final sample in samples) select(sample)],
        );
    return SolarDayModel._(
      exact,
      series((s) => s.declinationDeg),
      series((s) => s.equationOfTimeDeg),
      series((s) => s.radiusAu),
    );
  }

  const new _(
    this.exact,
    this._declination,
    this._equationOfTime,
    this._radius,
  );

  static const double _stepMs = 12 * 3600000;
  static const double _meanRateDegPerMs = 360 / 86400000;

  /// The exact Sun the model was sampled from.
  final ExactSun exact;

  final CubicHermiteSeries _declination;
  final CubicHermiteSeries _equationOfTime;
  final CubicHermiteSeries _radius;

  /// First instant the model covers (epoch ms); queries before it throw.
  double get startUtcMs => _declination.startMs;

  /// Last instant the model covers (epoch ms); queries after it throw.
  double get endUtcMs => _declination.endMs;

  /// Interpolated geocentric declination `δ` at [utcMs], degrees.
  double declinationDeg(double utcMs) => _declination.valueAt(utcMs);

  /// Interpolated equation of time `E` at [utcMs], degrees (see [ExactSun]).
  double equationOfTimeDeg(double utcMs) => _equationOfTime.valueAt(utcMs);

  /// Interpolated local hour angle at [utcMs], degrees (not reduced).
  double hourAngleDeg(double utcMs) =>
      ExactSun.meanHourAngleDeg(utcMs) +
      exact.site.longitudeDeg +
      _equationOfTime.valueAt(utcMs);

  @override
  double altitudeDeg(double utcMs) => TopocentricSun.observe(
    exact.site,
    declinationDeg: _declination.valueAt(utcMs),
    hourAngleDeg: hourAngleDeg(utcMs),
    radiusAu: _radius.valueAt(utcMs),
  ).altitudeDeg;

  @override
  double exactAltitudeDeg(double utcMs) => exact.altitudeDeg(utcMs);

  /// The instant nearest [guessUtcMs] (within ±12 h) at which the local hour
  /// angle equals [targetDeg] — 0° for the upper transit, 180° for the lower
  /// (§6.4 ¶4).
  ///
  /// Newton iteration on the interpolated hour angle to 1 µs, then one Newton
  /// step on the exact SPA hour angle. Throws [RangeError] if the iteration
  /// leaves the model's coverage.
  double instantOfHourAngle(double targetDeg, {required double guessUtcMs}) {
    var t = guessUtcMs;
    for (var i = 0; i < 20; i++) {
      final step = wrapTo180(hourAngleDeg(t) - targetDeg) / _rateDegPerMs(t);
      t -= step;
      if (step.abs() < 1e-3) break;
    }
    return t - wrapTo180(exact.hourAngleDeg(t) - targetDeg) / _rateDegPerMs(t);
  }

  double _rateDegPerMs(double utcMs) =>
      _meanRateDegPerMs + _equationOfTime.slopeAt(utcMs);
}
