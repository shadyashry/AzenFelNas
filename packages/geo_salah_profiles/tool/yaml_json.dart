// Reads a profile YAML file (profiles/**/*.yaml) as the JSON value it
// denotes, for the tests and tools of geo_salah_profiles. The app never reads
// YAML: profiles reach it compiled to JSON (ADR-008).
import 'dart:io';

import 'package:yaml/yaml.dart';

/// The JSON value of the YAML document in [file]: maps with string keys,
/// lists, strings, numbers, booleans and null, in document order.
///
/// Throws [FormatException] for YAML that is not plain JSON data (a
/// non-string key, a tag or an anchor that resolves to another type).
Object? readYamlAsJson(File file) => _json(loadYaml(file.readAsStringSync()));

Object? _json(Object? node) => switch (node) {
  final YamlMap map => {
    for (final MapEntry(:key, :value) in map.entries)
      switch (key) {
        final String name => name,
        _ => throw FormatException('Non-string key $key in YAML'),
      }: _json(
        value,
      ),
  },
  final YamlList list => [for (final item in list) _json(item)],
  null || final String _ || final num _ || final bool _ => node,
  _ => throw FormatException('Not JSON data in YAML: $node'),
};
