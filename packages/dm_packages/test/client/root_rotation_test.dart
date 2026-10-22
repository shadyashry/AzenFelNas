import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

import '../support/client_harness.dart';

const PackageType _gaz = PackageType.gazetteer;

/// A harness that synced sequence 1, then a rotated root at sequence 2.
Future<ClientHarness> _rotated() async {
  final harness = await ClientHarness.create();
  harness.channel.publish(_gaz, '1.0.0', utf8.encode('gaz-v1'));
  await harness.fetch.publish(sequence: 1);
  await harness.syncAt(0);
  await harness.channel.rotateRoot();
  await harness.fetch.publish(sequence: 2);
  final report = await harness.syncAt(6);
  expect(report.outcome, isNot(SyncOutcome.failed), reason: '$report');
  return harness;
}

void main() {
  group('root rotation by the old root threshold (Appendix C, '
      'REQ-DIST-001)', () {
    test('a rotated root becomes the anchor for later metadata', () async {
      // Arrange
      final harness = await _rotated();
      harness.channel
        ..retireOldRootKeys()
        ..publish(_gaz, '2.0.0', utf8.encode('gaz-v2'));
      await harness.fetch.publish(sequence: 3);

      // Act
      final report = await harness.syncAt(12);

      // Assert
      expect(report.activated.single.version, '2.0.0');
    });

    test('a root signed only by unknown keys is refused', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.channel.publish(_gaz, '1.0.0', utf8.encode('gaz-v1'));
      await harness.channel.rotateRoot();
      harness.channel.retireOldRootKeys();
      await harness.fetch.publish(sequence: 1);

      // Act
      final report = await harness.syncAt(0);

      // Assert
      expect(report.failure?.code, FailureCode.pkgSigInvalid);
      expect(await harness.catalog.activeAll(), isEmpty);
      expect(harness.trust.state.rootJson, isNull);
    });

    test(
      'a root with a lower version than the trusted one is refused',
      () async {
        // Arrange
        final harness = await _rotated();
        harness.channel
          ..retireOldRootKeys()
          ..rootVersion = 1;
        await harness.fetch.publish(sequence: 3);

        // Act
        final report = await harness.syncAt(12);

        // Assert
        expect(
          report.failure,
          isA<PackageSequenceRegression>().having(
            (f) => f.role,
            'role',
            MetadataRole.root,
          ),
        );
      },
    );
  });
}
