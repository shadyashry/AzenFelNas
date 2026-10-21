import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/astro/angles.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:glados/glados.dart';

import '../support/fake_tz_database.dart';
import '../support/paper_example.dart';
import '../support/sites.dart';

/// Epoch days of 2026-01-01 … 2028-12-31 (§15 D25).
final Generator<int> _days = any.intInRange(20454, 21550);
final Generator<int> _cityIndex = any.intInRange(0, testCities.length);

CulminationSegments _segments(TestCity city, CivilDate day) =>
    CulminationSegments.locate(
      day: day,
      site: city.site,
      zoneId: city.zoneId,
      tzdb: testTzdb,
    )!;

int _localEpochDay(double utcMs, TestCity city) =>
    ((utcMs + city.offsetSeconds * 1000) / 86400000).floor();

void main() {
  group('CulminationSegments (ADR-004)', () {
    Glados2(_cityIndex, _days).test(
      'bounds the prayer day by the lower transits around the upper transit '
      'whose local date is D (REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final segments = _segments(city, CivilDate.fromEpochDay(epochDay));
        final exact = ExactSun(city.site);
        expect(_localEpochDay(segments.upperUtcMs, city), epochDay);
        expect(segments.lowerBeforeUtcMs, lessThan(segments.upperUtcMs));
        expect(segments.upperUtcMs, lessThan(segments.lowerAfterUtcMs));
        // Hour angle 0° at T₀ and 180° at A±, on the exact SPA: 1e-6° of
        // hour angle is 0.24 ms.
        expect(
          wrapTo180(exact.hourAngleDeg(segments.upperUtcMs)),
          closeTo(0, 1e-6),
        );
        for (final lower in [
          segments.lowerBeforeUtcMs,
          segments.lowerAfterUtcMs,
        ]) {
          expect(wrapTo180(exact.hourAngleDeg(lower) - 180), closeTo(0, 1e-6));
        }
      },
    );

    Glados2(_cityIndex, _days).test(
      'tiles time: A₊ of day D is A₋ of day D + 1, within 1 ms '
      '(REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final today = _segments(city, CivilDate.fromEpochDay(epochDay));
        final tomorrow = _segments(city, CivilDate.fromEpochDay(epochDay + 1));
        expect(
          today.lowerAfterUtcMs - tomorrow.lowerBeforeUtcMs,
          closeTo(0, 1),
        );
      },
    );

    Glados2(_cityIndex, _days).test(
      'moves the upper transit by 24 h ± 60 s from one day to the next '
      '(continuity, REQ-TEST-002)',
      (index, epochDay) {
        final city = testCities[index];
        final today = _segments(city, CivilDate.fromEpochDay(epochDay));
        final tomorrow = _segments(city, CivilDate.fromEpochDay(epochDay + 1));
        expect(
          tomorrow.upperUtcMs - today.upperUtcMs - 86400000,
          closeTo(0, 60000),
        );
      },
    );

    test('finds the transit on the local day for a zone 24.5 h ahead of its '
        'solar time, Kiritimati (REQ-TIME-002)', () {
      final kiritimati = testCities.singleWhere(
        (c) => c.zoneId == 'Pacific/Kiritimati',
      );
      final day = CivilDate(2026, 6, 21);
      final segments = _segments(kiritimati, day);
      expect(_localEpochDay(segments.upperUtcMs, kiritimati), day.epochDay);
      // Local solar noon there is about 12:30 local, 22:30 UTC the day before.
      expect(
        segments.upperUtcMs - (day.epochDay - 1) * 86400000,
        closeTo(22.5 * 3600000, 30 * 60000),
      );
    });

    test('has no segments for a calendar day the zone skipped '
        '(Pacific/Apia, 2011-12-30)', () {
      // Apia moved from UTC−10 to UTC+14 at 2011-12-30T10:00Z.
      final tzdb = FakeTzDatabase.switching(
        const {'Pacific/Apia': -10 * 3600},
        switchUtcMs: DateTime.utc(2011, 12, 30, 10).millisecondsSinceEpoch,
        offsetAfterSeconds: const {'Pacific/Apia': 14 * 3600},
      );
      final apia = TopocentricSite.of(
        latitudeDeg: -13.83,
        longitudeDeg: -171.76,
      );
      CulminationSegments? locate(CivilDate day) => CulminationSegments.locate(
        day: day,
        site: apia,
        zoneId: 'Pacific/Apia',
        tzdb: tzdb,
      );
      expect(locate(CivilDate(2011, 12, 29)), isNotNull);
      expect(locate(CivilDate(2011, 12, 30)), isNull);
      expect(locate(CivilDate(2011, 12, 31)), isNotNull);
    });

    test('matches the SPA paper transit, 18:46:04.97 UT on 2003-10-17, '
        'within 0.25 s', () {
      // The paper's A.2 transit is within 0.23 s of the Astronomical Almanac
      // (its Figure A2.1); the engine solves H = 0 exactly.
      final segments = CulminationSegments.locate(
        day: CivilDate(2003, 10, 17),
        site: TopocentricSite.of(
          latitudeDeg: paperExampleLatitudeDeg,
          longitudeDeg: paperExampleLongitudeDeg,
        ),
        zoneId: 'MST',
        tzdb: FakeTzDatabase(const {'MST': -7 * 3600}),
      )!;
      final transit = DateTime.utc(2003, 10, 17, 18, 46, 4, 970);
      expect(
        segments.upperUtcMs - transit.millisecondsSinceEpoch,
        closeTo(0, 250),
      );
    });
  });
}
