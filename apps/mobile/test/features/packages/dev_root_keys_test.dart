import 'dart:io';

import 'package:daily_muslim/features/packages/data/dev_root_keys.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('REQ-DIST-001 the dev and lab binaries embed exactly the dev root '
      'keys gsctl signs with', () {
    // Arrange
    final committed = File(
      '../../tools/gsctl/keys/dev/root-keys.json',
    ).readAsStringSync();

    // Act
    final root = TrustedRoot.fromRootKeysJson(devRootKeysJson);

    // Assert
    expect(devRootKeysJson, committed);
    expect(root.threshold, 2);
    expect(root.publicKeys, hasLength(3));
  });
}
