import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/engine_fixtures.dart';
import '../support/fixtures.dart';
import '../support/sites.dart';

/// A reference point 60 km from Cairo's observer (shape test data).
const ReferencePoint _point = ReferencePoint(
  area: 'EG',
  lat: 30.5,
  lon: 31.5,
);

Observer _cairo({double lat = 30.04, double lon = 31.24}) => Observer(
  latitudeDeg: lat,
  longitudeDeg: lon,
  zoneId: 'Africa/Cairo',
  source: ObserverSource.benchmark,
);

Result<DayResult, EngineFailure> _calculate(
  PrayerProfile profile, {
  Observer? observer,
}) => const CalculateDay()(
  observer: observer ?? _cairo(),
  profile: profile,
  day: CivilDate(2027, 3, 20),
  tzdb: testTzdb,
  hijri: testHijri,
);

DayResult _ok(Result<DayResult, EngineFailure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('Unexpected $failure'),
};

void main() {
  group('reference mode (ADR-006)', () {
    final atPoint = testProfile.copyWith(
      authorityType: AuthorityType.government,
      referenceMode: ReferenceMode.authorityReferencePoint,
      referencePoints: [_point],
    );

    test('calculates at the reference point and flags every time '
        'referenceModeAuthorityPoint', () {
      final result = _ok(_calculate(atPoint));
      final there = _ok(
        _calculate(
          testProfile.copyWith(authorityType: AuthorityType.government),
          observer: _cairo(lat: _point.lat, lon: _point.lon),
        ),
      );
      expect(
        [for (final time in result.times) time.rawUtcMs],
        [for (final time in there.times) time.rawUtcMs],
      );
      for (final time in result.times) {
        expect(time.flags, contains(ResultFlag.referenceModeAuthorityPoint));
      }
    });

    test('hashes the coordinates it calculates at, so every observer of the '
        'area shares one Calculation ID (REQ-DOM-004)', () {
      final a = _ok(_calculate(atPoint));
      final b = _ok(
        _calculate(atPoint, observer: _cairo(lat: 29.9, lon: 31.1)),
      );
      expect(b.calculationId, a.calculationId);
      expect(b.times, a.times);
      final trace = asJsonObject(
        jsonDecode(
          jsonEncode(
            const CalculationTraceWriter().write(
              a,
              CalculationInputs.of(
                observer: _cairo(),
                profile: atPoint,
                day: CivilDate(2027, 3, 20),
                hijri: testHijri,
              ),
            ),
          ),
        ),
      );
      final inputs = asJsonObject(trace['inputs']);
      expect(inputs['lat'], _point.lat);
      expect(inputs['lon'], _point.lon);
      expect(trace['calculationId'], a.calculationId);
    });

    test('returns invalidProfile unless the resolver left exactly one '
        'reference point (REQ-ERR-001)', () {
      for (final points in [
        <ReferencePoint>[],
        [_point, _point.copyWith(area: 'SD')],
      ]) {
        final result = _calculate(atPoint.copyWith(referencePoints: points));
        expect(result, isA<Err<DayResult, EngineFailure>>());
        if (result case Err(:final failure)) {
          expect(failure.code, FailureCode.profileInvalid);
        }
      }
    });
  });

  group('noLocalProfile (ADR-007)', () {
    test('flags every time of the engine default and none of an authority '
        'profile', () {
      final fallback = _ok(_calculate(testProfile));
      final local = _ok(
        _calculate(
          testProfile.copyWith(authorityType: AuthorityType.government),
        ),
      );
      expect(
        fallback.times.every(
          (time) => time.flags.contains(ResultFlag.noLocalProfile),
        ),
        isTrue,
      );
      expect(
        local.times.any(
          (time) => time.flags.contains(ResultFlag.noLocalProfile),
        ),
        isFalse,
      );
    });
  });
}
