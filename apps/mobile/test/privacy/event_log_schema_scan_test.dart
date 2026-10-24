import 'dart:convert';
import 'dart:io';

import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _json(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, Object?>;

final Map<String, Object?> _eventLog = _json(
  '../../schemas/event_log.v1.schema.json',
);

Map<String, Object?> _attrsSchema() => switch (_eventLog) {
  {'properties': {'attrs': final Map<String, Object?> attrs}} => attrs,
  _ => throw StateError('event_log.v1 has no attrs'),
};

Map<String, Object?> _attrsProperties() => switch (_attrsSchema()) {
  {'properties': final Map<String, Object?> p} => p,
  _ => throw StateError('attrs has no properties'),
};

/// Every (path, schema object) under [node].
Iterable<(String, Map<String, Object?>)> _schemaObjects(
  Object? node, [
  String path = r'$',
]) sync* {
  if (node is Map<String, Object?>) {
    yield (path, node);
    for (final MapEntry(:key, :value) in node.entries) {
      yield* _schemaObjects(value, '$path.$key');
    }
  } else if (node is List<Object?>) {
    for (var i = 0; i < node.length; i++) {
      yield* _schemaObjects(node[i], '$path[$i]');
    }
  }
}

/// The names declared in the `class`/`struct` [type] block of [source].
Set<String> _fields(String source, String type, RegExp field) {
  final start = source.indexOf(type);
  expect(start, isNonNegative, reason: '$type not found');
  final end = source.indexOf(RegExp('^[)}]', multiLine: true), start);
  return {
    for (final m in field.allMatches(source.substring(start, end)))
      m.group(1) ?? '',
  };
}

void main() {
  test('REQ-PRIV-001 event_log.v1 attrs is closed and its keys are exactly '
      "Appendix J's allow-list", () {
    final design = File('../../DESIGN.md').readAsStringSync();
    final listed = RegExp(
      'key allow-list `([a-zA-Z, ]+)`',
    ).firstMatch(design)?.group(1);

    expect(_attrsSchema()['additionalProperties'], isFalse);
    expect(_eventLog['additionalProperties'], isFalse);
    expect(listed, isNotNull);
    expect(
      _attrsProperties().keys.toSet(),
      (listed ?? '').split(', ').toSet(),
    );
  });

  test('REQ-PRIV-001 no attrs value pattern admits a decimal coordinate', () {
    const coordinates = [
      '30.0444',
      '31.235749',
      '-30.04',
      '30.04,31.23',
      '30.044412 31.235749',
      '21.4225',
    ];
    for (final MapEntry(key: name, value: property)
        in _attrsProperties().entries) {
      if (property case {'pattern': final String pattern}) {
        final re = RegExp(pattern);
        for (final c in coordinates) {
          expect(re.hasMatch(c), isFalse, reason: '$name admits $c');
        }
      } else if (property case {'type': 'string'}) {
        fail('$name is a string without a pattern');
      }
    }
  });

  test('REQ-PRIV-001 the Dart, Kotlin and Swift event writers know exactly '
      'the schema keys', () {
    final schemaKeys = _attrsProperties().keys.toSet();
    final fixture = _json(
      '../../schemas/fixtures/event_log/valid/all_attrs.json',
    );
    final dart = EventLogEntry.fromJson(fixture).attrs.toJson().keys.toSet();
    final kotlin = _fields(
      File(
        'android/athan-core/src/main/kotlin/app/dailymuslim/athan/plan/'
        'EventLogEntry.kt',
      ).readAsStringSync(),
      'data class EventAttrs(',
      RegExp(r'val (\w+):'),
    );
    final swift = _fields(
      File(
        'ios/AthanKit/Sources/AthanKit/Plan/EventLogEntry.swift',
      ).readAsStringSync(),
      'struct EventAttrs:',
      RegExp(r'let (\w+):'),
    );

    expect(dart, schemaKeys);
    expect(kotlin, schemaKeys);
    expect(swift, schemaKeys);
  });

  test('REQ-PRIV-001 REQ-PRIV-005 the event log, telemetry and diagnostic '
      'schemas are closed and hold no raw coordinate', () {
    final rawCoordinate = RegExp(
      r'^(lat|lon|lng|latitude|longitude)(Deg|E6|itude)?$',
    );
    for (final name in [
      'event_log',
      'telemetry_aggregate',
      'diagnostic_bundle',
    ]) {
      final schema = _json('../../schemas/$name.v1.schema.json');
      for (final (path, node) in _schemaObjects(schema)) {
        if (node case {'properties': final Map<String, Object?> props}) {
          expect(
            node['additionalProperties'],
            isFalse,
            reason: '$name $path is open',
          );
          for (final MapEntry(:key, :value) in props.entries) {
            expect(
              rawCoordinate.hasMatch(key),
              isFalse,
              reason: '$name $path.$key',
            );
            if (key.endsWith('E2')) {
              expect(value, containsPair('type', 'integer'), reason: key);
            }
          }
        }
      }
    }
  });
}
