import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/model/observer.dart';
import 'package:geo_salah_core/src/model/sky_phase.dart';
import 'package:geo_salah_core/src/model/solar_state.dart';

/// The Sun's state for an observer at one instant (§6.3 `solarState`).
///
/// One exact SPA evaluation at [Observer]'s coordinates (sea level): the
/// geometric topocentric altitude and azimuth, the direction (rising while
/// the topocentric hour angle is in `[180°, 360°)`) and the Appendix G
/// [SkyPhase]. For the theme only; prayer times never read it.
///
/// No I/O, clock or randomness (REQ-DOM-020): equal arguments give equal
/// results. Valid for the ephemeris domain of `CalculateDay`.
final class ComputeSolarState {
  /// The use case.
  const new();

  /// The [SolarState] for [observer] at [utcMs].
  SolarState call({required Observer observer, required int utcMs}) {
    final site = TopocentricSite.of(
      latitudeDeg: observer.latitudeDeg,
      longitudeDeg: observer.longitudeDeg,
    );
    final t = utcMs.toDouble();
    final sun = ExactSun(site).apparentAt(t);
    final topo = TopocentricSun.observe(
      site,
      declinationDeg: sun.declinationDeg,
      hourAngleDeg: sun.hourAngleDeg(site.longitudeDeg),
      radiusAu: sun.earth.radiusAu,
    );
    final rising = topo.hourAngleDeg % 360 >= 180;
    final phase = SkyPhase.classify(
      altitudeDeg: topo.altitudeDeg,
      rising: rising,
    );
    return SolarState(
      altitudeDeg: topo.altitudeDeg,
      azimuthDeg: topo.azimuthDeg,
      rising: rising,
      phase: phase,
      phaseProgress: phase.progressAt(topo.altitudeDeg),
    );
  }
}
