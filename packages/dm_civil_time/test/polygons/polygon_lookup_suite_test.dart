// The S11 done-test (DESIGN.md §13): 1 000 random points agree with shapely
// ≥ 99.9 %, and the boundary flag holds within 10 km. The oracle
// (`lookup_oracle.json`, schema `polygon_lookup_oracle.v1`) is shapely on
// the unsimplified source; the payload is simplified (Douglas-Peucker
// 0.001°) and rounded to micro-degrees, so answers may differ only near a
// boundary (§15 D70–D71).
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:test/test.dart';

import '../support/pinned_polygons.dart';

/// Simplification moves an edge by at most 0.001° (≤ 112 m); rounding and
/// projection add well under a metre.
const double _toleranceM = 150;

List<Map<String, Object?>> _objects(Object? json) => switch (json) {
  final List<Object?> list => [
    for (final item in list)
      switch (item) {
        final Map<String, Object?> object => object,
        _ => throw const FormatException('expected an object'),
      },
  ],
  _ => throw const FormatException('expected a list'),
};

int _int(Map<String, Object?> json, String key) => switch (json[key]) {
  final int value => value,
  _ => throw FormatException('$key is not an integer'),
};

double? _metres(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final num value => value.toDouble(),
  _ => throw FormatException('$key is not a number'),
};

String? _name(Map<String, Object?> json, String key) => switch (json[key]) {
  null => null,
  final String value => value,
  _ => throw FormatException('$key is not a string'),
};

/// The name the resolver would use: the containing polygon, else the
/// nearest within the radius.
String? _resolved(PolygonMatch match) => switch (match) {
  InsidePolygon(:final name) || NearPolygon(:final name) => name,
  NoPolygon() => null,
};

double? _other(PolygonMatch match) => switch (match) {
  InsidePolygon(:final otherDistanceM) ||
  NearPolygon(:final otherDistanceM) => otherDistanceM,
  NoPolygon() => null,
};

/// Whether [metres] (null: beyond the limit) is within [radius].
bool _within(double? metres, num radius) => metres != null && metres <= radius;

void main() {
  for (final dataset in PolygonDataset.values) {
    group('${PinnedPolygons.packageOf(dataset)} against shapely', () {
      final pinned = PinnedPolygons.load(dataset);
      final index = pinned.index;
      final oracle = pinned.oracle;
      final limit = switch (oracle['distanceLimitM']) {
        final num value => value.toInt(),
        _ => throw const FormatException('distanceLimitM'),
      };

      test('the oracle is for this package and the §15 D71 projection', () {
        expect(oracle['dataset'], PinnedPolygons.packageOf(dataset));
        expect(oracle['earthRadiusM'], LocalProjection.earthRadiusM);
        expect(limit, ResolveZone.nearestRadiusM);
      });

      for (final sample in _objects(oracle['samples'])) {
        final points = _objects(sample['points']);
        final matches = [
          for (final point in points)
            index.locate(
              GeoPointE6(_int(point, 'latE6'), _int(point, 'lonE6')),
              searchRadiusM: limit,
            ),
        ];

        test('REQ-TIME-001 ${sample['name']}: ≥ 99.9 % of '
            '${points.length} points resolve to the name shapely gives, and '
            'every other one is flagged near a boundary', () {
          final disagreements = <String>[];
          for (var i = 0; i < points.length; i++) {
            final expected =
                _name(points[i], 'containing') ?? _name(points[i], 'nearest');
            final actual = _resolved(matches[i]);
            if (actual == expected) continue;
            disagreements.add('$i: $actual != $expected');
            expect(
              _within(_other(matches[i]), ResolveZone.boundaryRadiusM) ||
                  _within(_metres(points[i], 'otherDistanceM'), _toleranceM),
              isTrue,
              reason: 'point $i: $actual != $expected and not near a boundary',
            );
          }
          expect(points, hasLength(1000));
          expect(
            disagreements.length,
            lessThanOrEqualTo(1),
            reason: '$disagreements',
          );
        });

        test('REQ-TIME-001 ${sample['name']}: the 10 km boundary flag agrees '
            'with shapely outside the ±${_toleranceM.toInt()} m band', () {
          var flagged = 0;
          for (var i = 0; i < points.length; i++) {
            final expected = _metres(points[i], 'otherDistanceM');
            final actual = _other(matches[i]);
            if (expected != null &&
                (expected - ResolveZone.boundaryRadiusM).abs() <= _toleranceM) {
              continue;
            }
            expect(
              _within(actual, ResolveZone.boundaryRadiusM),
              _within(expected, ResolveZone.boundaryRadiusM),
              reason: 'point $i: ours $actual m, shapely $expected m',
            );
            if (_within(expected, ResolveZone.boundaryRadiusM)) flagged++;
          }
          expect(flagged, greaterThan(0));
        });

        test('${sample['name']}: distances agree with shapely within '
            '${_toleranceM.toInt()} m', () {
          for (var i = 0; i < points.length; i++) {
            final expected = _metres(points[i], 'otherDistanceM');
            final actual = _other(matches[i]);
            if (expected == null || actual == null) continue;
            if (_resolved(matches[i]) !=
                (_name(points[i], 'containing') ??
                    _name(points[i], 'nearest'))) {
              continue;
            }
            expect(actual, closeTo(expected, _toleranceM), reason: 'point $i');
          }
        });
      }
    });
  }
}
