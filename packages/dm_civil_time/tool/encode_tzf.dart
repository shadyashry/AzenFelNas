// Encodes a zic output directory into the `package:timezone` `.tzf` database
// that the `tzdata` package carries (DESIGN.md §9.5, §15 D66).
//
// It is the "all locations" step of package:timezone's own
// `tool/encode_tzf.dart` (0.11.2): every TZif file becomes a location, the
// database passes `filterTimeZoneData` with no date or location filter, and
// `tzdbSerialize` writes it sorted by zone name, so equal input gives equal
// bytes. The data pipeline (`dm-pipelines tzdata build`) runs it; run it from
// packages/dm_civil_time:
//
//   dart run tool/encode_tzf.dart <zoneinfo-dir> <out.tzf>
//
// Exit codes: 0 written, 2 usage or unreadable input.
import 'dart:io';

// The serializer and the filter are package:timezone's own tooling (its
// tool/encode_tzf.dart imports them the same way); they are not exported.
import 'package:timezone/src/tools.dart' as tools;
import 'package:timezone/src/tzdb.dart' as tzdb;
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/tzdata.dart' as tzfile;

void main(List<String> arguments) {
  if (arguments.length != 2) {
    stderr.writeln('usage: encode_tzf <zoneinfo-dir> <out.tzf>');
    exitCode = 2;
    return;
  }
  final root = Directory(arguments[0]);
  if (!root.existsSync()) {
    stderr.writeln('encode_tzf: no directory ${root.path}');
    exitCode = 2;
    return;
  }
  final db = tz.LocationDatabase();
  final files = root.listSync(recursive: true).whereType<File>().toList()
    ..sort((a, b) => a.path.compareTo(b.path));
  for (final file in files) {
    final name = file.path
        .substring(root.path.length)
        .replaceAll(r'\', '/')
        .replaceFirst(RegExp('^/+'), '');
    try {
      db.add(
        tools.tzfileLocationToNativeLocation(
          tzfile.Location.fromBytes(name, file.readAsBytesSync()),
        ),
      );
    } on FormatException catch (e) {
      stderr.writeln('encode_tzf: $name is not a TZif file: ${e.message}');
      exitCode = 2;
      return;
    }
  }
  final filtered = tools.filterTimeZoneData(db).db;
  File(arguments[1])
      .writeAsBytesSync(tzdb.tzdbSerialize(filtered), flush: true);
  stdout.writeln(
    'encode_tzf: ${filtered.locations.length} zones -> ${arguments[1]}',
  );
}
