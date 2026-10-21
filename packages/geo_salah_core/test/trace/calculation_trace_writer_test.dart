import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';
import '../support/fixtures.dart';

CalculationTraceDocument _trace(String zoneId, CivilDate day) {
  final city = cityIn(zoneId);
  final result = calculateOk(city, day);
  return const CalculationTraceWriter().write(
    result,
    CalculationInputs.of(
      observer: observerOf(city),
      profile: testProfile,
      day: day,
      hijri: testHijri,
    ),
  );
}

void main() {
  group('CalculationTraceWriter', () {
    test('writes NO_EVENT times without instants and the others with raw, '
        'displayed and dayOffset (REQ-DOM-002)', () {
      final json = asJsonObject(
        jsonDecode(jsonEncode(_trace('Europe/Tromso', CivilDate(2026, 6, 21)))),
      );
      final times = asJsonList(json['times']).map(asJsonObject).toList();
      expect(times.map((t) => t['event']), [
        'FAJR',
        'SUNRISE',
        'DHUHR',
        'ASR',
        'MAGHRIB',
        'ISHA',
      ]);
      for (final time in times) {
        final noEvent = asJsonObject(time['origin'])['kind'] == 'NO_EVENT';
        for (final key in ['rawUtcMs', 'displayedUtcMs', 'dayOffset']) {
          expect(time.containsKey(key), !noEvent, reason: '$key in $time');
        }
      }
      expect(asJsonObject(times[1]['origin'])['reason'], 'POLAR_DAY');
    });

    test('writes the calculation inputs, provenance and ID of the day '
        '(§6.4 ¶11)', () {
      final trace = _trace('Africa/Cairo', CivilDate(2026, 3, 20));
      final inputs = CalculationInputs.of(
        observer: observerOf(cityIn('Africa/Cairo')),
        profile: testProfile,
        day: CivilDate(2026, 3, 20),
        hijri: testHijri,
      );
      expect(trace.inputs.toJson(), inputs.toJson());
      expect(trace.provenance.inputsHash, inputs.inputsHash);
      expect(trace.calculationId, matches(RegExp(r'^GS-[A-Z2-7]{16}$')));
      expect(trace.day, '2026-03-20');
      expect(trace.inputs.hijri.confidence, HijriConfidenceCode.expected);
    });

    test('carries only a ROUNDING step on the compared events Sunrise, '
        'Dhuhr and Maghrib (§15 D29, REQ-DOM-003)', () {
      final trace = _trace('Africa/Cairo', CivilDate(2026, 3, 20));
      const compared = {
        PrayerEventCode.sunrise,
        PrayerEventCode.dhuhr,
        PrayerEventCode.maghrib,
      };
      final times = trace.times.where((t) => compared.contains(t.event));
      expect(times, hasLength(3));
      for (final time in times) {
        expect(time.adjustmentTrace.map((s) => s.kind), [
          AdjustmentKindCode.rounding,
        ]);
        final step = time.adjustmentTrace.single;
        expect(step.event, time.event);
        expect(
          (time.rawUtcMs ?? 0) + step.deltaMs,
          time.displayedUtcMs,
        );
      }
    });

    test('round-trips through the calculation_trace.v1 model', () {
      final trace = _trace('Europe/Tromso', CivilDate(2026, 12, 21));
      final json = asJsonObject(jsonDecode(jsonEncode(trace)));
      expect(CalculationTraceDocument.fromJson(json), trace);
    });

    test('refuses a day without times, which the schema cannot hold', () {
      final result = calculateOk(
        cityIn('Africa/Cairo'),
        CivilDate(2026, 3, 20),
      );
      expect(
        () => const CalculationTraceWriter().write(
          result.copyWith(times: const []),
          CalculationInputs.of(
            observer: observerOf(cityIn('Africa/Cairo')),
            profile: testProfile,
            day: CivilDate(2026, 3, 20),
            hijri: testHijri,
          ),
        ),
        throwsArgumentError,
      );
    });
  });
}
