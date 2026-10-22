import 'dart:convert';
import 'dart:typed_data';

/// Builds small `tz_polygons` / `country_polygons` payloads for tests, in
/// the layout of `schemas/tz_polygons.v1.ksy` (§15 D23). Every polygon is
/// listed in every grid cell its bounding box touches.
final class PolygonPayload {
  /// An empty builder writing [magic].
  new(this.magic);

  /// `TZPG` or `CTPG`.
  final String magic;

  final List<String> _names = [];
  final List<(int, List<List<(int, int)>>)> _polygons = [];

  /// Adds a polygon named [name] with [rings] of (lonE6, latE6) points,
  /// ring 0 outer; rings are closed here.
  void add(String name, List<List<(int, int)>> rings) {
    var index = _names.indexOf(name);
    if (index < 0) {
      _names.add(name);
      index = _names.length - 1;
    }
    _polygons.add((
      index,
      [
        for (final ring in rings) [...ring, ring.first],
      ],
    ));
  }

  /// Adds the axis-aligned box [lon0, lon1] × [lat0, lat1] in degrees.
  void box(String name, num lon0, num lat0, num lon1, num lat1) {
    int e6(num degrees) => (degrees * 1e6).round();
    add(name, [
      [
        (e6(lon0), e6(lat0)),
        (e6(lon1), e6(lat0)),
        (e6(lon1), e6(lat1)),
        (e6(lon0), e6(lat1)),
      ],
    ]);
  }

  /// The payload bytes.
  Uint8List build() {
    final out = BytesBuilder()..add(ascii.encode(magic));
    void u8(int v) => out.addByte(v);
    void u16(int v) => out.add(
      (ByteData(2)..setUint16(0, v, Endian.little)).buffer.asUint8List(),
    );
    void u32(int v) => out.add(
      (ByteData(4)..setUint32(0, v, Endian.little)).buffer.asUint8List(),
    );
    void s32(int v) => out.add(
      (ByteData(4)..setInt32(0, v, Endian.little)).buffer.asUint8List(),
    );
    u16(1);
    u32(_names.length);
    for (final name in _names) {
      final raw = utf8.encode(name);
      u8(raw.length);
      out.add(raw);
    }
    u32(_polygons.length);
    final cells = List.generate(64800, (_) => <int>[]);
    for (var id = 0; id < _polygons.length; id++) {
      final (minLon, minLat, maxLon, maxLat) = _box(_polygons[id].$2);
      for (
        var row = (minLat / 1e6).floor();
        row <= (maxLat / 1e6).floor();
        row++
      ) {
        for (
          var col = (minLon / 1e6).floor();
          col <= (maxLon / 1e6).floor();
          col++
        ) {
          final r = (row + 90).clamp(0, 179);
          final c = (col + 180).clamp(0, 359);
          if (!cells[r * 360 + c].contains(id)) cells[r * 360 + c].add(id);
        }
      }
    }
    var offset = 0;
    u32(0);
    for (final ids in cells) {
      offset += ids.length;
      u32(offset);
    }
    cells.expand((ids) => ids).forEach(u32);
    for (final (name, rings) in _polygons) {
      final (minLon, minLat, maxLon, maxLat) = _box(rings);
      u32(name);
      [minLon, minLat, maxLon, maxLat].forEach(s32);
      u16(rings.length);
      for (final ring in rings) {
        u32(ring.length);
        var (lon, lat) = (0, 0);
        for (final (x, y) in ring) {
          s32(x - lon);
          s32(y - lat);
          (lon, lat) = (x, y);
        }
      }
    }
    return out.takeBytes();
  }

  static (int, int, int, int) _box(List<List<(int, int)>> rings) {
    final xs = [for (final (x, _) in rings.first) x];
    final ys = [for (final (_, y) in rings.first) y];
    return (
      xs.reduce((a, b) => a < b ? a : b),
      ys.reduce((a, b) => a < b ? a : b),
      xs.reduce((a, b) => a > b ? a : b),
      ys.reduce((a, b) => a > b ? a : b),
    );
  }
}
