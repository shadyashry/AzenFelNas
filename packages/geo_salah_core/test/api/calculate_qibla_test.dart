import 'dart:convert';
import 'dart:io';

import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

/// §6.6 tolerance against the reference is 0.01°; the port matches
/// GeographicLib to round-off, so the test holds it to 1e-9°.
const double _bearingToleranceDeg = 1e-9;
const double _distanceToleranceM = 1e-6;

double _angleDelta(double a, double b) {
  final d = (a - b).abs() % 360;
  return d > 180 ? 360 - d : d;
}

Observer _at(double lat, double lon) => Observer(
  latitudeDeg: lat,
  longitudeDeg: lon,
  zoneId: 'Etc/UTC',
  source: ObserverSource.manual,
);

void main() {
  const qibla = CalculateQibla();
  final golden = jsonDecode(
    File('test/qibla/qibla_vectors.json').readAsStringSync(),
  ) as Map<String, Object?>;
  final vectors = _as<List<Object?>>(golden['vectors'])
      .cast<Map<String, Object?>>();

  group('CalculateQibla (§6.6)', () {
    test('REQ-DOM-030 golden vectors match GeographicLib within 1e-9°', () {
      expect(vectors, hasLength(greaterThanOrEqualTo(250)));
      for (final v in vectors) {
        final got = qibla(
          _at(_as<num>(v['lat']).toDouble(), _as<num>(v['lon']).toDouble()),
        );
        final want = _as<num>(v['bearingDeg']).toDouble();
        expect(
          _angleDelta(got.bearingDeg, want),
          lessThan(_bearingToleranceDeg),
          reason: '${v['name']}: ${got.bearingDeg} vs $want',
        );
        expect(
          (got.distanceM - _as<num>(v['distanceM']).toDouble()).abs(),
          lessThan(_distanceToleranceM),
          reason: '${v['name']} distance',
        );
      }
    });

    test('REQ-DOM-030 Cairo faces south-east and Jakarta west-north-west', () {
      expect(
        qibla(_at(30.04, 31.24)).bearingDeg,
        closeTo(135.98, 0.01),
      );
      expect(
        qibla(_at(-6.2, 106.8)).bearingDeg,
        closeTo(295.03, 0.01),
      );
    });

    test('REQ-DOM-030 bearing is in [0, 360) and names the Kaaba version', () {
      final b = qibla(_at(40.7, -74));
      expect(b.bearingDeg, inInclusiveRange(0, 360));
      expect(b.bearingDeg, lessThan(360));
      expect(b.kaabaRefVersion, Kaaba.refVersion);
    });

    test('REQ-DOM-030 at the Kaaba the bearing is 0 with distance 0', () {
      final b = qibla(_at(Kaaba.latitudeDeg, Kaaba.longitudeDeg));
      expect(b.distanceM, 0);
      expect(b.bearingDeg, 0);
    });

    test('REQ-DOM-020 equal arguments give equal bearings', () {
      expect(
        qibla(_at(51.5, -0.12)),
        qibla(_at(51.5, -0.12)),
      );
    });
  });
}

/// [value] as [T]; fails the test otherwise.
T _as<T>(Object? value) =>
    value is T ? value : throw StateError('not $T: $value');
