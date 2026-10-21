import 'dart:math' as math;

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/apparent_sun.dart';
import 'package:geo_salah_core/src/astro/earth_heliocentric.dart';
import 'package:geo_salah_core/src/astro/julian_date.dart';
import 'package:geo_salah_core/src/astro/spa_terms.dart';
import 'package:geo_salah_core/src/astro/topocentric.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:test/test.dart';

import '../support/paper_example.dart';

/// Expected values are the published Table A5.1 of Reda & Andreas,
/// NREL/TP-560-34302 (revised January 2008); each tolerance is half a unit in
/// the last printed decimal.
void main() {
  group('SPA paper Table A4.1 (Gregorian rows)', () {
    test('computes the Julian Day of each instant', () {
      final cases = {
        (2000, 1, 1, 12): 2451545.0,
        (1999, 1, 1, 0): 2451179.5,
        (1987, 1, 27, 0): 2446822.5,
        (1987, 6, 19, 12): 2446966.0,
        (1988, 1, 27, 0): 2447187.5,
        (1988, 6, 19, 12): 2447332.0,
        (1900, 1, 1, 0): 2415020.5,
        (1600, 1, 1, 0): 2305447.5,
        (1600, 12, 31, 0): 2305812.5,
      };
      for (final MapEntry(key: date, value: expected) in cases.entries) {
        final (year, month, day, hour) = date;
        final utcMs =
            CivilDate(year, month, day).epochDay * 86400000 + hour * 3600000;
        final jd = JulianDate.fromUtcMs(utcMs.toDouble(), deltaTSeconds: 0);
        expect(jd.julianDay, closeTo(expected, 1e-9), reason: '$date');
      }
    });
  });

  group('SPA paper Table A5.1 example', () {
    final time = JulianDate.fromUtcMs(
      paperExampleUtcMs,
      deltaTSeconds: paperExampleDeltaTSeconds,
    );
    final sun = ApparentSun.at(
      paperExampleUtcMs,
      deltaTSeconds: paperExampleDeltaTSeconds,
    );
    final site = TopocentricSite.of(
      latitudeDeg: paperExampleLatitudeDeg,
      longitudeDeg: paperExampleLongitudeDeg,
      elevationM: paperExampleElevationM,
    );
    final topocentric = TopocentricSun.observe(
      site,
      declinationDeg: sun.declinationDeg,
      hourAngleDeg: sun.hourAngleDeg(paperExampleLongitudeDeg),
      radiusAu: sun.earth.radiusAu,
    );

    test('Julian Day', () {
      expect(time.julianDay, closeTo(2452930.312847, 5e-7));
    });

    test('Earth periodic-term sums L0–L5, B0–B1, R0–R4', () {
      final jme = time.julianEphemerisMillennium;
      double sum(List<List<PeriodicTerm>> series, int k) =>
          EarthHeliocentric.sumOfTerms(series[k], jme);
      expect(sum(earthLongitudeTerms, 0), closeTo(172067561.526586, 5e-6));
      expect(sum(earthLongitudeTerms, 1), closeTo(628332010650.051147, 5e-6));
      expect(sum(earthLongitudeTerms, 2), closeTo(61368.682493, 5e-7));
      expect(sum(earthLongitudeTerms, 3), closeTo(-26.902819, 5e-7));
      expect(sum(earthLongitudeTerms, 4), closeTo(-121.279536, 5e-7));
      expect(sum(earthLongitudeTerms, 5), closeTo(-0.999999, 5e-7));
      expect(sum(earthLatitudeTerms, 0), closeTo(-176.502688, 5e-7));
      expect(sum(earthLatitudeTerms, 1), closeTo(3.067582, 5e-7));
      // Forty terms near 1e8 accumulate ~1e-6 of rounding in any double
      // summation order, more than half a printed unit.
      expect(sum(earthRadiusTerms, 0), closeTo(99653849.037796, 2e-6));
      expect(sum(earthRadiusTerms, 1), closeTo(100378.567146, 5e-7));
      expect(sum(earthRadiusTerms, 2), closeTo(-1140.953507, 5e-7));
      expect(sum(earthRadiusTerms, 3), closeTo(-141.115419, 5e-7));
      expect(sum(earthRadiusTerms, 4), closeTo(1.232361, 5e-7));
    });

    test('Earth heliocentric L, B, R', () {
      expect(sun.earth.longitudeDeg, closeTo(24.0182616917, 5e-11));
      expect(sun.earth.latitudeDeg, closeTo(-0.0001011219, 5e-11));
      expect(sun.earth.radiusAu, closeTo(0.9965422974, 5e-11));
    });

    test('nutation and obliquity', () {
      expect(sun.nutation.longitudeDeg, closeTo(-0.00399840, 5e-9));
      expect(sun.nutation.obliquityDeg, closeTo(0.00166657, 5e-9));
      expect(sun.trueObliquityDeg, closeTo(23.440465, 5e-7));
    });

    test('apparent longitude, right ascension, declination, hour angle', () {
      expect(sun.apparentLongitudeDeg, closeTo(204.0085519281, 5e-11));
      expect(sun.rightAscensionDeg, closeTo(202.22741, 5e-6));
      expect(sun.declinationDeg, closeTo(-9.31434, 5e-6));
      // The table prints H = 11.105900 to six decimals but its own α is
      // printed to five (H = ν + σ − α, eq. 32), so H is checked at α's
      // precision. The implementation gives 11.1059020 (0.5 ms of time).
      expect(
        sun.hourAngleDeg(paperExampleLongitudeDeg),
        closeTo(11.105900, 5e-6),
      );
    });

    test('topocentric right ascension, declination, hour angle', () {
      expect(
        sun.rightAscensionDeg + topocentric.rightAscensionParallaxDeg,
        closeTo(202.22704, 5e-6),
      );
      expect(topocentric.declinationDeg, closeTo(-9.316179, 5e-7));
      // Erratum: the table prints H′ = 11.10629, which disagrees by 2e-5° with
      // its own H − Δα = 11.105900 − (202.22704 − 202.22741) = 11.10627
      // (eqs. 38, 40). H′ is checked against that consistent value, at the
      // summed precision of the three printed inputs.
      expect(topocentric.hourAngleDeg, closeTo(11.10627, 1.1e-5));
    });

    test('topocentric zenith and azimuth', () {
      // The paper's zenith includes its refraction model (eq. 42) for
      // P = 820 mbar and T = 11 °C. The engine never refracts (ADR-003), so
      // the published zenith is converted back here, in the test only.
      final e0 = topocentric.altitudeDeg;
      final refraction =
          (820 / 1010) *
          (283 / (273 + 11)) *
          1.02 /
          (60 * math.tan((e0 + 10.3 / (e0 + 5.11)) * math.pi / 180));
      expect(90 - (e0 + refraction), closeTo(50.11162, 5e-6));
      expect(topocentric.azimuthDeg, closeTo(194.34024, 5e-6));
    });
  });
}
