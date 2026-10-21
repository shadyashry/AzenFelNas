import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/bench/bench_profile_reader.dart';
import 'package:geo_salah_core/src/bench/bench_profiles.dart';
import 'package:test/test.dart';

import '../support/bench_profile_files.dart';

/// A minimal stand-in document; the values are shape test data.
Map<String, Object?> _document({
  Map<String, Object?>? rules,
  Map<String, Object?>? extra,
}) => {
  'profileId': 'zz.fixture.bench',
  'schemaVersion': 1,
  'version': '2026.10.1',
  'status': 'APPROVED',
  'authority': {'name': 'Fixture', 'type': 'RECOGNIZED_BODY'},
  'rules':
      rules ??
      {
        'dhuhr': {'type': 'transit'},
      },
  'horizon': {'elevationPolicy': 'NONE'},
  'rounding': {'default': 'nearest', 'fajr': 'floor'},
  ...?extra,
};

void main() {
  group('BenchProfileReader (§15 D48)', () {
    test('reads the engine.default stand-in data with every S06 event', () {
      final profile = readEngineDefault();
      expect(profile.profileId, BenchProfiles.engineDefaultId);
      expect(profile.status, ProfileStatus.draftUnverified);
      expect(profile.authorityType, AuthorityType.engineDefault);
      expect(profile.benchmarkReportId, isNull);
      expect(profile.rules.keys, [
        PrayerEvent.fajr,
        PrayerEvent.sunrise,
        PrayerEvent.dhuhr,
        PrayerEvent.asr,
        PrayerEvent.maghrib,
        PrayerEvent.isha,
      ]);
      expect(profile.rules[PrayerEvent.sunrise], const EventRule.horizon());
      expect(profile.rules[PrayerEvent.dhuhr], const EventRule.transit());
      expect(profile.perEventMinutes, isEmpty);
    });

    test('reads every Appendix A rule shape, rounding overrides, offsets '
        'and the benchmark report id', () {
      final profile = BenchProfileReader.read(
        _document(
          rules: {
            'imsak': {'type': 'intervalBefore', 'base': 'fajr', 'minutes': 7},
            'fajr': {'type': 'solarAltitude', 'degrees': 12.5},
            'sunrise': {'type': 'horizon', 'refractionArcmin': 30},
            'dhuhr': {'type': 'transit', 'offsetMinutes': 2},
            'asr': {'type': 'shadowFactor', 'k': 2},
            'maghrib': {'type': 'horizon'},
            'isha': {'type': 'intervalAfter', 'base': 'maghrib', 'minutes': 40},
          },
          extra: {
            'adjustments': {
              'perEventMinutes': {'asr': -1},
              'maxAbsMinutes': 2,
              'ramadan': <String, Object?>{},
            },
            'evidence': {'benchmarkReportId': 'zz-report-1'},
          },
        ),
      );
      expect(profile.rules, {
        PrayerEvent.imsak: const EventRule.intervalBefore(
          base: PrayerEvent.fajr,
          duration: Duration(minutes: 7),
        ),
        PrayerEvent.fajr: const EventRule.solarAltitude(degrees: 12.5),
        PrayerEvent.sunrise: const EventRule.horizon(refractionArcmin: 30),
        PrayerEvent.dhuhr: const EventRule.transit(
          offset: Duration(minutes: 2),
        ),
        PrayerEvent.asr: const EventRule.shadowFactor(k: 2),
        PrayerEvent.maghrib: const EventRule.horizon(),
        PrayerEvent.isha: const EventRule.intervalAfter(
          base: PrayerEvent.maghrib,
          duration: Duration(minutes: 40),
        ),
      });
      expect(profile.status, ProfileStatus.approved);
      expect(profile.authorityType, AuthorityType.recognizedBody);
      expect(profile.roundingDefault, RoundingMode.nearest);
      expect(profile.roundingOverrides, {PrayerEvent.fajr: RoundingMode.floor});
      expect(profile.perEventMinutes, {PrayerEvent.asr: -1});
      expect(profile.maxAbsMinutes, 2);
      expect(profile.benchmarkReportId, 'zz-report-1');
    });

    test('rejects unknown members, rule shapes and codes, and Ramadan rules '
        'before S08', () {
      for (final document in [
        _document(extra: {'scope': <String, Object?>{}}),
        _document(
          rules: {
            'dhuhr': {'type': 'transit', 'offset': 2},
          },
        ),
        _document(
          rules: {
            'dhuhr': {'type': 'midday'},
          },
        ),
        _document(
          rules: {
            'noon': {'type': 'transit'},
          },
        ),
        _document(extra: {'status': 'PUBLISHED'}),
        _document(
          extra: {
            'rounding': {'default': 'up'},
          },
        ),
        _document(extra: {'rounding': <String, Object?>{}}),
        _document(extra: {'schemaVersion': 2}),
        _document(
          extra: {
            'adjustments': {
              'maxAbsMinutes': 0,
              'ramadan': {
                'isha': {'type': 'horizon'},
              },
            },
          },
        ),
      ]) {
        expect(
          () => BenchProfileReader.read(document),
          throwsFormatException,
          reason: '$document',
        );
      }
    });

    test('rejects a repeated profile id', () {
      expect(
        () => BenchProfiles.byId([_document(), _document()]),
        throwsFormatException,
      );
    });
  });
}
