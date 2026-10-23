import 'package:daily_muslim/features/passport/application/import_calculation_link.dart';
import 'package:daily_muslim/features/passport/application/measure_sensitivity.dart';
import 'package:daily_muslim/features/passport/application/resolve_calculation_id.dart';
import 'package:daily_muslim/features/passport/domain/calculation_link.dart';
import 'package:daily_muslim/features/passport/domain/import_mismatch.dart';
import 'package:daily_muslim/features/passport/domain/passport_entry.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';
import 'passport_support.dart';

void main() {
  final data = bundledRuntimeData();
  final schedule = cairoSchedule();
  final resolve = ResolveCalculationId(data.tzdb);
  final import = ImportCalculationLink(data.tzdb, data.profiles);
  final day = schedule.days[2];

  LinkedInputs linked(String? encoded) =>
      CalculationLink.decode(encoded ?? '') ??
      (throw StateError(encoded ?? ''));

  group('ResolveCalculationId (§6.4 ¶11, US-05)', () {
    test('REQ-DOM-004 a schedule day resolves by its ID, focused on the '
        'event', () {
      final entry = resolve(
        schedule,
        day.calculationId,
        event: PrayerEvent.asr,
      );
      if (entry == null) fail('not resolved');
      expect(entry.day, day);
      expect(entry.focus, PrayerEvent.asr);
      expect(entry.origin, PassportOrigin.local);
      expect(entry.inputs.inputsHash, day.provenance.inputsHash);
      expect(
        entry.roundingOf(PrayerEvent.asr),
        schedule.profile.roundingDefault,
      );
    });

    test('an unknown ID or an event without a row is not found', () {
      expect(resolve(schedule, 'GS-AAAAAAAAAAAAAAAA'), isNull);
      expect(
        resolve(schedule, day.calculationId, event: PrayerEvent.imsak),
        day.times.any((t) => t.event == PrayerEvent.imsak) ? isNotNull : isNull,
      );
    });
  });

  group('CalculationLink (§6.4 ¶11, §15 D78)', () {
    test('the link carries only the hashed inputs', () {
      final link = CalculationLink.of(
        calculationId: day.calculationId,
        inputs: schedule.inputs[2],
        event: PrayerEvent.fajr,
      );
      expect(link.scheme, 'dailymuslim');
      expect(link.path, '/calc/${day.calculationId}');
      expect(link.fragment, 'fajr');
      expect(link.queryParametersAll.keys, ['i']);
      final back = linked(link.queryParameters['i']);
      expect(back.latitudeDeg, schedule.inputs[2].latitudeDeg);
      expect(back.zoneId, 'Africa/Cairo');
      expect(back.day, day.day);
      expect(back.hijri, schedule.inputs[2].hijri);
    });

    test('malformed, extra or out-of-range inputs are refused', () {
      expect(CalculationLink.decode('!!!'), isNull);
      expect(CalculationLink.decode('eyJhIjoxfQ'), isNull); // {"a":1}
      final good = schedule.inputs[0].toJson();
      const enc = CalculationLink.encodeJson;
      expect(CalculationLink.decode(enc(good)), isNotNull);
      expect(CalculationLink.decode(enc({...good, 'lat': 91})), isNull);
      expect(CalculationLink.decode(enc({...good, 'x': 1})), isNull);
      expect(
        CalculationLink.decode(enc({...good, 'day': '2026-02-30'})),
        isNull,
      );
    });
  });

  group('ImportCalculationLink (§6.4 ¶11, US-09)', () {
    final encoded = CalculationLink.encode(schedule.inputs[2]);

    test('REQ-DOM-004 the same inputs recompute to the same ID here', () {
      final outcome = import(day.calculationId, linked(encoded));
      expect(outcome, isA<ImportMatched>());
      final entry = _as<ImportMatched>(outcome).entry;
      expect(entry.origin, PassportOrigin.importedMatch);
      expect(entry.day.calculationId, day.calculationId);
      expect(
        [for (final t in entry.day.times) t.rawUtcMs],
        [for (final t in day.times) t.rawUtcMs],
      );
    });

    test('REQ-DOM-004 another ID for the same inputs is a version mismatch '
        'with this device versions, never the sender values', () {
      final outcome = import('GS-AAAAAAAAAAAAAAAA', linked(encoded));
      final mismatch = _as<ImportMismatched>(outcome).mismatch;
      expect(mismatch.reason, MismatchReason.differentVersions);
      expect(mismatch.linkId, 'GS-AAAAAAAAAAAAAAAA');
      expect(mismatch.localId, day.calculationId);
      expect(mismatch.engineVersion, EngineVersion.current);
      expect(mismatch.tzdbVersion, '2026e');
    });

    test('a profile version this device lacks is named', () {
      final json = {
        ...schedule.inputs[2].toJson(),
        'profileVersion': '1999.1.1',
      };
      final outcome = import(
        day.calculationId,
        linked(CalculationLink.encodeJson(json)),
      );
      final mismatch = _as<ImportMismatched>(outcome).mismatch;
      expect(mismatch.reason, MismatchReason.profileUnavailable);
      expect(mismatch.profileVersion, '1999.1.1');
      expect(mismatch.localId, isNull);
    });

    test('a zone this TZDB lacks is named', () {
      final json = {...schedule.inputs[2].toJson(), 'zoneId': 'Mars/Olympus'};
      final outcome = import(
        day.calculationId,
        linked(CalculationLink.encodeJson(json)),
      );
      expect(
        _as<ImportMismatched>(outcome).mismatch.reason,
        MismatchReason.zoneUnavailable,
      );
    });
  });

  group('MeasureSensitivity (§6.7 perturbation)', () {
    test('REQ-DOM-020 ±1 km moves Cairo times by under a minute and the same '
        'arguments give the same line', () {
      final measure = MeasureSensitivity(data.tzdb);
      final observer = ObserverOf.context(schedule.context);
      Map<PrayerEvent, int> run() => measure(
        observer: observer,
        profile: schedule.profile,
        base: day,
        hijri: schedule.inputs[2].hijri,
      );
      final ms = run();
      expect(ms.keys, containsAll([PrayerEvent.fajr, PrayerEvent.maghrib]));
      for (final value in ms.values) {
        expect(value, inInclusiveRange(1, 60000));
      }
      expect(run(), ms);
    });
  });
}

/// [value] as [T]; fails the test otherwise.
T _as<T>(Object? value) =>
    value is T ? value : throw StateError('not $T: $value');
