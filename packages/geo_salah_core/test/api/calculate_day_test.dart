import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:glados/glados.dart';

import '../support/engine_fixtures.dart';
import '../support/fake_tz_database.dart';
import '../support/sites.dart';

/// Epoch days of 2026-01-01 … 2028-12-31 (the lab reference years).
final Generator<int> _days = any.intInRange(20454, 21550);
final Generator<int> _cityIndex = any.intInRange(0, testCities.length);

/// ADR-003's sunrise/sunset altitude with the §6.2 defaults: −(34′ + 16′).
const double _horizonDeg = -50 / 60;

CulminationSegments _segments(TestCity city, CivilDate day) =>
    switch (CulminationSegments.locate(
      day: day,
      site: city.site,
      zoneId: city.zoneId,
      tzdb: testTzdb,
    )) {
      final CulminationSegments segments => segments,
      null => throw StateError('No segments for $day'),
    };

int _raw(PrayerTime time) => switch (time.rawUtcMs) {
  final int raw => raw,
  null => throw StateError('No instant for $time'),
};

Result<DayResult, EngineFailure> _calculate(
  PrayerProfile profile, {
  CivilDate? day,
}) => const CalculateDay()(
  observer: observerOf(cityIn('Africa/Cairo')),
  profile: profile,
  day: day ?? CivilDate(2026, 3, 20),
  tzdb: testTzdb,
  hijri: testHijri,
);

void main() {
  group('CalculateDay', () {
    Glados2(_cityIndex, _days).test(
      'places Dhuhr at the upper transit T₀ whose local date is D '
      '(REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        final dhuhr = timeOf(calculateOk(city, day), PrayerEvent.dhuhr);
        expect(dhuhr.origin, const EventOrigin.primary());
        expect(_raw(dhuhr), _segments(city, day).upperUtcMs.floor());
      },
    );

    Glados2(_cityIndex, _days).test(
      'finds Sunrise rising through the horizon in [A₋, T₀] and Maghrib '
      'setting in [T₀, A₊] (REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        final result = calculateOk(city, day);
        final segments = _segments(city, day);
        final exact = ExactSun(city.site);
        final sunrise = timeOf(result, PrayerEvent.sunrise);
        final maghrib = timeOf(result, PrayerEvent.maghrib);
        if (sunrise.origin case Primary()) {
          final raw = _raw(sunrise).toDouble();
          expect(
            raw,
            inInclusiveRange(segments.lowerBeforeUtcMs, segments.upperUtcMs),
          );
          expect(
            exact.altitudeDeg(raw + 1000),
            greaterThan(exact.altitudeDeg(raw - 1000)),
          );
        }
        if (maghrib.origin case Primary()) {
          final raw = _raw(maghrib).toDouble();
          expect(
            raw,
            inInclusiveRange(segments.upperUtcMs, segments.lowerAfterUtcMs),
          );
          expect(
            exact.altitudeDeg(raw + 1000),
            lessThan(exact.altitudeDeg(raw - 1000)),
          );
        }
      },
    );

    Glados2(_cityIndex, _days).test(
      'solves the horizon rule at −(34′ + 16′) geometric altitude with no '
      'dip and no refraction model (ADR-003)',
      (index, epochDay) {
        final city = testCities[index];
        final result = calculateOk(city, CivilDate.fromEpochDay(epochDay));
        final exact = ExactSun(city.site);
        for (final event in [PrayerEvent.sunrise, PrayerEvent.maghrib]) {
          final time = timeOf(result, event);
          if (time.origin is! Primary) continue;
          final raw = _raw(time).toDouble();
          final rate =
              (exact.altitudeDeg(raw + 500) - exact.altitudeDeg(raw - 500))
                  .abs() /
              1000;
          // Truncation to 1 ms moves the altitude by at most one ms of rate.
          expect(exact.altitudeDeg(raw), closeTo(_horizonDeg, 1e-5 + rate));
        }
      },
    );

    Glados2(_cityIndex, _days).test(
      'gives every time a typed origin: PRIMARY with all instants or '
      'NO_EVENT with none, never a fallback where a root exists '
      '(REQ-DOM-002)',
      (index, epochDay) {
        final result = calculateOk(
          testCities[index],
          CivilDate.fromEpochDay(epochDay),
        );
        expect(result.times.map((t) => t.event), [
          PrayerEvent.sunrise,
          PrayerEvent.dhuhr,
          PrayerEvent.maghrib,
        ]);
        for (final time in result.times) {
          switch (time.origin) {
            case Primary():
              expect(time.rawUtcMs, isNotNull);
              expect(time.displayedUtcMs, isNotNull);
              expect(time.dayOffset, isNotNull);
            case NoEvent():
              expect(time.rawUtcMs, isNull);
              expect(time.displayedUtcMs, isNull);
              expect(time.dayOffset, isNull);
            case Fallback():
              fail('S05 has no fallback: $time');
          }
        }
      },
    );

    test('types the midnight sun at Tromsø as NO_EVENT(polarDay) for '
        'Sunrise and Maghrib, with Dhuhr still primary (REQ-DOM-002)', () {
      final result = calculateOk(
        cityIn('Europe/Tromso'),
        CivilDate(2026, 6, 21),
      );
      expect(
        timeOf(result, PrayerEvent.sunrise).origin,
        const EventOrigin.noEvent(NoEventReason.polarDay),
      );
      expect(
        timeOf(result, PrayerEvent.dhuhr).origin,
        const EventOrigin.primary(),
      );
      expect(
        timeOf(result, PrayerEvent.maghrib).origin,
        const EventOrigin.noEvent(NoEventReason.polarDay),
      );
    });

    test('types the polar night at Tromsø as NO_EVENT(polarNight) for '
        'Sunrise and Maghrib (REQ-DOM-002)', () {
      final result = calculateOk(
        cityIn('Europe/Tromso'),
        CivilDate(2026, 12, 21),
      );
      expect(
        timeOf(result, PrayerEvent.sunrise).origin,
        const EventOrigin.noEvent(NoEventReason.polarNight),
      );
      expect(
        timeOf(result, PrayerEvent.dhuhr).origin,
        const EventOrigin.primary(),
      );
      expect(
        timeOf(result, PrayerEvent.maghrib).origin,
        const EventOrigin.noEvent(NoEventReason.polarNight),
      );
    });

    test('labels a primary time Calculated and a missing one '
        'Unknown(reason) (REQ-DOM-050)', () {
      final result = calculateOk(
        cityIn('Europe/Tromso'),
        CivilDate(2026, 6, 21),
      );
      expect(
        timeOf(result, PrayerEvent.dhuhr).confidence,
        const ConfidenceLabel.calculated(),
      );
      expect(
        timeOf(result, PrayerEvent.sunrise).confidence,
        const ConfidenceLabel.unknown(reasonCode: 'POLAR_DAY'),
      );
    });

    Glados2(_cityIndex, _days).test(
      'repeats bit-identical results for identical inputs (REQ-DOM-004)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        expect(calculateOk(city, day), calculateOk(city, day));
      },
    );

    Glados2(_cityIndex, _days).test(
      'keeps raw instants independent of the zone offset, which only '
      'selects the day (REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        final shifted = FakeTzDatabase({
          city.zoneId: city.offsetSeconds + 3600,
        });
        List<int?> raws(DayResult result) => [
          for (final t in result.times) t.rawUtcMs,
        ];
        expect(
          raws(calculateOk(city, day, tzdb: shifted)),
          raws(calculateOk(city, day)),
        );
      },
    );

    test('calculates at the coordinates rounded to 6 decimals, so equal '
        'inputs hashes give equal raw instants (REQ-DOM-004)', () {
      Observer at(double lat) => Observer(
        latitudeDeg: lat,
        longitudeDeg: 31.24,
        zoneId: 'Africa/Cairo',
        source: ObserverSource.manual,
      );
      DayResult calculate(double lat) => switch (const CalculateDay()(
        observer: at(lat),
        profile: testProfile,
        day: CivilDate(2026, 3, 20),
        tzdb: testTzdb,
        hijri: testHijri,
      )) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError('$failure'),
      };
      final a = calculate(30.04);
      final b = calculate(30.0400004);
      expect(b.provenance.inputsHash, a.provenance.inputsHash);
      expect(b.calculationId, a.calculationId);
      expect(b.times, a.times);
    });

    test('derives dayOffset from the TZDB: a Maghrib after local midnight '
        'is +1', () {
      // London's Sun in a zone 11 h ahead: T₀ ≈ 23:07 local on D, sunset
      // ≈ 05:13 local on D + 1.
      final london = cityIn('Europe/London');
      final tzdb = FakeTzDatabase({london.zoneId: 11 * 3600});
      final result = calculateOk(london, CivilDate(2026, 3, 20), tzdb: tzdb);
      expect(timeOf(result, PrayerEvent.sunrise).dayOffset, 0);
      expect(timeOf(result, PrayerEvent.dhuhr).dayOffset, 0);
      expect(timeOf(result, PrayerEvent.maghrib).dayOffset, 1);
    });

    test('adds the transit rule offset to Dhuhr', () {
      final base = calculateOk(cityIn('Africa/Cairo'), CivilDate(2026, 3, 20));
      final offset = calculateOk(
        cityIn('Africa/Cairo'),
        CivilDate(2026, 3, 20),
        profile: testProfile.copyWith(
          rules: {
            ...testProfile.rules,
            PrayerEvent.dhuhr: const EventRule.transit(
              offset: Duration(minutes: 2),
            ),
          },
        ),
      );
      expect(
        _raw(timeOf(offset, PrayerEvent.dhuhr)) -
            _raw(timeOf(base, PrayerEvent.dhuhr)),
        inInclusiveRange(119999, 120001),
      );
    });

    test('takes refraction and semidiameter from the horizon rule '
        '(ADR-003)', () {
      final city = cityIn('Africa/Cairo');
      final result = calculateOk(
        city,
        CivilDate(2026, 3, 20),
        profile: testProfile.copyWith(
          rules: {
            PrayerEvent.sunrise: const EventRule.horizon(
              refractionArcmin: 0,
              semidiameterArcmin: 0,
            ),
          },
        ),
      );
      final raw = _raw(timeOf(result, PrayerEvent.sunrise)).toDouble();
      expect(ExactSun(city.site).altitudeDeg(raw), closeTo(0, 1e-4));
    });

    test('returns unsupportedPolicy for a [DEFERRED V2] elevation policy '
        '(ADR-003, REQ-ERR-001)', () {
      for (final policy in [
        HorizonElevationPolicy.aboveLocalTerrain,
        HorizonElevationPolicy.authorityTable,
      ]) {
        final result = _calculate(
          testProfile.copyWith(elevationPolicy: policy),
        );
        expect(
          result,
          const Result<DayResult, EngineFailure>.err(
            EngineFailure.unsupportedPolicy('horizon.elevationPolicy'),
          ),
        );
      }
    });

    test('returns invalidProfile for a rule the event cannot use '
        '(REQ-ERR-001)', () {
      for (final rules in [
        {PrayerEvent.dhuhr: const EventRule.horizon()},
        {PrayerEvent.sunrise: const EventRule.transit()},
      ]) {
        final result = _calculate(testProfile.copyWith(rules: rules));
        expect(result, isA<Err<DayResult, EngineFailure>>());
        if (result case Err(:final failure)) {
          expect(failure, isA<InvalidProfile>());
          expect(failure.code, FailureCode.profileInvalid);
        }
      }
    });

    test('returns a day without times for a calendar day the zone skipped '
        '(Pacific/Apia 2011-12-30, §15 D36)', () {
      // Apia moved from UTC−10 to UTC+14 at 2011-12-30T10:00Z.
      final tzdb = FakeTzDatabase.switching(
        const {'Pacific/Apia': -10 * 3600},
        switchUtcMs: DateTime.utc(2011, 12, 30, 10).millisecondsSinceEpoch,
        offsetAfterSeconds: const {'Pacific/Apia': 14 * 3600},
      );
      final apia = (
        zoneId: 'Pacific/Apia',
        site: TopocentricSite.of(latitudeDeg: -13.83, longitudeDeg: -171.76),
        offsetSeconds: 14 * 3600,
      );
      expect(
        calculateOk(apia, CivilDate(2011, 12, 30), tzdb: tzdb).times,
        isEmpty,
      );
      expect(
        calculateOk(apia, CivilDate(2011, 12, 31), tzdb: tzdb).times,
        hasLength(3),
      );
    });

    test('rejects a day after year 5999 as a precondition (§15 D36)', () {
      expect(
        () => _calculate(testProfile, day: CivilDate(6000, 1, 1)),
        throwsArgumentError,
      );
    });

    test('records the provenance of the day (REQ-TIME-020)', () {
      final result = calculateOk(
        cityIn('Africa/Cairo'),
        CivilDate(2026, 3, 20),
      );
      expect(
        result.provenance,
        Provenance(
          engineVersion: EngineVersion.current,
          deltaTModel: 'espenak-meeus-2006',
          profileId: 'engine.default',
          profileVersion: '0000.0.0',
          tzdbVersion: testTzdb.version,
          inputsHash: result.provenance.inputsHash,
          hijriConfidence: HijriConfidence.expected,
          adjustmentTrace: const [],
        ),
      );
      expect(result.calculationId, matches(RegExp(r'^GS-[A-Z2-7]{16}$')));
    });
  });
}
