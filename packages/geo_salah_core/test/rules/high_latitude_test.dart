import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_core/src/astro/topocentric_site.dart';
import 'package:geo_salah_core/src/rules/perturbed_sites.dart';
import 'package:geo_salah_core/src/solver/culmination_segments.dart';
import 'package:glados/glados.dart';

import '../support/engine_fixtures.dart';
import '../support/sites.dart';

/// Epoch days of 2026-01-01 … 2028-12-31.
final Generator<int> _days = any.intInRange(20454, 21550);
final Generator<int> _cityIndex = any.intInRange(0, testCities.length);

/// Interval test vector: an arbitrary duration, not a profile value.
const Duration _before = Duration(minutes: 13);

final TestCity _london = cityIn('Europe/London');
final TestCity _tromso = cityIn('Europe/Tromso');
final TestCity _utqiagvik = cityIn('America/Anchorage');
final TestCity _ushuaia = cityIn('America/Argentina/Ushuaia');

/// Midsummer: no twilight at London; midnight sun at Tromsø.
final CivilDate _midsummer = CivilDate(2026, 6, 21);

PrayerProfile _withChain(List<HighLatitudeMethod> chain) =>
    testProfile.copyWith(highLatitudeChain: chain);

final PrayerProfile _chainless = _withChain(const []);

int _raw(DayResult result, PrayerEvent event) =>
    switch (timeOf(result, event).rawUtcMs) {
      final int raw => raw,
      null => throw StateError('No $event instant on ${result.day}'),
    };

/// The raw [event] of [city] on [day] with the chainless profile.
int _rawOf(TestCity city, CivilDate day, PrayerEvent event) =>
    _raw(calculateOk(city, day, profile: _chainless), event);

/// The upper transit `T₀` of [city] on [day].
double _transit(TestCity city, CivilDate day) =>
    switch (CulminationSegments.locate(
      day: day,
      site: city.site,
      zoneId: city.zoneId,
      tzdb: testTzdb,
    )) {
      final CulminationSegments segments => segments.upperUtcMs,
      null => throw StateError('No segments for $day'),
    };

/// [city] moved to [site], in the same zone.
TestCity _at(TestCity city, TopocentricSite site) =>
    (zoneId: city.zoneId, site: site, offsetSeconds: city.offsetSeconds);

void main() {
  group('high-latitude chain (§6.4 ¶7)', () {
    Glados2(_cityIndex, _days).test(
      'falls back only where the rule has no root, and leaves every other '
      'time as the rule step gave it (REQ-DOM-002)',
      (index, epochDay) {
        final city = testCities[index];
        final day = CivilDate.fromEpochDay(epochDay);
        final ruleStep = calculateOk(city, day, profile: _chainless);
        final chained = calculateOk(city, day);
        for (final time in chained.times) {
          final rule = timeOf(ruleStep, time.event);
          switch (time.origin) {
            case Fallback():
              expect(rule.origin, isA<NoEvent>(), reason: '${time.event}');
              expect(
                [PrayerEvent.imsak, PrayerEvent.fajr, PrayerEvent.isha],
                contains(time.event),
              );
            case Primary():
              expect(time.rawUtcMs, rule.rawUtcMs);
            case NoEvent(:final reason):
              expect(rule.origin, isA<NoEvent>());
              if (reason == NoEventReason.chainExhausted) {
                expect(time.event, isNot(PrayerEvent.sunrise));
              } else {
                expect(time.origin, rule.origin);
              }
          }
        }
      },
    );

    test('measures anglePortion as α/60 of the UTC night: back from '
        'sunrise(D) to sunset(D−1) for Fajr, on from sunset(D) to '
        'sunrise(D+1) for Isha', () {
      final day = _midsummer;
      final result = calculateOk(_london, day);
      final sunsetBefore = _rawOf(
        _london,
        day.plusDays(-1),
        PrayerEvent.maghrib,
      );
      final sunrise = _rawOf(_london, day, PrayerEvent.sunrise);
      final sunset = _rawOf(_london, day, PrayerEvent.maghrib);
      final sunriseAfter = _rawOf(
        _london,
        day.plusDays(1),
        PrayerEvent.sunrise,
      );
      // engine.default's Fajr and Isha degrees: profile data, read back.
      final fajrPortion = switch (testProfile.rules[PrayerEvent.fajr]) {
        SolarAltitudeRule(:final degrees) => degrees / 60,
        _ => fail('engine.default Fajr is a solarAltitude rule'),
      };
      final ishaPortion = switch (testProfile.rules[PrayerEvent.isha]) {
        SolarAltitudeRule(:final degrees) => degrees / 60,
        _ => fail('engine.default Isha is a solarAltitude rule'),
      };

      expect(
        timeOf(result, PrayerEvent.fajr).origin,
        const EventOrigin.fallback(HighLatitudeMethod.anglePortion()),
      );
      expect(
        _raw(result, PrayerEvent.fajr),
        (sunrise - fajrPortion * (sunrise - sunsetBefore)).floor(),
      );
      expect(
        _raw(result, PrayerEvent.isha),
        (sunset + ishaPortion * (sunriseAfter - sunset)).floor(),
      );
    });

    test('measures middleOfNight and seventhOfNight as a half and a seventh '
        'of the same nights', () {
      final day = _midsummer;
      final sunsetBefore = _rawOf(
        _london,
        day.plusDays(-1),
        PrayerEvent.maghrib,
      );
      final sunrise = _rawOf(_london, day, PrayerEvent.sunrise);
      final sunset = _rawOf(_london, day, PrayerEvent.maghrib);
      final sunriseAfter = _rawOf(
        _london,
        day.plusDays(1),
        PrayerEvent.sunrise,
      );
      for (final (method, fraction) in [
        (const HighLatitudeMethod.middleOfNight(), 1 / 2),
        (const HighLatitudeMethod.seventhOfNight(), 1 / 7),
      ]) {
        final result = calculateOk(
          _london,
          day,
          profile: _withChain([method]),
        );

        expect(timeOf(result, PrayerEvent.fajr).origin, Fallback(method));
        expect(
          _raw(result, PrayerEvent.fajr),
          (sunrise - fraction * (sunrise - sunsetBefore)).floor(),
        );
        expect(
          _raw(result, PrayerEvent.isha),
          (sunset + fraction * (sunriseAfter - sunset)).floor(),
        );
      }
    });

    test('takes the first link of the chain that yields', () {
      final result = calculateOk(
        _london,
        _midsummer,
        profile: _withChain(const [
          HighLatitudeMethod.middleOfNight(),
          HighLatitudeMethod.anglePortion(),
        ]),
      );

      expect(
        timeOf(result, PrayerEvent.isha).origin,
        const EventOrigin.fallback(HighLatitudeMethod.middleOfNight()),
      );
    });

    test('skips the night methods when sunrise or sunset is absent and ends '
        'the chain as NO_EVENT(chainExhausted), labelled Unknown', () {
      final result = calculateOk(
        _tromso,
        _midsummer,
        profile: _withChain(const [
          HighLatitudeMethod.anglePortion(),
          HighLatitudeMethod.middleOfNight(),
          HighLatitudeMethod.seventhOfNight(),
        ]),
      );

      for (final event in [PrayerEvent.fajr, PrayerEvent.isha]) {
        expect(
          timeOf(result, event).origin,
          const EventOrigin.noEvent(NoEventReason.chainExhausted),
        );
        expect(
          timeOf(result, event).confidence,
          const ConfidenceLabel.unknown(reasonCode: 'CHAIN_EXHAUSTED'),
        );
      }
    });

    test('skips anglePortion for an event whose rule has no angle', () {
      final result = calculateOk(
        _tromso,
        _midsummer,
        profile: testProfile.copyWith(
          rules: {
            ...testProfile.rules,
            PrayerEvent.isha: const EventRule.intervalAfter(
              base: PrayerEvent.maghrib,
              duration: Duration(minutes: 77),
            ),
          },
          highLatitudeChain: const [HighLatitudeMethod.anglePortion()],
        ),
      );

      expect(
        timeOf(result, PrayerEvent.isha).origin,
        const EventOrigin.noEvent(NoEventReason.chainExhausted),
      );
    });

    test('takes nearestLatitude at ±latDeg in the observer hemisphere, same '
        'longitude, zone and day', () {
      for (final (city, day, latitude) in [
        (_tromso, _midsummer, 48.5),
        (_ushuaia, CivilDate(2026, 12, 21), -48.5),
      ]) {
        final result = calculateOk(
          city,
          day,
          profile: _withChain(const [
            HighLatitudeMethod.nearestLatitude(latDeg: 48.5),
          ]),
        );
        final there = _at(
          city,
          TopocentricSite.of(
            latitudeDeg: latitude,
            longitudeDeg: city.site.longitudeDeg,
          ),
        );

        for (final event in [PrayerEvent.fajr, PrayerEvent.isha]) {
          expect(
            timeOf(result, event).origin,
            const EventOrigin.fallback(
              HighLatitudeMethod.nearestLatitude(latDeg: 48.5),
            ),
            reason: '$day $event',
          );
          expect(_raw(result, event), _rawOf(there, day, event));
        }
      }
    });

    test('takes nearestValidDay from the nearest day with a root (D−1 '
        'before D+1), at the same distance from the upper transit', () {
      const method = HighLatitudeMethod.nearestValidDay(maxDays: 60);
      final day = _midsummer;
      final result = calculateOk(
        _london,
        day,
        profile: _withChain(const [method]),
      );
      final valid =
          [
            for (var distance = 1; distance <= 60; distance++) ...[
              day.plusDays(-distance),
              day.plusDays(distance),
            ],
          ].firstWhere(
            (other) =>
                timeOf(
                      calculateOk(_london, other, profile: _chainless),
                      PrayerEvent.isha,
                    ).origin
                    is Primary,
          );

      expect(
        timeOf(result, PrayerEvent.isha).origin,
        const EventOrigin.fallback(method),
      );
      expect(
        _raw(result, PrayerEvent.isha),
        (_transit(_london, day) +
                (_rawOf(_london, valid, PrayerEvent.isha) -
                    _transit(_london, valid)))
            .floor(),
      );
      final tooNear = calculateOk(
        _london,
        day,
        profile: _withChain(const [
          HighLatitudeMethod.nearestValidDay(maxDays: 3),
        ]),
      );
      expect(
        timeOf(tooNear, PrayerEvent.isha).origin,
        const EventOrigin.noEvent(NoEventReason.chainExhausted),
      );
    });

    test('moves an interval on a fallback base with it: Imsak before a '
        'fallback Fajr is the same fallback, the interval earlier '
        '(§15 D54)', () {
      final result = calculateOk(
        _london,
        _midsummer,
        profile: testProfile.copyWith(
          rules: {
            ...testProfile.rules,
            PrayerEvent.imsak: const EventRule.intervalBefore(
              base: PrayerEvent.fajr,
              duration: _before,
            ),
          },
        ),
      );
      final imsak = timeOf(result, PrayerEvent.imsak);

      expect(imsak.origin, timeOf(result, PrayerEvent.fajr).origin);
      expect(
        _raw(result, PrayerEvent.fajr) - _raw(result, PrayerEvent.imsak),
        _before.inMilliseconds,
      );
      expect(imsak.flags, contains(ResultFlag.highLatitudeFallback));
      expect(
        result.provenance.adjustmentTrace
            .where((step) => step.event == PrayerEvent.imsak)
            .first
            .reason,
        'highLatitude.anglePortion.via.fajr',
      );
    });

    test('flags a fallback highLatitudeFallback, labels it Estimated and '
        'traces it before its rounding (REQ-DOM-050, §15 D54)', () {
      final result = calculateOk(_london, _midsummer);
      final isha = timeOf(result, PrayerEvent.isha);
      final steps = [
        for (final step in result.provenance.adjustmentTrace)
          if (step.event == PrayerEvent.isha) step,
      ];

      expect(isha.flags, contains(ResultFlag.highLatitudeFallback));
      expect(
        isha.confidence,
        const ConfidenceLabel.estimated(rangeMinutes: 5),
      );
      expect(steps.map((s) => (s.kind, s.deltaMs, s.reason)).first, (
        AdjustmentKind.highLatitudeFallback,
        0,
        'highLatitude.anglePortion',
      ));
      expect(steps.last.kind, AdjustmentKind.rounding);
      expect(
        timeOf(result, PrayerEvent.dhuhr).flags,
        isNot(contains(ResultFlag.highLatitudeFallback)),
      );
    });

    test('widens Estimated to the ±1 km sensitivity where 1 km decides '
        'between a root and a fallback (Utqiaġvik, 2026-03-21, §15 D55)', () {
      final day = CivilDate(2026, 3, 21);
      final result = calculateOk(_utqiagvik, day);
      final isha = _raw(result, PrayerEvent.isha);
      final perturbed = [
        for (final site in const PerturbedSites().of(_utqiagvik.site))
          if (timeOf(
                calculateOk(_at(_utqiagvik, site), day),
                PrayerEvent.isha,
              ).rawUtcMs
              case final int raw)
            (raw - isha).abs(),
      ];
      final largest = perturbed.reduce((a, b) => a > b ? a : b);

      expect(
        timeOf(result, PrayerEvent.isha).origin,
        const EventOrigin.fallback(HighLatitudeMethod.anglePortion()),
      );
      expect(largest, greaterThan(const Duration(hours: 1).inMilliseconds));
      // The perturbed observers' coordinates are rounded to 6 decimals
      // (≈ 0.1 m) by CalculateDay, the engine's are not: allow one minute.
      expect(
        timeOf(result, PrayerEvent.isha).confidence,
        isA<Estimated>().having(
          (label) => label.rangeMinutes,
          'rangeMinutes',
          closeTo((largest / 60000).ceil(), 1),
        ),
      );
    });

    test('perturbs by 1 km on the WGS84 ellipsoid: 0.0090437° of latitude '
        'and 0.0089832° of longitude at the equator', () {
      final sites = const PerturbedSites().of(
        TopocentricSite.of(latitudeDeg: 0, longitudeDeg: 0),
      );

      expect(sites, hasLength(4));
      expect(sites[0].latitudeDeg, closeTo(0.0090437, 1e-7));
      expect(sites[1].latitudeDeg, closeTo(-0.0090437, 1e-7));
      expect(sites[2].longitudeDeg, closeTo(0.0089832, 1e-7));
      expect(sites[3].longitudeDeg, closeTo(-0.0089832, 1e-7));
    });
  });
}
