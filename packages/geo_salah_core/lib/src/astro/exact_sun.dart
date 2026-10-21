import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/apparent_sun.dart';
import 'package:geo_salah_core/src/astro/delta_t.dart';
import 'package:geo_salah_core/src/astro/sun_sample.dart';
import 'package:geo_salah_core/src/astro/topocentric.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:meta/meta.dart';

/// One full SPA evaluation per call, for one site: the "exact" path of §6.4
/// ¶2, used to build the day model's samples and to refine converged roots.
///
/// The equation of time here is **defined** as the apparent minus the mean
/// Greenwich hour angle, `E = ν − α − (15°·UT_h − 180°)`, wrapped to
/// `[−180°, 180°)`. With it `H = 15°·UT_h − 180° + σ + E` is exactly the SPA
/// hour angle. The paper's approximate eq. A1 (mean longitude in TT) differs
/// from it by about 0.2 s and is not used (§15 D33).
///
/// Pure and deterministic.
@immutable
final class ExactSun {
  /// The exact Sun for [site], with ΔT from [deltaT].
  const new(this.site, {this.deltaT = const EspenakMeeusDeltaT()});

  static const double _msPerDay = 86400000;

  /// The observing site.
  final TopocentricSite site;

  /// The ΔT model.
  final EspenakMeeusDeltaT deltaT;

  /// The mean-Sun Greenwich hour angle `15°·UT_h − 180°` at [utcMs], degrees,
  /// in `[−180, 180)`.
  static double meanHourAngleDeg(double utcMs) =>
      (utcMs % _msPerDay) / _msPerDay * 360 - 180;

  /// The apparent Sun at [utcMs].
  ApparentSun apparentAt(double utcMs) =>
      ApparentSun.at(utcMs, deltaTSeconds: deltaT.secondsAt(utcMs));

  /// Declination, equation of time and distance at [utcMs].
  SunSample sampleAt(double utcMs) {
    final sun = apparentAt(utcMs);
    return (
      declinationDeg: sun.declinationDeg,
      equationOfTimeDeg: wrapTo180(
        sun.apparentSiderealTimeDeg -
            sun.rightAscensionDeg -
            meanHourAngleDeg(utcMs),
      ),
      radiusAu: sun.earth.radiusAu,
    );
  }

  /// The local hour angle `H` at [utcMs], degrees, `[0, 360)`.
  double hourAngleDeg(double utcMs) =>
      apparentAt(utcMs).hourAngleDeg(site.longitudeDeg);

  /// The geometric topocentric altitude at [utcMs], degrees (no refraction).
  double altitudeDeg(double utcMs) {
    final sun = apparentAt(utcMs);
    return TopocentricSun.observe(
      site,
      declinationDeg: sun.declinationDeg,
      hourAngleDeg: sun.hourAngleDeg(site.longitudeDeg),
      radiusAu: sun.earth.radiusAu,
    ).altitudeDeg;
  }
}
