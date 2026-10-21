import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/astro/exact_sun.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/rules/shadow_rule_solver.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:glados/glados.dart';

import '../support/engine_fixtures.dart';
import '../support/sites.dart';

/// Epoch days of 2026-01-01 … 2028-12-31 (the lab reference years).
final Generator<int> _days = any.intInRange(20454, 21550);
final Generator<int> _cityIndex = any.intInRange(0, testCities.length);

/// Interval test vectors: arbitrary durations, not profile values.
const Duration _after = Duration(minutes: 77);
const Duration _before = Duration(minutes: 13);

/// A site near the pole, in Longyearbyen's zone, where the Sun stays below
/// −18° in December and above it in June.
final TestCity _nearPole = (
  zoneId: 'Arctic/Longyearbyen',
  site: TopocentricSite.of(latitudeDeg: 88.5, longitudeDeg: 15.63),
  offsetSeconds: 3600,
);

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

double _depressionOf(PrayerEvent event) => switch (testProfile.rules[event]) {
  SolarAltitudeRule(:final degrees) => degrees,
  final rule => throw StateError('$event is not an altitude rule: $rule'),
};

int _kOf(PrayerEvent event) => switch (testProfile.rules[event]) {
  ShadowFactorRule(:final k) => k,
  final rule => throw StateError('$event is not a shadow rule: $rule'),
};

/// The altitude tolerance at [raw]: interpolation (1e-5°) plus one ms of
/// altitude rate, for the truncation to 1 ms.
double _tolerance(ExactSun exact, double raw) =>
    1e-5 +
    (exact.altitudeDeg(raw + 500) - exact.altitudeDeg(raw - 500)).abs() / 1000;

Result<DayResult, EngineFailure> _calculate(
  Map<PrayerEvent, EventRule> rules,
) => const CalculateDay()(
  observer: observerOf(cityIn('Africa/Cairo')),
  profile: testProfile.copyWith(rules: rules),
  day: CivilDate(2026, 3, 20),
  tzdb: testTzdb,
  hijri: testHijri,
);

void main() {
  group('solarAltitude rule (ADR-003, ADR-004)', () {
    Glados2(_cityIndex, _days).test(
      'finds Fajr rising through −α in [A₋, T₀] and Isha setting through '
      '−α in [T₀, A₊], with no refraction and no dip (REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        final result = calculateOk(city, day);
        final segments = _segments(city, day);
        final exact = ExactSun(city.site);
        for (final (event, lower, upper, rising) in [
          (
            PrayerEvent.fajr,
            segments.lowerBeforeUtcMs,
            segments.upperUtcMs,
            true,
          ),
          (
            PrayerEvent.isha,
            segments.upperUtcMs,
            segments.lowerAfterUtcMs,
            false,
          ),
        ]) {
          final time = timeOf(result, event);
          if (time.origin is! Primary) continue;
          final raw = _raw(time).toDouble();
          expect(raw, inInclusiveRange(lower, upper));
          expect(
            exact.altitudeDeg(raw),
            closeTo(-_depressionOf(event), _tolerance(exact, raw)),
          );
          expect(
            exact.altitudeDeg(raw + 1000) > exact.altitudeDeg(raw - 1000),
            rising,
          );
        }
      },
    );

    test('types a Sun that never rises to −α as NO_EVENT(polarNight) '
        '(REQ-DOM-002)', () {
      final result = calculateOk(_nearPole, CivilDate(2026, 12, 21));
      for (final event in [PrayerEvent.fajr, PrayerEvent.isha]) {
        expect(
          timeOf(result, event).origin,
          const EventOrigin.noEvent(NoEventReason.polarNight),
        );
        expect(
          timeOf(result, event).confidence,
          const ConfidenceLabel.unknown(reasonCode: 'POLAR_NIGHT'),
        );
      }
    });

    test('types a Sun that never sinks to −α as NO_EVENT(twilightAbsent), '
        'never a fallback (REQ-DOM-002)', () {
      final result = calculateOk(
        cityIn('Europe/London'),
        CivilDate(2026, 6, 21),
      );
      for (final event in [PrayerEvent.fajr, PrayerEvent.isha]) {
        expect(
          timeOf(result, event).origin,
          const EventOrigin.noEvent(NoEventReason.twilightAbsent),
        );
      }
      expect(
        timeOf(result, PrayerEvent.sunrise).origin,
        const EventOrigin.primary(),
      );
    });
  });

  group('shadowFactor rule (§6.4 ¶6)', () {
    Glados2(_cityIndex, _days).test(
      'finds Asr setting through arccot(k + tan|φ − δ(T₀)|) between Dhuhr '
      'and A₊ (REQ-TIME-002)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        final result = calculateOk(city, day);
        final asr = timeOf(result, PrayerEvent.asr);
        if (asr.origin is! Primary) return;
        final segments = _segments(city, day);
        final exact = ExactSun(city.site);
        final raw = _raw(asr).toDouble();
        final target = ShadowRuleSolver.targetDeg(
          k: _kOf(PrayerEvent.asr),
          zenithDeg: (city.site.latitudeDeg - segments.upperDeclinationDeg)
              .abs(),
        );
        if (target == null) fail('Primary Asr without a target on $day');
        expect(exact.altitudeDeg(raw), closeTo(target, _tolerance(exact, raw)));
        expect(exact.altitudeDeg(raw + 1000), lessThan(exact.altitudeDeg(raw)));
        expect(_raw(timeOf(result, PrayerEvent.dhuhr)), lessThan(raw));
        expect(raw, lessThanOrEqualTo(segments.lowerAfterUtcMs));
        final maghrib = timeOf(result, PrayerEvent.maghrib);
        if (maghrib.origin is Primary) {
          expect(raw, lessThan(_raw(maghrib)));
        }
      },
    );

    test('gives the shadow ratio target from the formula: k = 1 at a 45° '
        'noon zenith distance is arccot 2', () {
      expect(
        ShadowRuleSolver.targetDeg(k: 1, zenithDeg: 45),
        closeTo(26.565051177, 1e-9),
      );
      expect(
        ShadowRuleSolver.targetDeg(k: 2, zenithDeg: 0),
        closeTo(26.565051177, 1e-9),
      );
    });

    test('types Asr as NO_EVENT(asrUndefined) when 90° − |φ − δ| ≤ 0 '
        '(§6.4 ¶6, REQ-DOM-002)', () {
      expect(ShadowRuleSolver.targetDeg(k: 1, zenithDeg: 90), isNull);
      final result = calculateOk(
        cityIn('Europe/Tromso'),
        CivilDate(2026, 12, 21),
      );
      expect(
        timeOf(result, PrayerEvent.asr).origin,
        const EventOrigin.noEvent(NoEventReason.asrUndefined),
      );
      expect(
        timeOf(result, PrayerEvent.asr).confidence,
        const ConfidenceLabel.unknown(reasonCode: 'ASR_UNDEFINED'),
      );
    });

    test('types an Asr altitude the Sun never sinks to as '
        'NO_EVENT(polarDay) (REQ-DOM-002)', () {
      final result = calculateOk(_nearPole, CivilDate(2026, 6, 21));
      expect(
        timeOf(result, PrayerEvent.asr).origin,
        const EventOrigin.noEvent(NoEventReason.polarDay),
      );
    });
  });

  group('interval rules', () {
    final intervalProfile = testProfile.copyWith(
      rules: {
        ...testProfile.rules,
        PrayerEvent.imsak: const EventRule.intervalBefore(
          base: PrayerEvent.fajr,
          duration: _before,
        ),
        PrayerEvent.isha: const EventRule.intervalAfter(
          base: PrayerEvent.maghrib,
          duration: _after,
        ),
      },
    );

    Glados2(_cityIndex, _days).test(
      'places intervalAfter after and intervalBefore before the base raw '
      'instant, or gives no time with the base reason (REQ-DOM-002, '
      'REQ-DOM-003)',
      (index, epochDay) {
        final result = calculateOk(
          testCities[index],
          CivilDate.fromEpochDay(epochDay),
          profile: intervalProfile,
        );
        for (final (event, base, offset) in [
          (PrayerEvent.imsak, PrayerEvent.fajr, -_before),
          (PrayerEvent.isha, PrayerEvent.maghrib, _after),
        ]) {
          final time = timeOf(result, event);
          final baseTime = timeOf(result, base);
          switch (baseTime.origin) {
            case Primary():
              expect(time.origin, const EventOrigin.primary());
              expect(
                _raw(time) - _raw(baseTime),
                offset.inMilliseconds,
              );
            case final NoEvent noEvent:
              expect(time.origin, noEvent);
            case Fallback():
              fail('No fallback before S08');
          }
        }
      },
    );

    test('returns invalidProfile for an interval without a solved base, a '
        'misplaced base or a non-positive duration (REQ-ERR-001)', () {
      const minute = Duration(minutes: 1);
      for (final rules in <Map<PrayerEvent, EventRule>>[
        {
          PrayerEvent.isha: const EventRule.intervalAfter(
            base: PrayerEvent.maghrib,
            duration: minute,
          ),
        },
        {
          PrayerEvent.maghrib: const EventRule.horizon(),
          PrayerEvent.isha: const EventRule.intervalAfter(
            base: PrayerEvent.imsak,
            duration: minute,
          ),
          PrayerEvent.imsak: const EventRule.intervalBefore(
            base: PrayerEvent.fajr,
            duration: minute,
          ),
        },
        {
          PrayerEvent.fajr: const EventRule.horizon(),
          PrayerEvent.isha: const EventRule.intervalBefore(
            base: PrayerEvent.fajr,
            duration: minute,
          ),
        },
        {
          PrayerEvent.maghrib: const EventRule.horizon(),
          PrayerEvent.isha: const EventRule.intervalAfter(
            base: PrayerEvent.maghrib,
            duration: Duration.zero,
          ),
        },
        {
          PrayerEvent.maghrib: const EventRule.horizon(),
          PrayerEvent.isha: EventRule.intervalAfter(
            base: PrayerEvent.maghrib,
            duration: -minute,
          ),
        },
      ]) {
        final result = _calculate(rules);
        expect(result, isA<Err<DayResult, EngineFailure>>(), reason: '$rules');
        if (result case Err(:final failure)) {
          expect(failure, isA<InvalidProfile>(), reason: '$rules');
        }
      }
    });
  });

  test('returns invalidProfile for a rule the event cannot use or a value '
      'outside its domain (REQ-ERR-001)', () {
    for (final rules in <Map<PrayerEvent, EventRule>>[
      {PrayerEvent.fajr: const EventRule.shadowFactor(k: 1)},
      {PrayerEvent.dhuhr: const EventRule.solarAltitude(degrees: 10)},
      {PrayerEvent.dhuhr: const EventRule.shadowFactor(k: 1)},
      {PrayerEvent.isha: const EventRule.solarAltitude(degrees: 0)},
      {PrayerEvent.isha: const EventRule.solarAltitude(degrees: 90)},
      {PrayerEvent.asr: const EventRule.shadowFactor(k: 0)},
    ]) {
      final result = _calculate(rules);
      expect(result, isA<Err<DayResult, EngineFailure>>(), reason: '$rules');
      if (result case Err(:final failure)) {
        expect(failure.code, FailureCode.profileInvalid, reason: '$rules');
      }
    }
  });
}
