import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/astro/sun_sample_cache.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:glados/glados.dart';

import '../support/engine_fixtures.dart';
import '../support/sites.dart';

/// Epoch days of 2026-01-01 … 2028-12-01 (the lab reference years).
final Generator<int> _days = any.intInRange(20454, 21520);
final Generator<int> _cityIndex = any.intInRange(0, testCities.length);

/// A Hijri state that differs per day, so a range must ask for each.
HijriState _hijriFor(CivilDate day) => HijriState(
  dateAtDawn: HijriDate(year: 1448, month: 1 + day.month % 12, day: day.day),
  dateAtNight: HijriDate(year: 1448, month: 1 + day.month % 12, day: day.day),
  confidence: HijriConfidence.expected,
);

Result<List<DayResult>, EngineFailure> _range(
  TestCity city,
  CivilDate from,
  int days, {
  PrayerProfile? profile,
}) => const CalculateRange()(
  observer: observerOf(city),
  profile: profile ?? testProfile,
  from: from,
  days: days,
  tzdb: testTzdb,
  hijriFor: _hijriFor,
);

void main() {
  group('CalculateRange (§6.3)', () {
    Glados2(_cityIndex, _days).test(
      'returns, bit for bit, the days CalculateDay returns one by one '
      '(REQ-DOM-004)',
      (index, epochDay) {
        final city = testCities[index];
        final from = CivilDate.fromEpochDay(epochDay);
        const days = 8;
        final expected = <Result<DayResult, EngineFailure>>[
          for (var i = 0; i < days; i++)
            const CalculateDay()(
              observer: observerOf(city),
              profile: testProfile,
              day: CivilDate.fromEpochDay(epochDay + i),
              tzdb: testTzdb,
              hijri: _hijriFor(CivilDate.fromEpochDay(epochDay + i)),
            ),
        ];
        final firstFailure = expected
            .whereType<Err<DayResult, EngineFailure>>();
        switch (_range(city, from, days)) {
          case Ok(:final value):
            expect(firstFailure, isEmpty);
            expect(value, [
              for (final result in expected)
                if (result case Ok(:final value)) value,
            ]);
          case Err(:final failure):
            expect(failure, firstFailure.first.failure);
        }
      },
    );

    test('calculates a whole year in day order with each day its own '
        'Hijri state', () {
      final from = CivilDate(2027, 1, 1);
      final result = _range(cityIn('Africa/Cairo'), from, 365);
      expect(result, isA<Ok<List<DayResult>, EngineFailure>>());
      if (result case Ok(:final value)) {
        expect(value, hasLength(365));
        for (final (i, day) in value.indexed) {
          expect(day.day, CivilDate.fromEpochDay(from.epochDay + i));
        }
        expect(value[40].calculationId, isNot(value[41].calculationId));
      }
    });

    test('ends with the first failing day (REQ-ERR-001)', () {
      final result = _range(
        cityIn('Africa/Cairo'),
        CivilDate(2026, 1, 1),
        3,
        profile: testProfile.copyWith(
          elevationPolicy: HorizonElevationPolicy.aboveLocalTerrain,
        ),
      );
      expect(
        result,
        const Result<List<DayResult>, EngineFailure>.err(
          EngineFailure.unsupportedPolicy('horizon.elevationPolicy'),
        ),
      );
    });

    test('accepts 1 to 400 days and nothing past year 5999 as '
        'preconditions (§15 D47)', () {
      final cairo = cityIn('Africa/Cairo');
      expect(() => _range(cairo, CivilDate(2026, 1, 1), 0), throwsRangeError);
      expect(() => _range(cairo, CivilDate(2026, 1, 1), 401), throwsRangeError);
      expect(
        () => _range(cairo, CivilDate(5999, 12, 31), 2),
        throwsArgumentError,
      );
      expect(
        _range(cairo, CivilDate(5999, 12, 31), 1),
        isA<Ok<List<DayResult>, EngineFailure>>(),
      );
    });

    test('shares three of five SPA samples between consecutive days, with '
        'unchanged segments (REQ-PERF-001)', () {
      final city = cityIn('Europe/London');
      final cache = SunSampleCache();
      const days = 30;
      for (var i = 0; i < days; i++) {
        final day = CivilDate.fromEpochDay(CivilDate(2026, 5, 1).epochDay + i);
        CulminationSegments? locate(SunSampleCache? cache) =>
            CulminationSegments.locate(
              day: day,
              site: city.site,
              zoneId: city.zoneId,
              tzdb: testTzdb,
              cache: cache,
            );
        final cached = locate(cache);
        final fresh = locate(null);
        expect(cached?.upperUtcMs, fresh?.upperUtcMs);
        expect(cached?.lowerBeforeUtcMs, fresh?.lowerBeforeUtcMs);
        expect(cached?.lowerAfterUtcMs, fresh?.lowerAfterUtcMs);
      }
      expect(cache.length, 2 * days + 3);
    });
  });
}
