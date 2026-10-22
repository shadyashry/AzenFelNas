import 'dart:typed_data';

import 'package:dm_civil_time/src/tzdb/pinned_tz_database.dart';
import 'package:dm_civil_time/src/tzdb/tzdb_failure.dart';
import 'package:dm_civil_time/src/tzdb/zone_rules.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Reads a `tzdata` payload — the `package:timezone` `.tzf` database built
/// by the data pipeline (§9.5) — into a [PinnedTzDatabase] (§15 D66).
///
/// Layout (big-endian, as `package:timezone` 0.11.2 writes it): a sequence of
/// chunks, each `u32 length` (a multiple of 8), `u32` padding and `length`
/// bytes holding one location: a header of eight `u32`s (name, abbreviations,
/// zones and transitions as offset/length pairs), the ASCII name, NUL-ended
/// abbreviations, zones of 8 bytes (`i32` offset in seconds, `u8` isDst,
/// `u8` abbreviation index, 2 padding) and transitions as `f64` seconds
/// followed by one `u8` zone index each.
///
/// Every offset, length, index and value is checked, so a payload that is
/// not such a database is a [TzdbFailure], never an exception. Pure and
/// deterministic.
final class ReadTzfDatabase {
  /// The reader.
  const new();

  /// IANA release names: four-digit year and one or more lowercase letters.
  static final RegExp versionPattern = RegExp(r'^\d{4}[a-z]+$');

  /// Largest |offset| accepted, 26 h (local mean times stay well inside).
  static const int maxAbsOffsetSeconds = 26 * 3600;

  /// Reads [payload] as TZDB release [version].
  Result<PinnedTzDatabase, TzdbFailure> call(
    Uint8List payload, {
    required String version,
  }) {
    if (!versionPattern.hasMatch(version)) {
      return Result.err(
        TzdbFailure.payloadInvalid('version "$version" is not an IANA name'),
      );
    }
    final zones = <String, ZoneRules>{};
    final data = ByteData.sublistView(payload);
    var offset = 0;
    while (offset < payload.length) {
      if (payload.length - offset < 8) {
        return _invalid('truncated chunk header at byte $offset');
      }
      final length = data.getUint32(offset);
      offset += 8;
      if (length % 8 != 0 || length > payload.length - offset) {
        return _invalid('chunk of $length bytes at byte $offset');
      }
      switch (_location(
        Uint8List.sublistView(payload, offset, offset + length),
      )) {
        case Ok(value: final rules):
          if (zones.containsKey(rules.name)) {
            return _invalid('zone ${rules.name} appears twice');
          }
          zones[rules.name] = rules;
        case Err(:final failure):
          return Result.err(failure);
      }
      offset += length;
    }
    if (zones.isEmpty) return _invalid('no zones');
    return Result.ok(PinnedTzDatabase.internal(version: version, zones: zones));
  }

  static Result<ZoneRules, TzdbFailure> _location(Uint8List chunk) {
    if (chunk.length < 32) return _invalid('location header truncated');
    final header = ByteData.sublistView(chunk);
    int u32(int index) => header.getUint32(index * 4);
    final (nameAt, nameLength) = (u32(0), u32(1));
    final (abbrsAt, abbrsLength) = (u32(2), u32(3));
    final (zonesAt, zoneCount) = (u32(4), u32(5));
    final (transAt, transCount) = (u32(6), u32(7));
    if (!_inside(chunk, nameAt, nameLength) ||
        !_inside(chunk, abbrsAt, abbrsLength) ||
        !_inside(chunk, zonesAt, zoneCount * 8) ||
        !_inside(chunk, transAt, transCount * 9)) {
      return _invalid('location section outside its chunk');
    }
    final nameBytes = Uint8List.sublistView(chunk, nameAt, nameAt + nameLength);
    if (nameLength == 0 || nameBytes.any((b) => b <= 0x20 || b > 0x7e)) {
      return _invalid('zone name is not printable ASCII');
    }
    final name = String.fromCharCodes(nameBytes);
    final abbreviationCount = Uint8List.sublistView(
      chunk,
      abbrsAt,
      abbrsAt + abbrsLength,
    ).where((b) => b == 0).length;
    if (zoneCount == 0) return _invalid('$name has no zones');
    final offsets = <int>[];
    final dst = <bool>[];
    for (var i = 0; i < zoneCount; i++) {
      final at = zonesAt + i * 8;
      final seconds = header.getInt32(at);
      if (seconds.abs() > maxAbsOffsetSeconds ||
          header.getUint8(at + 4) > 1 ||
          header.getUint8(at + 5) >= abbreviationCount) {
        return _invalid('$name zone $i is invalid');
      }
      offsets.add(seconds);
      dst.add(header.getUint8(at + 4) == 1);
    }
    final starts = <int>[];
    final startOffsets = <int>[];
    final indexes = <int>[];
    for (var i = 0; i < transCount; i++) {
      final seconds = header.getFloat64(transAt + i * 8);
      final index = header.getUint8(transAt + transCount * 8 + i);
      if (!seconds.isFinite ||
          seconds != seconds.truncateToDouble() ||
          index >= zoneCount) {
        return _invalid('$name transition $i is invalid');
      }
      final ms = seconds.toInt() * 1000;
      if (starts.isNotEmpty && ms <= starts.last) {
        return _invalid('$name transitions are not increasing');
      }
      starts.add(ms);
      startOffsets.add(offsets[index]);
      indexes.add(index);
    }
    return Result.ok(
      ZoneRules(
        name: name,
        initialOffsetSeconds: offsets[_firstZone(dst, indexes)],
        startsUtcMs: starts,
        offsetsSeconds: startOffsets,
      ),
    );
  }

  /// The zone in effect before the first transition: Go's `lookupFirstZone`
  /// rule, which `package:timezone` copies.
  static int _firstZone(List<bool> dst, List<int> indexes) {
    if (!indexes.contains(0)) return 0;
    if (indexes.isNotEmpty && dst[indexes.first]) {
      for (var zi = indexes.first - 1; zi >= 0; zi--) {
        if (!dst[zi]) return zi;
      }
    }
    for (final zi in indexes) {
      if (!dst[zi]) return zi;
    }
    return 0;
  }

  static bool _inside(Uint8List chunk, int at, int length) =>
      at <= chunk.length && length <= chunk.length - at;

  static Result<Never, TzdbFailure> _invalid(String reason) =>
      Result.err(TzdbFailure.payloadInvalid(reason));
}
