import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/interpolation.dart';
import 'package:geo_salah_core/src/astro/solar_day_model.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:glados/glados.dart';

/// Epoch days of 2026-01-01 … 2028-12-31, the reference years (§15 D25).
final Generator<int> _days = any.intInRange(20454, 21550);

void main() {
  group('CubicHermiteSeries', () {
    final quadratic = CubicHermiteSeries.fromSamples(
      startMs: 100,
      stepMs: 10,
      values: [for (var i = 0; i < 5; i++) _quadratic(100 + 10.0 * i)],
    );

    test('reproduces a quadratic exactly, slopes included', () {
      for (var t = 100.0; t <= 140; t += 0.7) {
        expect(quadratic.valueAt(t), closeTo(_quadratic(t), 1e-9));
        expect(quadratic.slopeAt(t), closeTo(0.6 * t - 4, 1e-9));
      }
    });

    test('never extrapolates outside its samples', () {
      expect(() => quadratic.valueAt(99.999), throwsRangeError);
      expect(() => quadratic.slopeAt(140.001), throwsRangeError);
      expect(quadratic.valueAt(140), closeTo(_quadratic(140), 1e-9));
    });

    test('needs three samples and a positive step', () {
      expect(
        () => CubicHermiteSeries.fromSamples(
          startMs: 0,
          stepMs: 1,
          values: const [1, 2],
        ),
        throwsArgumentError,
      );
      expect(
        () => CubicHermiteSeries.fromSamples(
          startMs: 0,
          stepMs: 0,
          values: const [1, 2, 3],
        ),
        throwsArgumentError,
      );
    });
  });

  group('SolarDayModel (§6.4 ¶2)', () {
    Glados3(
      any.doubleInRange(-89.9, 89.9),
      any.doubleInRange(-180, 180),
      _days,
    ).test(
      'interpolated altitude stays within 1e-5° (1 % of ADR-019) of exact SPA '
      'across the model',
      (lat, lon, epochDay) {
        final model = SolarDayModel.around(
          ExactSun(TopocentricSite.of(latitudeDeg: lat, longitudeDeg: lon)),
          anchorUtcMs: epochDay * 86400000.0 + 43200000,
        );
        for (var t = model.startUtcMs; t <= model.endUtcMs; t += 1800000) {
          expect(
            model.altitudeDeg(t) - model.exactAltitudeDeg(t),
            closeTo(0, 1e-5),
            reason: 'at $t',
          );
        }
      },
    );

    test('hour angle equals the exact SPA hour angle at the samples', () {
      final site = TopocentricSite.of(latitudeDeg: 30.04, longitudeDeg: 31.24);
      final anchor = CivilDate(2026, 3, 20).epochDay * 86400000.0;
      final model = SolarDayModel.around(ExactSun(site), anchorUtcMs: anchor);
      for (var k = -2; k <= 2; k++) {
        final t = anchor + k * 43200000;
        expect(
          wrapTo180(model.hourAngleDeg(t) - model.exact.hourAngleDeg(t)),
          closeTo(0, 1e-9),
        );
      }
    });
  });
}

double _quadratic(double t) => 0.3 * t * t - 4 * t + 7;
