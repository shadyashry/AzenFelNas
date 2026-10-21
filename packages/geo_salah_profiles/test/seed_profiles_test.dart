import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import 'support/fixed_offset_tz_database.dart';
import 'support/profile_files.dart';

/// Appendix H cities per scope: name, latitude, longitude, IANA zone and its
/// standard offset (hours). `*` is a spread for `engine.default`.
const Map<String, List<(String, double, double, String, double)>> _cities = {
  'EG': [
    ('Cairo', 30.04, 31.24, 'Africa/Cairo', 2),
    ('Alexandria', 31.20, 29.92, 'Africa/Cairo', 2),
    ('Aswan', 24.09, 32.90, 'Africa/Cairo', 2),
  ],
  'SA': [
    ('Makkah', 21.42, 39.83, 'Asia/Riyadh', 3),
    ('Riyadh', 24.71, 46.68, 'Asia/Riyadh', 3),
    ('Jeddah', 21.49, 39.19, 'Asia/Riyadh', 3),
  ],
  'AE': [
    ('Dubai', 25.20, 55.27, 'Asia/Dubai', 4),
    ('Abu Dhabi', 24.45, 54.38, 'Asia/Dubai', 4),
  ],
  '*': [
    ('London', 51.51, -0.13, 'Europe/London', 0),
    ('Tromsø', 69.65, 18.96, 'Europe/Oslo', 1),
    ('Kuala Lumpur', 3.14, 101.69, 'Asia/Kuala_Lumpur', 8),
    ('São Paulo', -23.55, -46.63, 'America/Sao_Paulo', -3),
    ('Kiritimati', 1.87, -157.43, 'Pacific/Kiritimati', 14),
  ],
};

final FixedOffsetTzDatabase _tzdb = FixedOffsetTzDatabase({
  for (final cities in _cities.values)
    for (final (_, _, _, zoneId, hours) in cities)
      zoneId: (hours * 3600).round(),
});

/// Shape-only Hijri state: no S07 event reads it (Ramadan replacement is S08).
const HijriState _hijri = HijriState(
  dateAtDawn: HijriDate(year: 1448, month: 1, day: 1),
  dateAtNight: HijriDate(year: 1448, month: 1, day: 2),
  confidence: HijriConfidence.expected,
);

/// The 15th of each month of 2027, after every seed's `effectiveFrom`.
final List<CivilDate> _days = [
  for (var month = 1; month <= 12; month++) CivilDate(2027, month, 15),
];

/// [profile] and, when it has Ramadan rules, its Ramadan variant: the rules
/// with each Ramadan rule in place (what S08 substitutes, §6.4 ¶6).
List<(String, PrayerProfile)> _variants(PrayerProfile profile) => [
  ('standard', profile),
  if (profile.ramadanRules.isNotEmpty)
    (
      'Ramadan',
      profile.copyWith(rules: {...profile.rules, ...profile.ramadanRules}),
    ),
];

DayResult _calculate(
  PrayerProfile profile,
  (String, double, double, String, double) city,
  CivilDate day,
) {
  final (name, lat, lon, zoneId, _) = city;
  return switch (const CalculateDay()(
    observer: Observer(
      latitudeDeg: lat,
      longitudeDeg: lon,
      zoneId: zoneId,
      source: ObserverSource.benchmark,
    ),
    profile: profile,
    day: day,
    tzdb: _tzdb,
    hijri: _hijri,
  )) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError(
      '${profile.profileId} $name $day: ${failure.detail}',
    ),
  };
}

int _raw(DayResult result, PrayerEvent event) =>
    switch (result.times.singleWhere((t) => t.event == event).rawUtcMs) {
      final int raw => raw,
      null => throw StateError('No $event instant'),
    };

void main() {
  group('seed profiles (S07 done-test, Appendix E)', () {
    final files = seedProfileFiles();

    test('are the four Appendix E seeds, all DRAFT_UNVERIFIED without '
        'approvals', () {
      final profiles = seedProfiles();
      expect(
        profiles.map((p) => p.profileId),
        unorderedEquals([
          'ae.awqaf.standard',
          'eg.egas.standard',
          'engine.default',
          'sa.ummalqura.standard',
        ]),
      );
      for (final profile in profiles) {
        expect(profile.status, ProfileStatus.draftUnverified);
        expect(profile.hasReligiousApproval, isFalse);
        expect(profile.benchmarkReportId, isNull);
      }
    });

    for (final file in files) {
      final name = file.uri.pathSegments.last;
      test('$name passes conformance: it parses, validates and calculates '
          'every benchmark city of its scope, in each variant', () {
        final profile = parseOk(file);
        final scope = profile.countries.single;
        final cities = _cities[scope];
        if (cities == null) fail('No benchmark city for $scope');
        for (final (variant, candidate) in _variants(profile)) {
          for (final city in cities) {
            for (final day in _days) {
              final result = _calculate(candidate, city, day);
              expect(result.times, isNotEmpty, reason: '$variant $city $day');
              for (final time in result.times) {
                expect(
                  time.confidence,
                  isNot(isA<AuthorityAligned>()),
                  reason: 'a DRAFT_UNVERIFIED profile is never aligned',
                );
              }
            }
          }
        }
      });
    }

    test('form a set without overlap that loads on dev and lab only '
        '(ADR-007, Appendix E)', () {
      final set = seedSet();
      for (final channel in ReleaseChannel.values) {
        final loads = const CheckProfileChannel()(set, channel) is Ok;
        expect(
          loads,
          channel == ReleaseChannel.dev || channel == ReleaseChannel.lab,
          reason: '$channel',
        );
      }
    });

    test('carry the §6.5 Umm al-Qura Isha intervals: 90 min after Maghrib, '
        '120 min in the Ramadan variant', () {
      final sa = seedProfiles().singleWhere(
        (p) => p.profileId == 'sa.ummalqura.standard',
      );
      final [(_, standard), (_, ramadan)] = _variants(sa);
      final makkah = _cities['SA']!.first; // SAFETY: the map literal has SA.
      final day = CivilDate(2027, 2, 15);
      final plain = _calculate(standard, makkah, day);
      final fasting = _calculate(ramadan, makkah, day);
      expect(
        _raw(plain, PrayerEvent.isha) - _raw(plain, PrayerEvent.maghrib),
        const Duration(minutes: 90).inMilliseconds,
      );
      expect(
        _raw(fasting, PrayerEvent.isha) - _raw(fasting, PrayerEvent.maghrib),
        const Duration(minutes: 120).inMilliseconds,
      );
    });
  });
}
