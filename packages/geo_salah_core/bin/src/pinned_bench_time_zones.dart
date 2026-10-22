import 'dart:io';
import 'dart:isolate';

// The bench is a development executable that the lab runs inside the
// workspace (§15 D29); dm_civil_time depends on this package, so it can only
// be a dev dependency here (§15 D68).
// ignore: depend_on_referenced_packages
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/bench/bench_time_zones.dart';

/// The bench's zones: the pinned TZDB that `dm_civil_time` carries under
/// `data/tzdata/<version>/` (§15 D68).
///
/// `dm_civil_time` implements the engine's `TzDatabase` port and depends on
/// `geo_salah_core`, so `geo_salah_core` reaches it only as a dev dependency,
/// from `bin/`, `tool/` and `test/`; `lib/` keeps depending on the port alone.
final class PinnedBenchTimeZones implements BenchTimeZones {
  const new _(this._db);

  /// Reads the single pinned version; throws [FileSystemException] or
  /// [FormatException] when it is missing or invalid.
  factory load() {
    final library = Isolate.resolvePackageUriSync(
      Uri.parse('package:dm_civil_time/dm_civil_time.dart'),
    );
    if (library == null) {
      throw const FileSystemException('cannot resolve package:dm_civil_time');
    }
    final root = Directory.fromUri(library.resolve('../data/tzdata/'));
    final versions = root.listSync().whereType<Directory>().toList();
    if (versions.length != 1) {
      throw FileSystemException('expected one pinned tzdata', root.path);
    }
    final directory = versions.single;
    final version = directory.uri.pathSegments.lastWhere((s) => s.isNotEmpty);
    final bytes = File('${directory.path}/tzdata.tzf').readAsBytesSync();
    return switch (const ReadTzfDatabase()(bytes, version: version)) {
      Ok(:final value) => PinnedBenchTimeZones._(value),
      Err(:final failure) => throw FormatException(failure.detail),
    };
  }

  final PinnedTzDatabase _db;

  @override
  bool supports(String zoneId) => _db.zoneIds.contains(zoneId);

  @override
  String get version => _db.version;

  @override
  int offsetSecondsAt(String zoneId, int utcMs) =>
      _db.offsetSecondsAt(zoneId, utcMs);
}
