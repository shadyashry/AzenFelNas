// REQ-TEST-004: the LocateInPolygons port contract, run against the real
// PolygonIndex (synthetic and pinned payloads) and the fake.
import 'dart:math';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:test/test.dart';

import '../support/fake_locate_in_polygons.dart';
import '../support/pinned_polygons.dart';
import '../support/polygon_payload.dart';

/// Checks the documented contract on [points] at [radii].
void checkContract(
  LocateInPolygons port,
  List<GeoPointE6> points, {
  List<int> radii = const [1000, 10000, 50000],
}) {
  for (final point in points) {
    for (final radius in radii) {
      final match = port.locate(point, searchRadiusM: radius);
      expect(port.locate(point, searchRadiusM: radius), match, reason: 'pure');
      switch (match) {
        case InsidePolygon(:final otherDistanceM):
          expect(otherDistanceM ?? 0, inInclusiveRange(0, radius));
        case NearPolygon(:final distanceM, :final otherDistanceM):
          expect(distanceM, inInclusiveRange(0, radius));
          expect(otherDistanceM ?? distanceM, greaterThanOrEqualTo(0));
          expect(otherDistanceM ?? 0, lessThanOrEqualTo(radius));
          expect(
            otherDistanceM ?? double.infinity,
            greaterThanOrEqualTo(distanceM),
            reason: 'the match is the nearest polygon',
          );
        case NoPolygon():
          if (radius > radii.first) {
            final smaller = port.locate(point, searchRadiusM: radii.first);
            expect(smaller, const NoPolygon(), reason: 'monotonic in radius');
          }
      }
    }
  }
}

List<GeoPointE6> _randomPoints(int count, {required int seed}) {
  final random = Random(seed);
  return [
    for (var i = 0; i < count; i++)
      GeoPointE6(
        (asin(random.nextDouble() * 2 - 1) * 180 / pi * 1e6).round(),
        (random.nextDouble() * 360e6 - 180e6).round(),
      ),
  ];
}

void main() {
  group('REQ-TEST-004 LocateInPolygons contract', () {
    test('PolygonIndex over a synthetic payload', () {
      final payload =
          (PolygonPayload('TZPG')
                ..box('A/West', 10, 10, 11, 11)
                ..box('A/East', 11, 10, 12, 11))
              .build();
      final index = switch (const ReadPolygonIndex()(
        payload,
        dataset: PolygonDataset.tz,
      )) {
        Ok(:final value) => value,
        Err(:final failure) => fail('$failure'),
      };
      checkContract(index, [
        for (var lon = 9.5; lon <= 12.5; lon += 0.05)
          GeoPointE6.fromDegrees(10.5, lon),
      ]);
      expect(
        index.locate(GeoPointE6.fromDegrees(10.5, 10.95), searchRadiusM: 10000),
        isA<InsidePolygon>()
            .having((m) => m.name, 'name', 'A/West')
            .having((m) => m.otherDistanceM, 'other', closeTo(5468, 5)),
      );
    });

    for (final dataset in PolygonDataset.values) {
      test('PolygonIndex over the pinned ${dataset.name} package', () {
        checkContract(
          PinnedPolygons.load(dataset).index,
          _randomPoints(300, seed: dataset.index),
        );
      });
    }

    test('FakeLocateInPolygons', () {
      final inside = GeoPointE6.fromDegrees(30, 31);
      final near = GeoPointE6.fromDegrees(30, 32);
      checkContract(
        FakeLocateInPolygons({
          inside: const InsidePolygon('Africa/Cairo', otherDistanceM: 9000),
          near: const NearPolygon(
            'Africa/Cairo',
            distanceM: 4000,
            otherDistanceM: 20000,
          ),
        }),
        [inside, near, GeoPointE6.fromDegrees(0, 0)],
      );
    });
  });
}
