// The engine bench of the Accuracy Lab (DESIGN.md §6.1, §9.4, §15 D29):
// `dart run geo_salah_core:bench` reads `bench_request.v1` JSONL on stdin and
// writes exactly one line per request, in order, on stdout — a
// `calculation_trace.v1` or a `bench_failure.v1` document. Blank lines are
// not requests. A line that breaks the contract stops the run with exit
// status 2 and a message on stderr; the lines already written stand.
//
// The profiles are the stand-in data files in `bench/profiles/` of this
// package (§15 D48), found through the package's own URI so the bench works
// from any working directory. An unreadable profile file is exit status 2.
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:geo_salah_core/src/bench/bench_profiles.dart';
import 'package:geo_salah_core/src/bench/bench_runner.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';

Future<void> main() async {
  final Map<String, PrayerProfile> profiles;
  try {
    profiles = await _profiles();
  } on FormatException catch (e) {
    stderr.writeln('bench: bench profiles: ${e.message}');
    exitCode = 2;
    return;
  } on FileSystemException catch (e) {
    stderr.writeln('bench: bench profiles: ${e.message} (${e.path})');
    exitCode = 2;
    return;
  }
  final runner = BenchRunner(profiles: profiles);
  final lines = stdin.transform(utf8.decoder).transform(const LineSplitter());
  var number = 0;
  await for (final line in lines) {
    number++;
    if (line.trim().isEmpty) continue;
    try {
      stdout.writeln(jsonEncode(runner.answer(_object(jsonDecode(line)))));
    } on FormatException catch (e) {
      stderr.writeln('bench: request line $number: ${e.message}');
      exitCode = 2;
      break;
    }
  }
  await stdout.flush();
}

/// Reads `bench/profiles/*.json` next to this package's `lib/`.
Future<Map<String, PrayerProfile>> _profiles() async {
  final library = await Isolate.resolvePackageUri(
    Uri.parse('package:geo_salah_core/geo_salah_core.dart'),
  );
  if (library == null) {
    throw const FileSystemException('cannot resolve package:geo_salah_core');
  }
  final root = File.fromUri(library).parent.parent;
  final files =
      Directory.fromUri(root.uri.resolve(BenchProfiles.directory))
          .listSync()
          .whereType<File>()
          .where((file) => file.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  return BenchProfiles.byId([
    for (final file in files) jsonDecode(file.readAsStringSync()),
  ]);
}

Map<String, Object?> _object(Object? json) => switch (json) {
  final Map<String, Object?> object => object,
  _ => throw const FormatException('A request line is not a JSON object'),
};
