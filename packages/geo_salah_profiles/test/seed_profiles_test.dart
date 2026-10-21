import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_hijri/dm_hijri.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:test/test.dart';

import 'support/fixed_offset_tz_database.dart';
import 'support/fixtures.dart';
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

/// A Hijri state outside Ramadan: every rule is the standard one.
const HijriState _outsideRamadan = HijriState(
  dateAtDawn: HijriDate(year: 1448, month: 1, day: 1),
  dateAtNight: HijriDate(year: 1448, month: 1, day: 2),
  confidence: HijriConfidence.expected,
);

/// A Hijri state inside Ramadan, dawn and night: every Ramadan rule
/// replaces its event's rule (§6.4 ¶6).
const HijriState _inRamadan = HijriState(
  dateAtDawn: HijriDate(year: 1448, month: 9, day: 10),
  dateAtNight: HijriDate(year: 1448, month: 9, day: 11),
  confidence: HijriConfidence.expected,
);

/// The 15th of each month of 2027, after every seed's `effectiveFrom`.
final List<CivilDate> _days = [
  for (var month = 1; month <= 12; month++) CivilDate(2027, month, 15),
];

/// The Hijri states that exercise [profile]: outside Ramadan and, when it
/// has Ramadan rules, inside Ramadan, where the engine replaces them.
List<(String, HijriState)> _variants(PrayerProfile profile) => [
  ('standard', _outsideRamadan),
  if (profile.ramadanRules.isNotEmpty) ('Ramadan', _inRamadan),
];

DayResult _calculate(
  PrayerProfile profile,
  (String, double, double, String, double) city,
  CivilDate day, {
  HijriState hijri = _outsideRamadan,
}) {
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
    hijri: hijri,
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
        for (final (variant, hijri) in _variants(profile)) {
          for (final city in cities) {
            for (final day in _days) {
              final result = _calculate(profile, city, day, hijri: hijri);
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
        '120 min in Ramadan by the tabular calendar (ADR-016)', () {
      final sa = seedProfiles().singleWhere(
        (p) => p.profileId == 'sa.ummalqura.standard',
      );
      final makkah = _cities['SA']!.first; // SAFETY: the map literal has SA.
      // 9 Dhu al-Qa'da and 9 Ramadan 1448 in the tabular calendar.
      final plainDay = CivilDate(2027, 4, 15);
      final fastingDay = CivilDate(2027, 2, 15);
      final plain = _calculate(
        sa,
        makkah,
        plainDay,
        hijri: const BuildHijriState()(day: plainDay),
      );
      final fasting = _calculate(
        sa,
        makkah,
        fastingDay,
        hijri: const BuildHijriState()(day: fastingDay),
      );
      expect(
        _raw(plain, PrayerEvent.isha) - _raw(plain, PrayerEvent.maghrib),
        const Duration(minutes: 90).inMilliseconds,
      );
      expect(
        _raw(fasting, PrayerEvent.isha) - _raw(fasting, PrayerEvent.maghrib),
        const Duration(minutes: 120).inMilliseconds,
      );
    });

    test('show the Ramadan Isha replacement in the calculation trace, '
        'flagged HIJRI_EXPECTED under the tabular calendar (S08 done-test, '
        '§6.4 ¶6)', () {
      final sa = seedProfiles().singleWhere(
        (p) => p.profileId == 'sa.ummalqura.standard',
      );
      final (name, lat, lon, zoneId, _) =
          _cities['SA']!.first; // SAFETY: the map literal has SA.
      final day = CivilDate(2027, 2, 15);
      final hijri = const BuildHijriState()(day: day);
      final observer = Observer(
        latitudeDeg: lat,
        longitudeDeg: lon,
        zoneId: zoneId,
        source: ObserverSource.benchmark,
      );
      final result = _calculate(
        sa,
        (name, lat, lon, zoneId, 3),
        day,
        hijri: hijri,
      );

      final trace = const CalculationTraceWriter().write(
        result,
        CalculationInputs.of(
          observer: observer,
          profile: sa,
          day: day,
          hijri: hijri,
        ),
      );
      final json = jsonEncode(trace.toJson());
      final isha = CalculationTraceDocument.fromJson(
        asJsonObject(jsonDecode(json)),
      ).times.singleWhere((time) => time.event == PrayerEventCode.isha);

      expect(hijri.ramadanAtNight, isTrue);
      expect(
        isha.adjustmentTrace.first,
        AdjustmentStepDocument(
          event: PrayerEventCode.isha,
          kind: AdjustmentKindCode.ramadanRuleReplacement,
          deltaMs: const Duration(minutes: 30).inMilliseconds,
          reason: 'adjustments.ramadan',
        ),
      );
      expect(isha.flags, contains(ResultFlagCode.hijriExpected));
    });
  });
}
