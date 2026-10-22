import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

import '../support/client_harness.dart';

const PackageType _gaz = PackageType.gazetteer;

void main() {
  group('bundled seeds are imported on first launch (REQ-PKG-003)', () {
    test('every bundled type becomes active as source=bundled', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness
        ..bundle(_gaz, '3.0.2', 'gaz-seed')
        ..bundle(PackageType.tzdata, '2026e', 'tz-seed');

      // Act
      final report = await harness.importSeeds(nowUtcMs: harnessNow);

      // Assert
      expect(report.failures, isEmpty);
      final active = await harness.catalog.activeAll();
      expect(active.map((a) => (a.type, a.version, a.source, a.sequence)), [
        (_gaz, '3.0.2', PackageSource.bundled, 0),
        (PackageType.tzdata, '2026e', PackageSource.bundled, 0),
      ]);
      expect(harness.apply.applied[_gaz], 'gaz-seed');
      expect(harness.blobs.files, isEmpty);
    });

    test('a second launch imports nothing again', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.bundle(_gaz, '3.0.2', 'gaz-seed');
      await harness.importSeeds(nowUtcMs: harnessNow);
      harness.apply.applied.clear();

      // Act
      final report = await harness.importSeeds(nowUtcMs: harnessNow + hourMs);

      // Assert
      expect(report.imported, isEmpty);
      expect(harness.apply.applied, isEmpty);
    });

    test('a newer binary replaces an older bundled seed', () async {
      // Arrange
      final harness = await ClientHarness.create();
      final old = harness.bundle(_gaz, '3.0.2', 'gaz-seed');
      await harness.importSeeds(nowUtcMs: harnessNow);
      harness.seeds.payloads.remove(old);
      harness.bundle(_gaz, '3.1.0', 'gaz-seed-2');

      // Act
      final report = await harness.importSeeds(nowUtcMs: harnessNow + hourMs);

      // Assert
      expect(report.imported.single.version, '3.1.0');
      expect((await harness.catalog.active(_gaz))?.previousVersion, '3.0.2');
    });

    test('a seed whose bytes do not match its index is refused', () async {
      // Arrange
      final harness = await ClientHarness.create();
      final seed = harness.bundle(_gaz, '3.0.2', 'gaz-seed');
      harness.seeds.payloads[seed] = utf8.encode('gaz-tampered');

      // Act
      final report = await harness.importSeeds(nowUtcMs: harnessNow);

      // Assert
      expect(report.failures[_gaz]?.code, FailureCode.pkgHashMismatch);
      expect(await harness.catalog.activeAll(), isEmpty);
    });

    test('the active bundled payload loads back from the seed', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.bundle(_gaz, '3.0.2', 'gaz-seed');
      await harness.importSeeds(nowUtcMs: harnessNow);
      final file = (await harness.catalog.files(_gaz)).single;

      // Act
      final payload = await harness.load(file);

      // Assert
      expect(
        payload,
        isA<Ok<List<int>, PackageFailure>>().having(
          (o) => utf8.decode(o.value),
          'payload',
          'gaz-seed',
        ),
      );
    });
  });
}
