import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// ADR-014: approximate location only, never background, on both platforms.
void main() {
  test('ADR-014 Android declares coarse location only, no fine or '
      'background location', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();
    expect(manifest, contains('android.permission.ACCESS_COARSE_LOCATION'));
    expect(manifest, isNot(contains('ACCESS_FINE_LOCATION')));
    expect(manifest, isNot(contains('ACCESS_BACKGROUND_LOCATION')));
  });

  test('ADR-014 iOS asks for when-in-use location only', () {
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, contains('NSLocationWhenInUseUsageDescription'));
    expect(
      plist,
      isNot(contains('NSLocationAlwaysAndWhenInUseUsageDescription')),
    );
  });
}
