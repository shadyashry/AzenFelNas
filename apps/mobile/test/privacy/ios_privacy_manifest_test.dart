import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

final String _manifest = File('ios/Runner/PrivacyInfo.xcprivacy')
    .readAsStringSync();

/// The `<key>` [key] followed by [value], ignoring whitespace and comments.
bool _keyIs(String key, String value) => RegExp(
  '<key>$key</key>\\s*(<!--[\\s\\S]*?-->\\s*)*${RegExp.escape(value)}',
).hasMatch(_manifest);

/// Required-reason API categories and the Swift calls that need them
/// (developer.apple.com/documentation/bundleresources/describing-use-of-required-reason-api).
final _requiredReasonApis = {
  'NSPrivacyAccessedAPICategoryUserDefaults': RegExp(r'\bUserDefaults\b'),
  'NSPrivacyAccessedAPICategoryFileTimestamp': RegExp(
    r'\b(creationDate|modificationDate|contentModificationDate|'
    r'getattrlist|fstat|lstat)\b',
  ),
  'NSPrivacyAccessedAPICategorySystemBootTime': RegExp(
    r'\b(systemUptime|mach_absolute_time)\b',
  ),
  'NSPrivacyAccessedAPICategoryDiskSpace': RegExp(
    r'\b(volumeAvailableCapacity\w*|systemFreeSize|statfs)\b',
  ),
  'NSPrivacyAccessedAPICategoryActiveKeyboards': RegExp(
    r'\bactiveInputModes\b',
  ),
};

void main() {
  test('REQ-ALM-036 PrivacyInfo.xcprivacy is bundled in Runner', () {
    final project = File(
      'ios/Runner.xcodeproj/project.pbxproj',
    ).readAsStringSync();

    expect(project, contains('PrivacyInfo.xcprivacy in Resources'));
  });

  test('REQ-PRIV-001 the privacy manifest declares no tracking and no '
      'collected data', () {
    expect(_keyIs('NSPrivacyTracking', '<false/>'), isTrue);
    expect(_keyIs('NSPrivacyTrackingDomains', '<array/>'), isTrue);
    expect(_keyIs('NSPrivacyCollectedDataTypes', '<array/>'), isTrue);
    final info = File('ios/Runner/Info.plist').readAsStringSync();
    expect(info, isNot(contains('NSUserTrackingUsageDescription')));
  });

  test('REQ-ALM-036 every declared API category has an approved reason', () {
    final entries = RegExp(
      r'<string>(NSPrivacyAccessedAPICategory\w+)</string>\s*'
      r'<key>NSPrivacyAccessedAPITypeReasons</key>\s*<array>([\s\S]*?)</array>',
    ).allMatches(_manifest).toList();

    expect(entries, isNotEmpty);
    for (final e in entries) {
      expect(
        RegExp(r'<string>[0-9A-F]{4}\.\d</string>').hasMatch(e.group(2) ?? ''),
        isTrue,
        reason: '${e.group(1)} has no reason code',
      );
    }
  });

  test('REQ-ALM-036 every required-reason API the Swift code calls is '
      'declared', () {
    final swift = [
      for (final root in ['ios/Runner', 'ios/AthanKit/Sources'])
        for (final f in Directory(root).listSync(recursive: true))
          if (f is File && f.path.endsWith('.swift')) f.readAsStringSync(),
    ].join('\n');

    for (final MapEntry(key: category, value: api)
        in _requiredReasonApis.entries) {
      if (api.hasMatch(swift)) {
        expect(_manifest, contains(category), reason: category);
      }
    }
  });
}
