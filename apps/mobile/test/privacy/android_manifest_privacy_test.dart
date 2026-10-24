import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Advertising-identifier permissions a dependency could merge in.
const _adPermissions = [
  'com.google.android.gms.permission.AD_ID',
  'android.permission.ACCESS_ADSERVICES_AD_ID',
  'android.permission.ACCESS_ADSERVICES_ATTRIBUTION',
  'android.permission.ACCESS_ADSERVICES_TOPICS',
];

/// Every permission the release app may hold: the app's and athan-core's.
const _allowedPermissions = {
  'android.permission.ACCESS_COARSE_LOCATION',
  'android.permission.INTERNET',
  'android.permission.SCHEDULE_EXACT_ALARM',
  'android.permission.POST_NOTIFICATIONS',
  'android.permission.FOREGROUND_SERVICE',
  'android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK',
  'android.permission.RECEIVE_BOOT_COMPLETED',
  'android.permission.WAKE_LOCK',
  'android.permission.VIBRATE',
};

final _usesPermission = RegExp(
  r'<uses-permission\s+android:name="([^"]+)"\s*(tools:node="remove")?\s*/>',
);

/// (permission, removed) for every `<uses-permission>` in [path].
List<(String, bool)> _permissions(String path) => [
  for (final m in _usesPermission.allMatches(File(path).readAsStringSync()))
    (m.group(1) ?? '', m.group(2) != null),
];

const _mainManifests = [
  'android/app/src/main/AndroidManifest.xml',
  'android/athan-core/src/main/AndroidManifest.xml',
];

void main() {
  test('REQ-PRIV-001 the app removes every advertising-identifier permission '
      'a dependency could merge in', () {
    final app = _permissions(_mainManifests.first);

    for (final permission in _adPermissions) {
      expect(app, contains((permission, true)), reason: permission);
    }
  });

  test('REQ-PRIV-001 no manifest grants an advertising identifier', () {
    final manifests = Directory('android')
        .listSync(recursive: true)
        .whereType<File>()
        .where((f) => f.path.endsWith('AndroidManifest.xml'))
        .where((f) => !f.path.contains('/build/'))
        .map((f) => f.path)
        .toList();

    expect(manifests, hasLength(greaterThanOrEqualTo(4)));
    for (final path in manifests) {
      for (final (name, removed) in _permissions(path)) {
        if (_adPermissions.contains(name)) {
          expect(removed, isTrue, reason: '$path grants $name');
        }
      }
    }
  });

  test('REQ-PRIV-006 the release permissions are exactly the allow-list', () {
    final granted = {
      for (final path in _mainManifests)
        for (final (name, removed) in _permissions(path))
          if (!removed) name,
    };

    expect(granted, _allowedPermissions);
  });
}
