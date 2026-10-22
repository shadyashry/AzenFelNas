import 'dart:convert';
import 'dart:typed_data';

import 'package:dm_civil_time/src/polygons/geo_point_e6.dart';
import 'package:dm_civil_time/src/polygons/polygon_dataset.dart';
import 'package:dm_civil_time/src/polygons/polygon_index.dart';
import 'package:dm_civil_time/src/polygons/polygon_index_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Reads a `tz_polygons` or `country_polygons` payload into a
/// [PolygonIndex] (§9.5, `schemas/tz_polygons.v1.ksy`, §15 D23, D70).
///
/// Every count, offset, index, ring and coordinate is checked — magic and
/// version, UTF-8 names, monotonic grid offsets, polygon ids and name
/// indexes in range, closed rings of at least four points inside their
/// polygon's bounding box, and no trailing bytes — so a payload that is not
/// such an index is a [PolygonIndexFailure], never an exception. Pure and
/// deterministic.
final class ReadPolygonIndex {
  /// The reader.
  const new();

  /// Payload layout version this reader understands.
  static const int layoutVersion = 1;

  /// Grid cells (360 × 180).
  static const int cells = PolygonIndex.columns * PolygonIndex.rows;

  /// Reads [payload] as a [dataset] index.
  Result<PolygonIndex, PolygonIndexFailure> call(
    Uint8List payload, {
    required PolygonDataset dataset,
  }) {
    try {
      return Result.ok(_Cursor(payload).index(dataset));
    } on _Invalid catch (invalid) {
      return Result.err(PolygonIndexFailure.payloadInvalid(invalid.reason));
    }
  }
}

final class _Invalid implements Exception {
  const new(this.reason);

  final String reason;
}

final class _Cursor {
  new(this.bytes) : data = ByteData.sublistView(bytes);

  final Uint8List bytes;
  final ByteData data;
  int at = 0;

  void need(int count, String what) {
    if (count < 0 || count > bytes.length - at) {
      throw _Invalid('$what truncated at byte $at');
    }
  }

  int u8() {
    need(1, 'u1');
    return data.getUint8(at++);
  }

  int u16() {
    need(2, 'u2');
    final value = data.getUint16(at, Endian.little);
    at += 2;
    return value;
  }

  int u32() {
    need(4, 'u4');
    final value = data.getUint32(at, Endian.little);
    at += 4;
    return value;
  }

  int s32() {
    need(4, 's4');
    final value = data.getInt32(at, Endian.little);
    at += 4;
    return value;
  }

  PolygonIndex index(PolygonDataset dataset) {
    need(4, 'magic');
    final magic = String.fromCharCodes(bytes, 0, 4);
    at = 4;
    if (magic != dataset.magic) {
      throw _Invalid('magic is not ${dataset.magic}');
    }
    final version = u16();
    if (version != ReadPolygonIndex.layoutVersion) {
      throw _Invalid('layout version $version');
    }
    final names = _names(u32());
    final polygonCount = u32();
    // Each polygon takes at least 22 header bytes, so a huge count is a lie.
    need(polygonCount * 22, 'polygons');
    final offsets = Uint32List(ReadPolygonIndex.cells + 1);
    for (var i = 0; i < offsets.length; i++) {
      offsets[i] = u32();
      if (i == 0 ? offsets[i] != 0 : offsets[i] < offsets[i - 1]) {
        throw _Invalid('grid offset $i is not monotonic from 0');
      }
    }
    need(offsets.last * 4, 'grid ids');
    final ids = Uint32List(offsets.last);
    for (var i = 0; i < ids.length; i++) {
      ids[i] = u32();
      if (ids[i] >= polygonCount) throw _Invalid('grid id $i out of range');
    }
    return _polygons(dataset, names, offsets, ids, polygonCount);
  }

  List<String> _names(int count) {
    final names = <String>[];
    for (var i = 0; i < count; i++) {
      final length = u8();
      need(length, 'name $i');
      final String name;
      try {
        name = utf8.decode(Uint8List.sublistView(bytes, at, at + length));
      } on FormatException {
        throw _Invalid('name $i is not UTF-8');
      }
      at += length;
      if (name.isEmpty) throw _Invalid('name $i is empty');
      names.add(name);
    }
    if (names.isEmpty) throw const _Invalid('no names');
    return List.unmodifiable(names);
  }

  PolygonIndex _polygons(
    PolygonDataset dataset,
    List<String> names,
    Uint32List offsets,
    Uint32List ids,
    int polygonCount,
  ) {
    final nameIndexes = Uint32List(polygonCount);
    final boxes = Int32List(4 * polygonCount);
    final ringStarts = Uint32List(polygonCount + 1);
    final pointStarts = <int>[0];
    final points = <int>[];
    for (var p = 0; p < polygonCount; p++) {
      nameIndexes[p] = u32();
      if (nameIndexes[p] >= names.length) {
        throw _Invalid('polygon $p name index out of range');
      }
      for (var i = 0; i < 4; i++) {
        boxes[4 * p + i] = s32();
      }
      final ringCount = u16();
      if (ringCount == 0) throw _Invalid('polygon $p has no rings');
      for (var r = 0; r < ringCount; r++) {
        _ring(p, r, boxes, points);
        pointStarts.add(points.length ~/ 2);
      }
      ringStarts[p + 1] = ringStarts[p] + ringCount;
    }
    if (at != bytes.length) throw _Invalid('trailing bytes at $at');
    return PolygonIndex.internal(
      dataset: dataset,
      names: names,
      cellOffsets: offsets,
      cellIds: ids,
      nameIndexes: nameIndexes,
      boxes: boxes,
      ringStarts: ringStarts,
      pointStarts: Uint32List.fromList(pointStarts),
      points: Int32List.fromList(points),
    );
  }

  void _ring(int p, int r, Int32List boxes, List<int> points) {
    final count = u32();
    if (count < 4) throw _Invalid('polygon $p ring $r has $count points');
    need(count * 8, 'polygon $p ring $r');
    final first = points.length;
    var lon = 0;
    var lat = 0;
    for (var i = 0; i < count; i++) {
      lon += s32();
      lat += s32();
      if (lon < boxes[4 * p] ||
          lat < boxes[4 * p + 1] ||
          lon > boxes[4 * p + 2] ||
          lat > boxes[4 * p + 3] ||
          lon.abs() > GeoPointE6.maxLonE6 ||
          lat.abs() > GeoPointE6.maxLatE6) {
        throw _Invalid('polygon $p ring $r point $i outside its box');
      }
      points
        ..add(lon)
        ..add(lat);
    }
    if (points[first] != lon || points[first + 1] != lat) {
      throw _Invalid('polygon $p ring $r is not closed');
    }
  }
}
