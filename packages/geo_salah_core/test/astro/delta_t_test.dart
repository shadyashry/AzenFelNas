import 'package:geo_salah_core/src/astro/delta_t.dart';
import 'package:glados/glados.dart';

void main() {
  const deltaT = EspenakMeeusDeltaT();

  group('EspenakMeeusDeltaT', () {
    test('is recorded in provenance as espenak-meeus-2006', () {
      expect(EspenakMeeusDeltaT.modelId, 'espenak-meeus-2006');
    });

    test('returns each polynomial constant at its expansion epoch', () {
      final constants = {
        1000.0: 1574.2,
        1600.0: 120.0,
        1700.0: 8.83,
        1800.0: 13.72,
        1860.0: 7.62,
        1900.0: -2.79,
        1920.0: 21.20,
        1950.0: 29.07,
        1975.0: 45.45,
        2000.0: 63.86,
      };
      for (final MapEntry(key: year, value: seconds) in constants.entries) {
        expect(deltaT.secondsForYear(year), closeTo(seconds, 1e-9));
      }
      expect(deltaT.secondsForYear(0), closeTo(10583.6, 1e-9));
      expect(
        deltaT.secondsForYear(-1000),
        closeTo(-20 + 32 * 28.2 * 28.2, 1e-9),
      );
    });

    test('evaluates 2005–2050 as 62.92 + 0.32217 t + 0.005589 t²', () {
      expect(deltaT.secondsForYear(2026), closeTo(75.074, 1e-3));
    });

    test('steps by under 0.26 s at every polynomial boundary', () {
      // The intervals were fitted to join; a mistyped coefficient shows up as
      // a jump of seconds to hours at an interval end.
      for (final boundary in [
        -500.0,
        500.0,
        1600.0,
        1700.0,
        1800.0,
        1860.0,
        1900.0,
        1920.0,
        1941.0,
        1961.0,
        1986.0,
        2005.0,
        2050.0,
        2150.0,
      ]) {
        final jump =
            deltaT.secondsForYear(boundary) -
            deltaT.secondsForYear(boundary - 1e-9);
        expect(jump.abs(), lessThan(0.26), reason: 'at $boundary');
      }
    });

    Glados(any.doubleInRange(1700000000000, 1900000000000)).test(
      'is continuous in time inside 2005–2050, so it adds no step inside a '
      'solver bracket',
      (utcMs) {
        final step = deltaT.secondsAt(utcMs + 1) - deltaT.secondsAt(utcMs);
        expect(step.abs(), lessThan(1e-9));
      },
    );
  });
}
