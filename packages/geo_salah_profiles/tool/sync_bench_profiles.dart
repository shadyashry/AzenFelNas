// Compiles the seed profiles the engine bench reads (DESIGN.md §15 D48, D51):
// profiles/engine/engine.default.yaml → packages/geo_salah_core/bench/profiles/
// engine.default.json, as indented JSON in document order. The bench cannot
// read YAML or import this package (geo_salah_profiles depends on
// geo_salah_core), so it reads this compiled copy.
// test/bench_profiles_fresh_test.dart fails when the copy is stale.
//
// Run from packages/geo_salah_profiles after changing a bench seed profile:
//
//   dart run tool/sync_bench_profiles.dart
import 'dart:io';

import 'bench_profile_files.dart';

void main() {
  for (final (source, target) in benchProfileFiles) {
    target.writeAsStringSync(compiledBenchProfile(source));
    stdout.writeln('${source.path} -> ${target.path}');
  }
}
