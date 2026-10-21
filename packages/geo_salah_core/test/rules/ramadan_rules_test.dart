import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';
import '../support/fixtures.dart';
import '../support/sites.dart';

/// Interval test vectors: arbitrary durations, not profile values.
const Duration _standardIsha = Duration(minutes: 77);
const Duration _ramadanIsha = Duration(minutes: 107);
const Duration _imsak = Duration(minutes: 13);

/// Isha [_standardIsha] after Maghrib, [_ramadanIsha] in Ramadan, and an
/// Imsak defined only for Ramadan.
final PrayerProfile _profile = testProfile.copyWith(
  rules: {
    ...testProfile.rules,
    PrayerEvent.isha: const EventRule.intervalAfter(
      base: PrayerEvent.maghrib,
      duration: _standardIsha,
    ),
  },
  ramadanRules: const {
    PrayerEvent.isha: EventRule.intervalAfter(
      base: PrayerEvent.maghrib,
      duration: _ramadanIsha,
    ),
    PrayerEvent.imsak: EventRule.intervalBefore(
      base: PrayerEvent.fajr,
      duration: _imsak,
    ),
  },
);

final CivilDate _day = CivilDate(2027, 2, 15);

HijriState _hijri({
  required int dawnMonth,
  required int nightMonth,
  HijriConfidence confidence = HijriConfidence.expected,
}) => HijriState(
  dateAtDawn: HijriDate(year: 1448, month: dawnMonth, day: 29),
  dateAtNight: HijriDate(year: 1448, month: nightMonth, day: 1),
  confidence: confidence,
);

DayResult _calculate(HijriState hijri, {PrayerProfile? profile}) =>
    switch (const CalculateDay()(
      observer: observerOf(cityIn('Asia/Riyadh')),
      profile: profile ?? _profile,
      day: _day,
      tzdb: testTzdb,
      hijri: hijri,
    )) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError('Unexpected $failure'),
    };

int _raw(DayResult result, PrayerEvent event) =>
    switch (timeOf(result, event).rawUtcMs) {
      final int raw => raw,
      null => throw StateError('No $event instant'),
    };

List<AdjustmentStep> _stepsOf(DayResult result, PrayerEvent event) => [
  for (final step in result.provenance.adjustmentTrace)
    if (step.event == event) step,
];

void main() {
  group('Ramadan rule replacement (§6.4 ¶6)', () {
    test('replaces Isha on a night that ramadanAtNight governs and traces '
        'the change as RAMADAN_RULE_REPLACEMENT before the rounding', () {
      final result = _calculate(_hijri(dawnMonth: 8, nightMonth: 9));
      final steps = _stepsOf(result, PrayerEvent.isha);

      expect(
        _raw(result, PrayerEvent.isha) - _raw(result, PrayerEvent.maghrib),
        _ramadanIsha.inMilliseconds,
      );
      expect(steps.map((s) => (s.kind, s.deltaMs, s.reason)).first, (
        AdjustmentKind.ramadanRuleReplacement,
        (_ramadanIsha - _standardIsha).inMilliseconds,
        'adjustments.ramadan',
      ));
      expect(steps.last.kind, AdjustmentKind.rounding);
    });

    test('shows the replacement in the calculation_trace.v1 document '
        '(S08 done-test)', () {
      final result = _calculate(_hijri(dawnMonth: 8, nightMonth: 9));
      final trace = CalculationTraceDocument.fromJson(
        asJsonObject(
          jsonDecode(
            jsonEncode(
              const CalculationTraceWriter()
                  .write(
                    result,
                    CalculationInputs.of(
                      observer: observerOf(cityIn('Asia/Riyadh')),
                      profile: _profile,
                      day: _day,
                      hijri: _hijri(dawnMonth: 8, nightMonth: 9),
                    ),
                  )
                  .toJson(),
            ),
          ),
        ),
      );
      final isha = trace.times.singleWhere(
        (time) => time.event == PrayerEventCode.isha,
      );

      expect(
        isha.adjustmentTrace.map((step) => step.kind),
        [
          AdjustmentKindCode.ramadanRuleReplacement,
          AdjustmentKindCode.rounding,
        ],
      );
      expect(isha.flags, contains(ResultFlagCode.hijriExpected));
    });

    test('keeps the standard Isha when the night is not in Ramadan, even on '
        'a Ramadan dawn', () {
      final result = _calculate(_hijri(dawnMonth: 9, nightMonth: 10));

      expect(
        _raw(result, PrayerEvent.isha) - _raw(result, PrayerEvent.maghrib),
        _standardIsha.inMilliseconds,
      );
      expect(
        _stepsOf(result, PrayerEvent.isha).map((s) => s.kind),
        [AdjustmentKind.rounding],
      );
    });

    test('lets ramadanAtDawn govern Imsak: a Ramadan-only Imsak exists on a '
        'Ramadan dawn, traced with a 0 ms change, and not before', () {
      final eve = _calculate(_hijri(dawnMonth: 8, nightMonth: 9));
      final fast = _calculate(_hijri(dawnMonth: 9, nightMonth: 9));

      expect(eve.times.map((t) => t.event), isNot(contains(PrayerEvent.imsak)));
      expect(
        _raw(fast, PrayerEvent.fajr) - _raw(fast, PrayerEvent.imsak),
        _imsak.inMilliseconds,
      );
      expect(
        _stepsOf(fast, PrayerEvent.imsak).first,
        const AdjustmentStep(
          event: PrayerEvent.imsak,
          kind: AdjustmentKind.ramadanRuleReplacement,
          deltaMs: 0,
          reason: 'adjustments.ramadan',
        ),
      );
    });

    test('flags replaced events hijriExpected only under an Expected Hijri '
        'state (§15 D44, D56)', () {
      final expected = _calculate(_hijri(dawnMonth: 9, nightMonth: 9));
      for (final confidence in [
        HijriConfidence.confirmed,
        HijriConfidence.userOverride,
      ]) {
        final other = _calculate(
          _hijri(dawnMonth: 9, nightMonth: 9, confidence: confidence),
        );
        expect(
          other.times.expand((t) => t.flags),
          isNot(contains(ResultFlag.hijriExpected)),
          reason: '$confidence',
        );
      }

      for (final time in expected.times) {
        expect(
          time.flags.contains(ResultFlag.hijriExpected),
          time.event == PrayerEvent.imsak || time.event == PrayerEvent.isha,
          reason: '${time.event}',
        );
      }
    });

    test('changes nothing on a day outside Ramadan and for a profile '
        'without Ramadan rules', () {
      final outside = _calculate(_hijri(dawnMonth: 7, nightMonth: 8));
      final plain = _calculate(
        _hijri(dawnMonth: 9, nightMonth: 9),
        profile: _profile.copyWith(ramadanRules: const {}),
      );

      for (final result in [outside, plain]) {
        expect(
          result.provenance.adjustmentTrace.map((s) => s.kind),
          everyElement(AdjustmentKind.rounding),
        );
      }
    });

    test('refuses a Ramadan rule for an event other than Imsak, Fajr or Isha '
        'as invalidProfile (REQ-ERR-001)', () {
      final result = const CalculateDay()(
        observer: observerOf(cityIn('Asia/Riyadh')),
        profile: _profile.copyWith(
          ramadanRules: const {PrayerEvent.asr: EventRule.shadowFactor(k: 2)},
        ),
        day: _day,
        tzdb: testTzdb,
        hijri: _hijri(dawnMonth: 9, nightMonth: 9),
      );

      expect(
        result,
        isA<Err<DayResult, EngineFailure>>().having(
          (err) => err.failure,
          'failure',
          isA<InvalidProfile>(),
        ),
      );
    });
  });
}
