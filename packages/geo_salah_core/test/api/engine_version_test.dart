import 'dart:io';

import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:test/test.dart';

void main() {
  test('EngineVersion.current is the package version (REQ-DOM-004)', () {
    final pubspec = File('pubspec.yaml').readAsLinesSync();
    expect(pubspec, contains('version: ${EngineVersion.current}'));
  });
}
