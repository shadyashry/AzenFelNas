import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

import '../support/fake_locate_in_polygons.dart';

void main() {
  final inland = GeoPointE6.fromDegrees(30, 31);
  final border = GeoPointE6.fromDegrees(31.3, 34.2);
  final pier = GeoPointE6.fromDegrees(31.2, 29.9);
  final sea = GeoPointE6.fromDegrees(33, 29);
  final resolve = ResolveCountry(
    FakeLocateInPolygons({
      inland: const InsidePolygon('EG', otherDistanceM: null),
      border: const InsidePolygon('EG', otherDistanceM: 2500),
      pier: const NearPolygon('EG', distanceM: 300, otherDistanceM: null),
      sea: const NearPolygon('EG', distanceM: 22225, otherDistanceM: null),
    }),
  );

  group('ResolveCountry (§8)', () {
    test('a containing polygon gives its country, flagged within 10 km of '
        'another country', () {
      expect(resolve(inland), const InCountry('EG', nearBoundary: false));
      expect(resolve(inland).flags, isEmpty);
      expect(resolve(border), const InCountry('EG', nearBoundary: true));
      expect(resolve(border).flags, {ResultFlag.zoneBoundaryProximity});
    });

    test('within the 12 nmi territorial sea the nearest country is used', () {
      expect(
        resolve(pier),
        const OffshoreCountry('EG', distanceM: 300, nearBoundary: false),
      );
    });

    test('beyond it there is no country (engine.default, noLocalProfile)', () {
      expect(resolve(sea), const NoCountry());
      expect(resolve(sea).flags, isEmpty);
    });
  });
}
