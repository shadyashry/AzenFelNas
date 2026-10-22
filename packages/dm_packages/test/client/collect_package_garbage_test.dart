import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

import '../support/client_harness.dart';

const PackageType _gaz = PackageType.gazetteer;

void main() {
  group('package garbage is deleted after 7 days (§7.3, REQ-PKG-001)', () {
    test(
      'a rolled-back file is kept 7 days, then its blob and row go',
      () async {
        // Arrange
        final harness = await ClientHarness.create();
        for (final (sequence, version) in [(1, '1.0.0'), (2, '2.0.0')]) {
          harness.channel.publish(_gaz, version, utf8.encode('gaz-$version'));
          await harness.fetch.publish(sequence: sequence);
          await harness.syncAt(7 * (sequence - 1));
        }
        await harness.rollBack(_gaz, nowUtcMs: harnessNow + 8 * hourMs);
        final collect = CollectPackageGarbage(
          read: harness.catalog,
          write: harness.catalog,
          blobs: harness.blobs,
        );

        // Act
        final early = await collect(nowUtcMs: harnessNow + 6 * 24 * hourMs);
        final due = await collect(nowUtcMs: harnessNow + 8 * 24 * hourMs);

        // Assert
        expect(early, const Ok<int, PackageFailure>(0));
        expect(due, const Ok<int, PackageFailure>(1));
        final files = await harness.catalog.files(_gaz);
        expect(files.map((f) => (f.version, f.state)), [
          ('1.0.0', PackageFileState.active),
        ]);
        expect(harness.blobs.files.keys, [files.single.path]);
      },
    );
  });
}
