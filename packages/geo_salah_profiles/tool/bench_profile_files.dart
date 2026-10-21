// The seed profiles the engine bench reads and their compiled copies
// (DESIGN.md §15 D51), shared by tool/sync_bench_profiles.dart and the
// freshness test. Paths are relative to packages/geo_salah_profiles.
import 'dart:convert';
import 'dart:io';

import 'yaml_json.dart';

/// Each bench seed profile and the compiled JSON the bench reads.
final List<(File, File)> benchProfileFiles = [
  (
    File('../../profiles/engine/engine.default.yaml'),
    File('../geo_salah_core/bench/profiles/engine.default.json'),
  ),
];

/// The compiled text of [source]: indented JSON with a final newline.
String compiledBenchProfile(File source) =>
    '${const JsonEncoder.withIndent('  ').convert(readYamlAsJson(source))}\n';
