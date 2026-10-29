import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:test/test.dart';

const int _minuteMs = 60000;
const int _dayMs = 24 * 60 * _minuteMs;

Observer _at(double lat, double lon) => Observer(
  latitudeDeg: lat,
  longitudeDeg: lon,
  zoneId: 'Etc/UTC',
  source: ObserverSource.benchmark,
);

final Map<String, Observer> _places = {
  'London': _at(51.51, -0.13),
  'Lagos': _at(6.5244, 3.3792),
  'Jakarta': _at(-6.2088, 106.8456),
  'Kuala Lumpur': _at(3.139, 101.6869),
  'Tromsø': _at(69.65, 18.96),
  'New York': _at(40.7128, -74.006),
  'Quito': _at(-0.18, -78.47),
  'Sydney': _at(-33.87, 151.21),
  'Cairo': _at(30.04, 31.24),
  'Ushuaia': _at(-54.80, -68.30),
};

Observer _place(String name) =>
    _places[name] ?? (throw ArgumentError.value(name, 'name'));

int _utc(int year, int month, int day, [int hour = 0, int minute = 0]) =>
    DateTime.utc(year, month, day, hour, minute).millisecondsSinceEpoch;

List<QiblaSunAlignment> _day(
  Observer observer,
  int dayStartUtcMs, {
  double toleranceDeg = 1,
}) => const FindQiblaSunAlignments()(
  observer: observer,
  fromUtcMs: dayStartUtcMs,
  toUtcMs: dayStartUtcMs + _dayMs,
  toleranceDeg: toleranceDeg,
);

/// The Sun's topocentric (azimuth, altitude) at [utcMs], from the engine's
/// exact SPA path.
(double, double) _sun(Observer observer, int utcMs) {
  final site = TopocentricSite.of(
    latitudeDeg: observer.latitudeDeg,
    longitudeDeg: observer.longitudeDeg,
  );
  final apparent = ExactSun(site).apparentAt(utcMs.toDouble());
  final sun = TopocentricSun.observe(
    site,
    declinationDeg: apparent.declinationDeg,
    hourAngleDeg: apparent.hourAngleDeg(site.longitudeDeg),
    radiusAu: apparent.earth.radiusAu,
  );
  return (sun.azimuthDeg, sun.altitudeDeg);
}

double _target(Observer observer, QiblaSunAlignmentKind kind) {
  final qibla = const CalculateQibla()(observer).bearingDeg;
  return switch (kind) {
    QiblaSunAlignmentKind.sunTowardQibla => qibla,
    QiblaSunAlignmentKind.sunAwayFromQibla => qibla + 180,
  };
}

void main() {
  group('FindQiblaSunAlignments (§6.6)', () {
    // Raṣd al-qibla: the Sun culminates over the Kaaba, published as 12:18
    // and 12:27 Makkah time (UTC+3) on 27/28 May and 15/16 July. Every
    // observer in daylight then sees the Sun in the Qibla direction.
    for (final (label, reference) in [
      ('27 May 2026, 09:18 UTC', _utc(2026, 5, 27, 9, 18)),
      ('16 July 2026, 09:27 UTC', _utc(2026, 7, 16, 9, 27)),
    ]) {
      test(
        'REQ-DOM-031 reproduces raṣd al-qibla of $label within 2 min '
        'for observers 4 200 to 7 900 km from the Kaaba',
        () {
          for (final name in [
            'London',
            'Lagos',
            'Jakarta',
            'Kuala Lumpur',
            'Tromsø',
          ]) {
            final dayStart = reference - reference % _dayMs;
            final toward = _day(_place(name), dayStart).where(
              (a) => a.kind == QiblaSunAlignmentKind.sunTowardQibla,
            );
            expect(toward, hasLength(1), reason: name);
            expect(
              (toward.single.utcMs - reference).abs(),
              lessThan(2 * _minuteMs),
              reason: name,
            );
          }
        },
      );
    }

    test('REQ-DOM-031 gives the antipodal transit of 13 January 2026 as one '
        'shadow-to-Qibla instant shared by observers on three continents', () {
      final instants = [
        for (final name in ['New York', 'Quito', 'Sydney'])
          _day(_place(name), _utc(2026, 1, 13))
              .where((a) => a.kind == QiblaSunAlignmentKind.sunAwayFromQibla)
              .last
              .utcMs,
      ];
      final spread =
          instants.reduce((a, b) => a > b ? a : b) -
          instants.reduce((a, b) => a < b ? a : b);
      expect(spread, lessThan(3 * _minuteMs));
    });

    test('REQ-DOM-031 puts the Sun on the Qibla bearing or its reciprocal '
        'within 0.01° and above the horizon at every reported instant', () {
      var checked = 0;
      for (final observer in _places.values) {
        for (var month = 1; month <= 12; month++) {
          for (final alignment in _day(observer, _utc(2026, month, 7))) {
            final (azimuth, altitude) = _sun(observer, alignment.utcMs);
            expect(
              wrapTo180(azimuth - _target(observer, alignment.kind)).abs(),
              lessThan(0.01),
            );
            expect(altitude, greaterThan(0));
            expect(alignment.sunAltitudeDeg, closeTo(altitude, 1e-4));
            checked++;
          }
        }
      }
      expect(checked, greaterThan(100));
    });

    test(
      'REQ-DOM-031 bounds each window where the azimuth leaves the tolerance '
      'or the Sun sets, conservative to 1 s',
      () {
        const tolerance = 2.0;
        for (final observer in _places.values) {
          for (final month in [2, 5, 8, 11]) {
            final day = _day(observer, _utc(2026, month, 3), toleranceDeg: 2);
            for (final alignment in day) {
              final target = _target(observer, alignment.kind);
              bool inside(int utcMs) {
                final (azimuth, altitude) = _sun(observer, utcMs);
                return altitude > 0 &&
                    wrapTo180(azimuth - target).abs() <= tolerance;
              }

              expect(
                alignment.windowStartUtcMs,
                lessThanOrEqualTo(alignment.utcMs),
              );
              expect(
                alignment.windowEndUtcMs,
                greaterThanOrEqualTo(alignment.utcMs),
              );
              expect(inside(alignment.windowStartUtcMs), isTrue);
              expect(inside(alignment.windowEndUtcMs), isTrue);
              expect(inside(alignment.windowStartUtcMs - 2000), isFalse);
              expect(inside(alignment.windowEndUtcMs + 2000), isFalse);
            }
          }
        }
      },
    );

    test('REQ-DOM-031 names the kind by where the Sun stands: London faces the '
        'Sun to the Qibla in the morning and has its shadow on the Qibla in '
        'the evening', () {
      final day = _day(_place('London'), _utc(2026, 5, 27));
      expect(day.map((a) => a.kind), [
        QiblaSunAlignmentKind.sunTowardQibla,
        QiblaSunAlignmentKind.sunAwayFromQibla,
      ]);
    });

    test('REQ-DOM-031 returns no alignment in polar night', () {
      expect(_day(_place('Tromsø'), _utc(2026, 12, 21)), isEmpty);
    });

    test('REQ-DOM-031 returns no alignment when the Sun never reaches the '
        'bearing: Sydney in June', () {
      expect(_day(_place('Sydney'), _utc(2026, 6, 21)), isEmpty);
    });

    test(
      'REQ-DOM-031 lists alignments in time order inside [from, to), the same '
      'whether two days are searched at once or one by one',
      () {
        final observer = _place('Sydney');
        final start = _utc(2026, 3, 1);
        final both = const FindQiblaSunAlignments()(
          observer: observer,
          fromUtcMs: start,
          toUtcMs: start + 2 * _dayMs,
          toleranceDeg: 1,
        );
        expect(both, [
          ..._day(observer, start),
          ..._day(observer, start + _dayMs),
        ]);
        expect(both, hasLength(4));
        for (var k = 1; k < both.length; k++) {
          expect(both[k].utcMs, greaterThan(both[k - 1].utcMs));
        }
        for (final alignment in both) {
          expect(
            alignment.utcMs,
            inInclusiveRange(start, start + 2 * _dayMs - 1),
          );
        }
      },
    );

    test('REQ-DOM-031 rejects an empty or over-long interval and a tolerance '
        'outside (0, 10]', () {
      final observer = _place('Cairo');
      final start = _utc(2026, 3, 1);
      List<QiblaSunAlignment> find(int to, double tolerance) =>
          const FindQiblaSunAlignments()(
            observer: observer,
            fromUtcMs: start,
            toUtcMs: to,
            toleranceDeg: tolerance,
          );
      expect(() => find(start, 1), throwsArgumentError);
      expect(() => find(start + 8 * _dayMs + 1, 1), throwsArgumentError);
      expect(() => find(start + _dayMs, 0), throwsArgumentError);
      expect(() => find(start + _dayMs, 10.5), throwsArgumentError);
      expect(find(start + 8 * _dayMs, 10), isNotEmpty);
    });

    test('REQ-DOM-020 REQ-DOM-031 is deterministic: equal arguments give equal '
        'alignments', () {
      final observer = _place('Jakarta');
      expect(
        _day(observer, _utc(2026, 9, 9)),
        _day(observer, _utc(2026, 9, 9)),
      );
    });
  });
}
