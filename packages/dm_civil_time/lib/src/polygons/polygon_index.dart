import 'dart:math' as math;
import 'dart:typed_data';

import 'package:dm_civil_time/src/polygons/geo_point_e6.dart';
import 'package:dm_civil_time/src/polygons/local_projection.dart';
import 'package:dm_civil_time/src/polygons/locate_in_polygons.dart';
import 'package:dm_civil_time/src/polygons/polygon_dataset.dart';
import 'package:dm_civil_time/src/polygons/polygon_match.dart';
import 'package:meta/meta.dart';

/// An in-memory `tz_polygons` or `country_polygons` index (§9.5, §15 D23,
/// D70–D71), read by `ReadPolygonIndex`; the [LocateInPolygons] adapter.
///
/// A point is inside a polygon by the even-odd rule over all its rings
/// (exact integer arithmetic; a point on an edge may fall either way). The
/// containing polygon is the first in payload order among those listed for
/// the point's grid cell. Distances use [LocalProjection]. Immutable, pure
/// and deterministic.
final class PolygonIndex implements LocateInPolygons {
  /// Wraps decoded arrays; only `ReadPolygonIndex` calls this, after it has
  /// checked every invariant below.
  @internal
  const new internal({
    required this.dataset,
    required this.names,
    required this._cellOffsets,
    required this._cellIds,
    required this._nameIndexes,
    required this._boxes,
    required this._ringStarts,
    required this._pointStarts,
    required this._points,
  });

  /// Grid columns (1° of longitude each).
  static const int columns = 360;

  /// Grid rows (1° of latitude each).
  static const int rows = 180;

  /// The package this index was read from.
  final PolygonDataset dataset;

  /// The name table: zone ids or ISO 3166-1 alpha-2 codes, sorted.
  final List<String> names;

  // 64 801 prefix offsets into _cellIds.
  final Uint32List _cellOffsets;
  final Uint32List _cellIds;
  // Per polygon: name index; bbox as minLon, minLat, maxLon, maxLat.
  final Uint32List _nameIndexes;
  final Int32List _boxes;
  // Polygon p has rings _ringStarts[p] .. _ringStarts[p + 1]; ring r has
  // points _pointStarts[r] .. _pointStarts[r + 1] of _points (lon, lat).
  final Uint32List _ringStarts;
  final Uint32List _pointStarts;
  final Int32List _points;

  /// Number of polygons.
  int get polygonCount => _nameIndexes.length;

  @override
  PolygonMatch locate(GeoPointE6 point, {required int searchRadiusM}) {
    RangeError.checkValueInInterval(searchRadiusM, 1, 1 << 30, 'searchRadiusM');
    final cell = _cell(point.lonE6, point.latE6);
    int? inside;
    for (var i = _cellOffsets[cell]; i < _cellOffsets[cell + 1]; i++) {
      if (_contains(_cellIds[i], point)) {
        inside = _cellIds[i];
        break;
      }
    }
    final distances = _distances(point, searchRadiusM);
    if (inside != null) {
      final name = _name(inside);
      return InsidePolygon(name, otherDistanceM: _other(distances, name));
    }
    if (distances.isEmpty) return const NoPolygon();
    var nearest = distances.keys.first;
    for (final MapEntry(key: id, value: metres) in distances.entries) {
      final best = distances[nearest] ?? double.infinity;
      if (metres < best || (metres == best && id < nearest)) nearest = id;
    }
    final name = _name(nearest);
    return NearPolygon(
      name,
      distanceM: distances[nearest] ?? 0,
      otherDistanceM: _other(distances, name),
    );
  }

  String _name(int polygon) => names[_nameIndexes[polygon]];

  double? _other(Map<int, double> distances, String name) {
    double? best;
    for (final MapEntry(key: id, value: metres) in distances.entries) {
      if (_name(id) != name && (best == null || metres < best)) best = metres;
    }
    return best;
  }

  static int _cell(int lonE6, int latE6) {
    final row = math.min((latE6 / 1e6).floor() + 90, rows - 1);
    final column = math.min((lonE6 / 1e6).floor() + 180, columns - 1);
    return row * columns + column;
  }

  /// Distance of every polygon within [radiusM] of [point], by polygon id.
  Map<int, double> _distances(GeoPointE6 point, int radiusM) {
    final projection = LocalProjection(point);
    final latSpan = projection.latSpanE6(radiusM);
    final lonSpan = projection.lonSpanE6(radiusM);
    final rowFrom = math.max(((point.latE6 - latSpan) / 1e6).floor(), -90);
    final rowTo = math.min(((point.latE6 + latSpan) / 1e6).floor(), 89);
    final colFrom = ((point.lonE6 - lonSpan) / 1e6).floor();
    final colTo = ((point.lonE6 + lonSpan) / 1e6).floor();
    final allColumns = colTo - colFrom + 1 >= columns;
    final seen = <int>{};
    final distances = <int, double>{};
    for (var row = rowFrom; row <= rowTo; row++) {
      for (
        var c = allColumns ? -180 : colFrom;
        c <= (allColumns ? 179 : colTo);
        c++
      ) {
        final cell = (row + 90) * columns + (c + 180) % columns;
        for (var i = _cellOffsets[cell]; i < _cellOffsets[cell + 1]; i++) {
          final id = _cellIds[i];
          if (!seen.add(id)) continue;
          final metres = _distance(id, point, projection, radiusM);
          if (metres <= radiusM) distances[id] = metres;
        }
      }
    }
    return distances;
  }

  double _distance(
    int polygon,
    GeoPointE6 point,
    LocalProjection projection,
    int radiusM,
  ) {
    if (_contains(polygon, point)) return 0;
    var best = double.infinity;
    final latSpan = projection.latSpanE6(radiusM);
    for (var r = _ringStarts[polygon]; r < _ringStarts[polygon + 1]; r++) {
      for (var p = _pointStarts[r]; p + 1 < _pointStarts[r + 1]; p++) {
        final aLat = _points[2 * p + 1];
        final bLat = _points[2 * p + 3];
        // Both ends on one side beyond the box: the segment cannot be near.
        if ((aLat - point.latE6 > latSpan && bLat - point.latE6 > latSpan) ||
            (point.latE6 - aLat > latSpan && point.latE6 - bLat > latSpan)) {
          continue;
        }
        final metres = projection.segmentDistanceM(
          _points[2 * p],
          aLat,
          _points[2 * p + 2],
          bLat,
        );
        if (metres < best) best = metres;
      }
    }
    return best;
  }

  bool _contains(int polygon, GeoPointE6 point) {
    final px = point.lonE6;
    final py = point.latE6;
    final box = 4 * polygon;
    if (px < _boxes[box] ||
        py < _boxes[box + 1] ||
        px > _boxes[box + 2] ||
        py > _boxes[box + 3]) {
      return false;
    }
    var inside = false;
    for (var r = _ringStarts[polygon]; r < _ringStarts[polygon + 1]; r++) {
      for (var p = _pointStarts[r]; p + 1 < _pointStarts[r + 1]; p++) {
        final xi = _points[2 * p];
        final yi = _points[2 * p + 1];
        final xj = _points[2 * p + 2];
        final yj = _points[2 * p + 3];
        if ((yi > py) != (yj > py)) {
          // Does the edge cross the ray from the point towards +lon?
          final lhs = (px - xi) * (yj - yi);
          final rhs = (py - yi) * (xj - xi);
          if (yj > yi ? lhs < rhs : lhs > rhs) inside = !inside;
        }
      }
    }
    return inside;
  }
}
