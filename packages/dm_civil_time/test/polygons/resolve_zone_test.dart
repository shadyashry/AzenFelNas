import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/fake_locate_in_polygons.dart';
import '../support/pinned_tzdata.dart';

void main() {
  final inside = GeoPointE6.fromDegrees(30, 31);
  final border = GeoPointE6.fromDegrees(31, 31);
  final coast = GeoPointE6.fromDegrees(31.5, 30);
  final ocean = GeoPointE6.fromDegrees(-20, -150);
  final resolve = ResolveZone(
    FakeLocateInPolygons({
      inside: const InsidePolygon('Africa/Cairo', otherDistanceM: 10001),
      border: const InsidePolygon('Africa/Cairo', otherDistanceM: 10000),
      coast: const NearPolygon(
        'Africa/Cairo',
        distanceM: 49000,
        otherDistanceM: null,
      ),
      ocean: const NearPolygon(
        'Pacific/Tahiti',
        distanceM: 50001,
        otherDistanceM: null,
      ),
    }),
  );

  group('ResolveZone (§8)', () {
    test('REQ-TIME-001 a containing polygon gives its zone, flagged only '
        'within 10 km of another zone', () {
      expect(
        resolve(inside),
        const InZone('Africa/Cairo', nearBoundary: false),
      );
      expect(resolve(inside).flags, isEmpty);
      expect(resolve(border), const InZone('Africa/Cairo', nearBoundary: true));
      expect(resolve(border).flags, {ResultFlag.zoneBoundaryProximity});
    });

    test('REQ-TIME-001 off the polygons the nearest zone within 50 km is used '
        'and flagged manualCoordinateResolution', () {
      expect(
        resolve(coast),
        const NearestZone(
          'Africa/Cairo',
          distanceM: 49000,
          nearBoundary: false,
        ),
      );
      expect(resolve(coast).flags, {ResultFlag.manualCoordinateResolution});
    });

    test('REQ-TIME-001 beyond 50 km of any zone the nautical Etc/GMT zone of '
        'the longitude is used', () {
      expect(resolve(ocean), const NauticalZone('Etc/GMT+10'));
      expect(resolve(ocean).flags, {ResultFlag.manualCoordinateResolution});
    });

    test('nautical zones: 15° bands centred on multiples of 15°, POSIX sign, '
        'clamped to ±12 h', () {
      const cases = {
        0: 'Etc/GMT',
        7499999: 'Etc/GMT',
        7500000: 'Etc/GMT-1',
        -7500000: 'Etc/GMT+1',
        45000000: 'Etc/GMT-3',
        -150000000: 'Etc/GMT+10',
        172500000: 'Etc/GMT-12',
        180000000: 'Etc/GMT-12',
        -180000000: 'Etc/GMT+12',
      };
      for (final MapEntry(key: lon, value: zone) in cases.entries) {
        expect(ResolveZone.nauticalZoneId(lon), zone, reason: '$lon');
      }
    });

    test('REQ-TIME-020 every nautical zone exists in the pinned TZDB with the '
        'offset its name states', () {
      final db = PinnedTzdata.load().database;
      for (var lon = -180000000; lon <= 180000000; lon += 7500000) {
        final zone = ResolveZone.nauticalZoneId(lon);
        final hours = (lon / 15e6).round().clamp(-12, 12);
        expect(db.offsetSecondsAt(zone, 0), hours * 3600, reason: zone);
      }
    });
  });
}
