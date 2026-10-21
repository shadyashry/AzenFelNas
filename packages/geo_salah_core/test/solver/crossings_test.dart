import 'dart:math' as math;

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/solver/crossing.dart';
import 'package:geo_salah_core/src/solver/crossing_direction.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:geo_salah_core/src/solver/monotone_pieces.dart';
import 'package:glados/glados.dart';

import '../support/fake_tz_database.dart';
import '../support/paper_example.dart';

/// Epoch days of 2026-01-01 … 2028-12-31 (§15 D25).
final Generator<int> _days = any.intInRange(20454, 21550);

/// The SPA paper's sunrise/sunset altitude h0′ (§A.2), used only to compare
/// with the paper's published times. The engine takes horizon altitudes from
/// the profile (ADR-003); no such constant exists in `lib/`.
const double _paperHorizonDeg = -0.8333;

final FakeTzDatabase _utc = FakeTzDatabase(const {'UTC': 0});

CulminationSegments _segments(double lat, double lon, int epochDay) =>
    CulminationSegments.locate(
      day: CivilDate.fromEpochDay(epochDay),
      site: TopocentricSite.of(latitudeDeg: lat, longitudeDeg: lon),
      zoneId: 'UTC',
      tzdb: _utc,
    )!;

/// Asserts that [pieces] reports every sign change of `altitude − target`
/// that a 60 s scan of its segment sees, with the same direction.
///
/// The scan samples the interpolated altitude, while each reported crossing
/// is refined on the exact SPA altitude. The two differ by at most 1e-5°
/// (interpolation test), which moves a crossing by `1e-5° / |rate|`. So a
/// crossing may lie that far outside the scan cell, by at least 1 ms and at
/// most 60 s, the ADR-019 bound for a near-tangent crossing.
void _expectEveryScannedCrossing(MonotonePieces pieces, double targetDeg) {
  final solved = pieces.crossings(targetDeg);
  final end = pieces.boundaries.last;
  var t0 = pieces.boundaries.first;
  var f0 = pieces.source.altitudeDeg(t0) - targetDeg;
  while (t0 < end) {
    final t1 = math.min(t0 + 60000, end);
    final f1 = pieces.source.altitudeDeg(t1) - targetDeg;
    if ((f0 < 0 && f1 >= 0) || (f0 > 0 && f1 <= 0)) {
      final direction = f1 > f0
          ? CrossingDirection.rising
          : CrossingDirection.setting;
      final rate = ((f1 - f0) / (t1 - t0)).abs();
      final slack = rate == 0
          ? 60000.0
          : math.min(60000, math.max(1, 1e-5 / rate)).toDouble();
      expect(
        solved.where(
          (c) =>
              c.direction == direction &&
              c.utcMs >= t0.floor() - 1 - slack &&
              c.utcMs <= t1 + slack,
        ),
        isNotEmpty,
        reason: 'scanned crossing in [$t0, $t1], target $targetDeg',
      );
    }
    t0 = t1;
    f0 = f1;
  }
}

void main() {
  group('MonotonePieces', () {
    Glados3(
      any.doubleInRange(-89.9, 89.9),
      _days,
      any.doubleInRange(-20, 60),
    ).test(
      'finds every crossing a dense scan finds, in its direction, so a '
      'primary root is never missed (bracket exhaustiveness, REQ-DOM-002)',
      (lat, epochDay, target) {
        final segments = _segments(lat, 0, epochDay);
        _expectEveryScannedCrossing(segments.ascending, target);
        _expectEveryScannedCrossing(segments.descending, target);
      },
    );

    Glados3(
      any.doubleInRange(-89.9, 89.9),
      _days,
      any.doubleInRange(-6, -2),
    ).test(
      'finds both crossings of a target grazing an altitude extremum, '
      '1e-6° to 1e-2° inside it (bracket exhaustiveness, REQ-DOM-002)',
      (lat, epochDay, log10Offset) {
        final segments = _segments(lat, 0, epochDay);
        final offset = math.pow(10, log10Offset).toDouble();
        for (final half in [segments.ascending, segments.descending]) {
          for (final boundary in half.boundaries) {
            final extremum = half.source.altitudeDeg(boundary);
            _expectEveryScannedCrossing(half, extremum - offset);
            _expectEveryScannedCrossing(half, extremum + offset);
          }
        }
      },
    );

    Glados2(any.doubleInRange(-89.9, 89.9), _days).test(
      'splits each half segment into pieces on which the altitude is monotone '
      '(REQ-DOM-002)',
      (lat, epochDay) {
        final segments = _segments(lat, 0, epochDay);
        for (final half in [segments.ascending, segments.descending]) {
          final b = half.boundaries;
          for (var i = 0; i + 1 < b.length; i++) {
            final sign =
                (half.source.altitudeDeg(b[i + 1]) -
                        half.source.altitudeDeg(b[i]))
                    .sign;
            var previous = half.source.altitudeDeg(b[i]);
            for (var t = b[i] + 60000; t < b[i + 1]; t += 60000) {
              final current = half.source.altitudeDeg(t);
              expect((current - previous) * sign, greaterThanOrEqualTo(-1e-9));
              previous = current;
            }
          }
        }
      },
    );

    Glados3(
      any.doubleInRange(-89.9, 89.9),
      _days,
      any.doubleInRange(-20, 60),
    ).test(
      'places each crossing where the exact SPA altitude equals the '
      'target, truncated to 1 ms (REQ-DOM-004)',
      (lat, epochDay, target) {
        final segments = _segments(lat, 0, epochDay);
        final exact = ExactSun(
          TopocentricSite.of(latitudeDeg: lat, longitudeDeg: 0),
        );
        for (final half in [segments.ascending, segments.descending]) {
          for (final crossing in half.crossings(target)) {
            // 1 ms at the fastest solar altitude rate (0.0042°/s) is
            // 4.2e-6°.
            expect(
              exact.altitudeDeg(crossing.utcMs + 0.5) - target,
              closeTo(0, 1e-5),
            );
          }
        }
      },
    );

    Glados3(
      any.doubleInRange(-50, 50),
      any.doubleInRange(-180, 180),
      _days,
    ).test(
      'moves a horizon crossing by less than 3 min from one day to the next '
      'up to 50° latitude (continuity, REQ-TEST-002)',
      (lat, lon, epochDay) {
        for (final target in [-1.0, 0.0, 1.0]) {
          final today = _segments(lat, lon, epochDay);
          final tomorrow = _segments(lat, lon, epochDay + 1);
          for (final (a, b) in [
            (today.ascending, tomorrow.ascending),
            (today.descending, tomorrow.descending),
          ]) {
            final first = a.crossings(target).single.utcMs;
            final next = b.crossings(target).single.utcMs;
            expect(next - first - 86400000, closeTo(0, 180000));
          }
        }
      },
    );

    test('reports no crossing in polar day or polar night, never an '
        'extrapolated one (REQ-DOM-002)', () {
      for (final day in [CivilDate(2026, 6, 21), CivilDate(2026, 12, 21)]) {
        final segments = _segments(69.65, 18.96, day.epochDay);
        expect(segments.ascending.crossings(0), isEmpty);
        expect(segments.descending.crossings(0), isEmpty);
      }
    });

    test('gives bit-identical instants when the day is recomputed '
        '(REQ-DOM-004)', () {
      List<Crossing> run() {
        final segments = _segments(
          51.51,
          -0.13,
          CivilDate(2026, 3, 29).epochDay,
        );
        return [
          ...segments.ascending.crossings(-6),
          ...segments.descending.crossings(-6),
        ];
      }

      final first = run();
      expect(first, hasLength(2));
      for (var i = 0; i < 5; i++) {
        expect(run(), first);
      }
    });
  });

  group('SPA paper §A.2 sunrise and sunset (2003-10-17, Golden)', () {
    // The paper's A.2 is a one-step approximation on geocentric positions;
    // the engine solves the topocentric altitude exactly. Topocentric
    // parallax alone shifts these crossings by ~0.8 s, so they must agree
    // within 2 s.
    CulminationSegments segmentsOn(CivilDate day) => CulminationSegments.locate(
      day: day,
      site: TopocentricSite.of(
        latitudeDeg: paperExampleLatitudeDeg,
        longitudeDeg: paperExampleLongitudeDeg,
      ),
      zoneId: 'MST',
      tzdb: FakeTzDatabase(const {'MST': -7 * 3600}),
    )!;

    test('sunrise 13:12:43.46 UT', () {
      final rise = segmentsOn(
        CivilDate(2003, 10, 17),
      ).ascending.crossings(_paperHorizonDeg).single;
      expect(rise.direction, CrossingDirection.rising);
      expect(
        rise.utcMs -
            DateTime.utc(2003, 10, 17, 13, 12, 43, 460).millisecondsSinceEpoch,
        closeTo(0, 2000),
      );
    });

    test('sunset 00:20:19.19 UT, which A.2 takes from the evening of '
        '16 October local time', () {
      // A.2 limits the sunset fraction m2 to the UT day of the input, so its
      // 00:20:19 UT on 17 October is the sunset of 16 October local time;
      // 17 October's sunset is about 88 s earlier, at 00:18:51 UT on the 18th.
      final set = segmentsOn(
        CivilDate(2003, 10, 16),
      ).descending.crossings(_paperHorizonDeg).single;
      expect(set.direction, CrossingDirection.setting);
      expect(
        set.utcMs -
            DateTime.utc(2003, 10, 17, 0, 20, 19, 190).millisecondsSinceEpoch,
        closeTo(0, 2000),
      );
    });
  });
}
