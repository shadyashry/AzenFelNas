import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:glados/glados.dart';

import '../support/engine_fixtures.dart';
import '../support/fake_tz_database.dart';
import '../support/fixtures.dart';
import '../support/sites.dart';

/// Epoch days of 2026-01-01 … 2028-12-31 (the lab reference years).
final Generator<int> _days = any.intInRange(20454, 21550);
final Generator<int> _cityIndex = any.intInRange(0, testCities.length);

int _raw(PrayerTime time) => switch (time.rawUtcMs) {
  final int raw => raw,
  null => throw StateError('No instant for $time'),
};

int _displayed(PrayerTime time) => switch (time.displayedUtcMs) {
  final int displayed => displayed,
  null => throw StateError('No instant for $time'),
};

List<AdjustmentStep> _stepsOf(DayResult result, PrayerEvent event) => [
  for (final step in result.provenance.adjustmentTrace)
    if (step.event == event) step,
];

Result<DayResult, EngineFailure> _calculate(
  PrayerProfile profile, {
  String zoneId = 'Africa/Cairo',
  CivilDate? day,
  TzDatabase? tzdb,
  ObserverSource source = ObserverSource.benchmark,
}) {
  final city = cityIn(zoneId);
  return const CalculateDay()(
    observer: Observer(
      latitudeDeg: city.site.latitudeDeg,
      longitudeDeg: city.site.longitudeDeg,
      zoneId: zoneId,
      source: source,
    ),
    profile: profile,
    day: day ?? CivilDate(2026, 3, 20),
    tzdb: tzdb ?? testTzdb,
    hijri: testHijri,
  );
}

DayResult _ok(Result<DayResult, EngineFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('Unexpected $failure'),
};

/// A pair of consecutive timed events whose displayed instants break
/// REQ-DOM-001, read back from a trace.
bool _traceBreaksOrder(String traceJson) {
  final trace = asJsonObject(jsonDecode(traceJson));
  final displayed = [
    for (final time in asJsonList(trace['times']).map(asJsonObject))
      if (time['displayedUtcMs'] case final int ms) (time['event'], ms),
  ];
  for (var i = 1; i < displayed.length; i++) {
    final (earlier, earlierMs) = displayed[i - 1];
    final (later, laterMs) = displayed[i];
    final mayTie = earlier == 'IMSAK' && later == 'FAJR';
    if (earlierMs > laterMs || (earlierMs == laterMs && !mayTie)) return true;
  }
  return false;
}

void main() {
  group('rounding (ADR-005, REQ-DOM-003)', () {
    Glados2(_cityIndex, _days).test(
      'rounds each timed event exactly once, as its last step, and keeps '
      'the raw instant the rule instant (REQ-DOM-003)',
      (index, epochDay) {
        final city = testCities[index];
        final result = calculateOk(city, CivilDate.fromEpochDay(epochDay));
        for (final time in result.times) {
          final steps = _stepsOf(result, time.event);
          if (time.origin is NoEvent) {
            expect(steps, isEmpty);
            continue;
          }
          expect(steps.map((s) => s.kind), [AdjustmentKind.rounding]);
          expect(_raw(time) + steps.single.deltaMs, _displayed(time));
          expect(
            (_displayed(time) + city.offsetSeconds * 1000) % 60000,
            0,
            reason: '${time.event} is on a local minute boundary',
          );
        }
      },
    );

    Glados2(_cityIndex, _days).test(
      'applies the profile mode per event: Sunrise down, the others up, '
      'each within a minute (ADR-005)',
      (index, epochDay) {
        final result = calculateOk(
          testCities[index],
          CivilDate.fromEpochDay(epochDay),
        );
        for (final time in result.times) {
          if (time.origin is NoEvent) continue;
          final mode =
              testProfile.roundingOverrides[time.event] ??
              testProfile.roundingDefault;
          final delta = _displayed(time) - _raw(time);
          switch (mode) {
            case RoundingMode.ceil:
              expect(delta, inInclusiveRange(0, 59999));
            case RoundingMode.floor:
              expect(delta, inInclusiveRange(-59999, 0));
            case RoundingMode.nearest:
              expect(delta, inInclusiveRange(-29999, 30000));
          }
        }
      },
    );

    Glados2(_cityIndex, _days).test(
      'flags nearRoundingBoundary exactly when the raw instant is within '
      '500 ms of a minute boundary (ADR-005)',
      (index, epochDay) {
        final city = testCities[index];
        final result = calculateOk(city, CivilDate.fromEpochDay(epochDay));
        for (final time in result.times) {
          if (time.origin is NoEvent) continue;
          final intoMinute = (_raw(time) + city.offsetSeconds * 1000) % 60000;
          expect(
            time.flags.contains(ResultFlag.nearRoundingBoundary),
            intoMinute < 500 || 60000 - intoMinute < 500,
          );
        }
      },
    );

    test('never feeds a rounded instant into another calculation: an '
        "interval from Maghrib ignores Maghrib's rounding (REQ-DOM-003)", () {
      int ishaRaw(RoundingMode maghribMode) => _raw(
        timeOf(
          _ok(
            _calculate(
              testProfile.copyWith(
                rules: {
                  PrayerEvent.maghrib: const EventRule.horizon(),
                  PrayerEvent.isha: const EventRule.intervalAfter(
                    base: PrayerEvent.maghrib,
                    duration: Duration(minutes: 77),
                  ),
                },
                roundingOverrides: {PrayerEvent.maghrib: maghribMode},
              ),
            ),
          ),
          PrayerEvent.isha,
        ),
      );
      final raws = {for (final mode in RoundingMode.values) ishaRaw(mode)};
      expect(raws, hasLength(1));
    });
  });

  group('per-event offsets (§6.4 ¶8)', () {
    test('adds the minutes before rounding, logs them first and keeps the '
        'raw instant', () {
      final base = _ok(_calculate(testProfile));
      final shifted = _ok(
        _calculate(
          testProfile.copyWith(
            perEventMinutes: {PrayerEvent.isha: 2},
            maxAbsMinutes: 3,
          ),
        ),
      );
      final before = timeOf(base, PrayerEvent.isha);
      final after = timeOf(shifted, PrayerEvent.isha);
      expect(_raw(after), _raw(before));
      expect(_displayed(after) - _displayed(before), 120000);
      expect(_stepsOf(shifted, PrayerEvent.isha).map((s) => s.kind), [
        AdjustmentKind.perEventOffset,
        AdjustmentKind.rounding,
      ]);
      expect(_stepsOf(shifted, PrayerEvent.isha).first.deltaMs, 120000);
      expect(
        timeOf(shifted, PrayerEvent.maghrib),
        timeOf(base, PrayerEvent.maghrib),
      );
    });

    test('returns invalidProfile for an offset beyond maxAbsMinutes '
        '(REQ-ERR-001)', () {
      final result = _calculate(
        testProfile.copyWith(
          perEventMinutes: {PrayerEvent.fajr: -4},
          maxAbsMinutes: 3,
        ),
      );
      expect(result, isA<Err<DayResult, EngineFailure>>());
      if (result case Err(:final failure)) {
        expect(failure, isA<InvalidProfile>());
      }
    });
  });

  group('ordering guard (REQ-DOM-001)', () {
    Glados2(_cityIndex, _days).test(
      'returns days whose displayed instants keep the prayer order, and '
      'orderingViolation only for days that break it (REQ-DOM-001)',
      (index, epochDay) {
        final result = const CalculateDay()(
          observer: observerOf(testCities[index]),
          profile: testProfile,
          day: CivilDate.fromEpochDay(epochDay),
          tzdb: testTzdb,
          hijri: testHijri,
        );
        switch (result) {
          case Ok(:final value):
            final displayed = [
              for (final time in value.times)
                if (time.displayedUtcMs case final int ms) ms,
            ];
            for (var i = 1; i < displayed.length; i++) {
              expect(displayed[i], greaterThan(displayed[i - 1]));
            }
          case Err(failure: OrderingViolation(:final traceJson)):
            expect(_traceBreaksOrder(traceJson), isTrue);
          case Err(:final failure):
            fail('Unexpected $failure');
        }
      },
    );

    test('returns orderingViolation with the day trace when Asr and Dhuhr '
        'share a displayed minute (Tromsø, 2026-11-21)', () {
      final result = _calculate(
        testProfile,
        zoneId: 'Europe/Tromso',
        day: CivilDate(2026, 11, 21),
      );
      expect(result, isA<Err<DayResult, EngineFailure>>());
      if (result case Err(:final failure)) {
        expect(failure.code, FailureCode.engineOrdering);
        if (failure case OrderingViolation(:final traceJson)) {
          final trace = CalculationTraceDocument.fromJson(
            asJsonObject(jsonDecode(traceJson)),
          );
          final byEvent = {for (final t in trace.times) t.event: t};
          expect(
            byEvent[PrayerEventCode.asr]?.displayedUtcMs,
            byEvent[PrayerEventCode.dhuhr]?.displayedUtcMs,
          );
          expect(_traceBreaksOrder(traceJson), isTrue);
        }
      }
    });

    test('allows Imsak to share its displayed minute with Fajr and rejects '
        'the same tie between Fajr and Sunrise', () {
      final imsakTie = _calculate(
        testProfile.copyWith(
          rules: {
            PrayerEvent.imsak: const EventRule.horizon(),
            PrayerEvent.fajr: const EventRule.horizon(),
          },
          roundingOverrides: const {},
        ),
      );
      expect(imsakTie, isA<Ok<DayResult, EngineFailure>>());
      final fajrTie = _calculate(
        testProfile.copyWith(
          rules: {
            PrayerEvent.fajr: const EventRule.horizon(),
            PrayerEvent.sunrise: const EventRule.horizon(),
          },
          roundingOverrides: const {},
        ),
      );
      expect(fajrTie, isA<Err<DayResult, EngineFailure>>());
      if (fajrTie case Err(:final failure)) {
        expect(failure, isA<OrderingViolation>());
      }
    });
  });

  group('confidence (REQ-DOM-050)', () {
    test('labels primary times of an approved government profile with a '
        'benchmark report Authority aligned and missing ones Unknown', () {
      final result = _ok(
        _calculate(
          testProfile.copyWith(
            status: ProfileStatus.approved,
            authorityType: AuthorityType.government,
            benchmarkReportId: 'zz-report-1',
          ),
          zoneId: 'Europe/London',
          day: CivilDate(2026, 6, 21),
        ),
      );
      expect(
        timeOf(result, PrayerEvent.dhuhr).confidence,
        const ConfidenceLabel.authorityAligned(
          benchmarkReportId: 'zz-report-1',
        ),
      );
      expect(
        timeOf(result, PrayerEvent.isha).confidence,
        const ConfidenceLabel.unknown(reasonCode: 'TWILIGHT_ABSENT'),
      );
    });

    test('labels the engine.default stand-in Calculated', () {
      final result = _ok(_calculate(testProfile));
      for (final time in result.times) {
        expect(time.confidence, const ConfidenceLabel.calculated());
      }
    });
  });

  group('day flags (§15 D44)', () {
    test('flags every time of a day with a UTC-offset transition '
        'dstTransitionDay, and not the days around it', () {
      // Cairo moves from UTC+2 to UTC+3 at 2026-03-20T10:00Z (fake).
      final tzdb = FakeTzDatabase.switching(
        {for (final city in testCities) city.zoneId: city.offsetSeconds},
        switchUtcMs: DateTime.utc(2026, 3, 20, 10).millisecondsSinceEpoch,
        offsetAfterSeconds: {
          for (final city in testCities) city.zoneId: city.offsetSeconds + 3600,
        },
      );
      bool flagged(CivilDate day) =>
          _ok(_calculate(testProfile, day: day, tzdb: tzdb)).times
              .every((t) => t.flags.contains(ResultFlag.dstTransitionDay));
      bool anyFlagged(CivilDate day) =>
          _ok(_calculate(testProfile, day: day, tzdb: tzdb)).times.any(
            (t) => t.flags.contains(ResultFlag.dstTransitionDay),
          );
      expect(flagged(CivilDate(2026, 3, 20)), isTrue);
      expect(anyFlagged(CivilDate(2026, 3, 19)), isFalse);
      expect(anyFlagged(CivilDate(2026, 3, 21)), isFalse);
    });

    test('flags every time of a manual place manualCoordinateResolution', () {
      final manual = _ok(
        _calculate(testProfile, source: ObserverSource.manual),
      );
      final benchmark = _ok(_calculate(testProfile));
      expect(
        manual.times.every(
          (t) => t.flags.contains(ResultFlag.manualCoordinateResolution),
        ),
        isTrue,
      );
      expect(
        benchmark.times.any(
          (t) => t.flags.contains(ResultFlag.manualCoordinateResolution),
        ),
        isFalse,
      );
    });
  });
}
