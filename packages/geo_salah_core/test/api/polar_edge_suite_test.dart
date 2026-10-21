import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';
import '../support/fixtures.dart';
import '../support/sites.dart';

/// The §6.7 polar edge cities (Appendix H coordinates; Utqiaġvik is the
/// test city in the Anchorage zone).
final Map<String, TestCity> _polar = {
  'Tromsø': cityIn('Europe/Tromso'),
  'Longyearbyen': cityIn('Arctic/Longyearbyen'),
  'Utqiaġvik': cityIn('America/Anchorage'),
};

/// Every day of 2026.
final List<CivilDate> _year = [
  for (var day = CivilDate(2026, 1, 1); day.year == 2026; day = day.plusDays(1))
    day,
];

/// The one day whose Asr shares Dhuhr's displayed minute (§15 D45, D58).
final CivilDate _tromsoAsrDay = CivilDate(2026, 11, 21);

const Set<PrayerEvent> _chainEvents = {
  PrayerEvent.imsak,
  PrayerEvent.fajr,
  PrayerEvent.isha,
};

void main() {
  group('polar edge suite (§6.7, S08 done-test)', () {
    final chainless = testProfile.copyWith(highLatitudeChain: const []);

    for (final MapEntry(key: name, value: city) in _polar.entries) {
      test('$name gives every time of 2026 a typed origin: a fallback only '
          'for Imsak, Fajr or Isha without a root, flagged and Estimated, and '
          'NO_EVENT with a polar reason otherwise (REQ-DOM-002, '
          'REQ-DOM-050)', () {
        final origins = <String>{};
        for (final day in _year) {
          final result = const CalculateDay()(
            observer: observerOf(city),
            profile: testProfile,
            day: day,
            tzdb: testTzdb,
            hijri: testHijri,
          );
          final DayResult value;
          switch (result) {
            case Ok(value: final ok):
              value = ok;
            case Err(:final failure):
              expect((city, day), (_polar['Tromsø'], _tromsoAsrDay));
              expect(failure, isA<OrderingViolation>());
              continue;
          }
          final ruleStep = calculateOk(city, day, profile: chainless);
          for (final time in value.times) {
            final reason = '$name $day ${time.event}';
            switch (time.origin) {
              case Primary():
                expect(time.displayedUtcMs, isNotNull, reason: reason);
                origins.add('PRIMARY');
              case Fallback(:final method):
                expect(_chainEvents, contains(time.event), reason: reason);
                expect(
                  timeOf(ruleStep, time.event).origin,
                  isA<NoEvent>(),
                  reason: reason,
                );
                expect(time.displayedUtcMs, isNotNull, reason: reason);
                expect(time.flags, contains(ResultFlag.highLatitudeFallback));
                expect(
                  time.confidence,
                  isA<Estimated>().having(
                    (label) => label.rangeMinutes,
                    'rangeMinutes',
                    greaterThanOrEqualTo(5),
                  ),
                  reason: reason,
                );
                origins.add('FALLBACK ${method.runtimeType}');
              case NoEvent(reason: final why):
                expect(time.displayedUtcMs, isNull, reason: reason);
                expect(_chainEvents, isNot(contains(time.event)));
                expect(
                  why,
                  isIn(const {
                    NoEventReason.polarDay,
                    NoEventReason.polarNight,
                    NoEventReason.asrUndefined,
                  }),
                  reason: reason,
                );
                origins.add('NO_EVENT ${why.code}');
            }
          }
        }

        // Midnight sun, polar night and both seed methods all occur.
        expect(
          origins,
          containsAll(<String>[
            'PRIMARY',
            'NO_EVENT POLAR_DAY',
            'NO_EVENT POLAR_NIGHT',
            'FALLBACK AnglePortion',
            'FALLBACK NearestLatitude',
          ]),
        );
      });
    }

    test('keeps Tromsø 2026-11-21 an orderingViolation: Asr has a root, so '
        'no fallback may replace it (REQ-DOM-001, REQ-DOM-002, §15 D58)', () {
      final result = const CalculateDay()(
        observer: observerOf(_polar['Tromsø']!), // SAFETY: a literal key.
        profile: testProfile,
        day: _tromsoAsrDay,
        tzdb: testTzdb,
        hijri: testHijri,
      );

      switch (result) {
        case Err(failure: OrderingViolation(:final traceJson)):
          final trace = CalculationTraceDocument.fromJson(
            asJsonObject(jsonDecode(traceJson)),
          );
          final asr = trace.times.singleWhere(
            (time) => time.event == PrayerEventCode.asr,
          );
          expect(asr.origin, const EventOriginDocument.primary());
        case Ok() || Err():
          fail('Expected orderingViolation, got $result');
      }
    });
  });
}
