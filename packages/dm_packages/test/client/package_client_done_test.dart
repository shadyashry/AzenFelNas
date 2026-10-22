// The S14 done-test (§13 S14): the package client end to end over a
// channel signed with ephemeral keys — tamper, downgrade, expiry-warning
// and rollback. Fakes only at the ports (§17.7).
import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

import '../support/client_harness.dart';

const PackageType _gaz = PackageType.gazetteer;

/// A harness with gazetteer 1.0.0 (`gaz-v1`) installed from sequence 1.
Future<ClientHarness> _installedV1() async {
  final harness = await ClientHarness.create();
  harness.channel.publish(_gaz, '1.0.0', utf8.encode('gaz-v1'));
  await harness.fetch.publish(sequence: 1);
  final report = await harness.syncAt(0);
  expect(report.outcome, SyncOutcome.completed, reason: '$report');
  return harness;
}

/// A harness with 2.0.0 (`gaz-v2`) installed over 1.0.0 from sequence 2.
Future<ClientHarness> _installedV2() async {
  final harness = await _installedV1();
  harness.channel.publish(_gaz, '2.0.0', utf8.encode('gaz-v2'));
  await harness.fetch.publish(sequence: 2);
  final report = await harness.syncAt(7);
  expect(report.activated.single.version, '2.0.0', reason: '$report');
  return harness;
}

Matcher _failedWith(FailureCode code) => isA<SyncReport>()
    .having((r) => r.outcome, 'outcome', SyncOutcome.failed)
    .having((r) => r.failure?.code, 'failure', code);

void main() {
  group('install: download → verify → stage → activate (REQ-PKG-001)', () {
    test('a signed target becomes active with its payload applied', () async {
      // Arrange
      final harness = await _installedV1();

      // Act
      final active = await harness.catalog.active(_gaz);

      // Assert
      expect(active?.version, '1.0.0');
      expect(active?.source, PackageSource.downloaded);
      expect(active?.sequence, 1);
      expect(harness.apply.applied[_gaz], 'gaz-v1');
      expect(harness.trust.state.sequences.targets, 1);
      expect(harness.events.events.whereType<PackageActivated>(), hasLength(1));
      expect(
        harness.events.events.whereType<SyncFinished>().single.outcome,
        'completed',
      );
    });
  });

  group('tamper leaves the last-known-good active (REQ-PKG-001, '
      'REQ-DIST-003, REQ-DIST-004)', () {
    test('a package with one flipped byte is refused', () async {
      // Arrange
      final harness = await _installedV1();
      harness.channel.publish(_gaz, '2.0.0', utf8.encode('gaz-v2'));
      await harness.fetch.publish(sequence: 2);
      final bytes = [...?harness.fetch.packages['gazetteer/2.0.0']];
      bytes[bytes.length ~/ 2] ^= 0x01;
      harness.fetch.packages['gazetteer/2.0.0'] = bytes;

      // Act
      final report = await harness.syncAt(7);

      // Assert
      expect(
        report.targetFailures['gazetteer/2.0.0']?.code,
        FailureCode.pkgHashMismatch,
      );
      expect(await harness.activeVersion(_gaz), '1.0.0');
      expect(harness.apply.applied[_gaz], 'gaz-v1');
    });

    test('targets.json changed after signing is refused', () async {
      // Arrange
      final harness = await _installedV1();
      harness.channel.publish(_gaz, '2.0.0', utf8.encode('gaz-v2'));
      await harness.fetch.publish(sequence: 2);
      final served = harness.fetch.served;
      served[MetadataRole.targets] = utf8.encode(
        utf8
            .decode(served[MetadataRole.targets] ?? const [])
            .replaceFirst('"Update"', '"Updatf"'),
      );

      // Act
      final report = await harness.syncAt(7);

      // Assert
      expect(report, _failedWith(FailureCode.pkgSigInvalid));
      expect(await harness.activeVersion(_gaz), '1.0.0');
      expect(harness.trust.state.sequences.targets, 1);
    });

    test('a stored package changed on disk is not loaded', () async {
      // Arrange
      final harness = await _installedV1();
      final file = (await harness.catalog.files(_gaz)).single;
      harness.blobs.files[file.path] = [...?harness.blobs.files[file.path], 0];

      // Act
      final loaded = await harness.load(file);

      // Assert
      expect(
        loaded,
        isA<Err<List<int>, PackageFailure>>().having(
          (e) => e.failure.code,
          'code',
          FailureCode.pkgHashMismatch,
        ),
      );
    });

    test('a payload the type schema refuses is not activated', () async {
      // Arrange
      final harness = await _installedV1();
      harness.channel.publish(_gaz, '2.0.0', utf8.encode('INVALID payload'));
      await harness.fetch.publish(sequence: 2);

      // Act
      final report = await harness.syncAt(7);

      // Assert
      expect(
        report.targetFailures['gazetteer/2.0.0']?.code,
        FailureCode.pkgIncompatible,
      );
      expect(await harness.activeVersion(_gaz), '1.0.0');
    });
  });

  group('downgrade is refused (REQ-PKG-005, REQ-DIST-002)', () {
    test('replayed older metadata is a sequence regression', () async {
      // Arrange
      final harness = await _installedV1();
      final old = harness.fetch.served;
      harness.channel.publish(_gaz, '2.0.0', utf8.encode('gaz-v2'));
      await harness.fetch.publish(sequence: 2);
      await harness.syncAt(7);
      harness.fetch.served = old;

      // Act
      final report = await harness.syncAt(14);

      // Assert
      expect(report, _failedWith(FailureCode.pkgSequenceRegression));
      expect(await harness.activeVersion(_gaz), '2.0.0');
      expect(harness.trust.state.sequences.targets, 2);
    });

    test('the pointer never moves to a lower targets sequence', () async {
      // Arrange
      final harness = await _installedV2();
      final staged = StagedPackage(
        file: const PackageFile(
          type: _gaz,
          version: '0.9.0',
          path: 'gazetteer/0.9.0/x.dmpkg',
          sha256: 'x',
          source: PackageSource.downloaded,
          state: PackageFileState.staged,
          updatedUtcMs: harnessNow,
        ),
        payload: utf8.encode('gaz-old'),
      );

      // Act
      final result = await harness.activate(
        staged,
        sequence: 1,
        nowUtcMs: harnessNow + 20 * hourMs,
      );

      // Assert
      expect(
        result,
        isA<Err<ActivePackage, PackageFailure>>().having(
          (e) => e.failure.code,
          'code',
          FailureCode.pkgSequenceRegression,
        ),
      );
      expect(await harness.activeVersion(_gaz), '2.0.0');
      expect(harness.apply.applied[_gaz], 'gaz-v2');
    });

    test('a bundled seed never replaces a downloaded version '
        '(REQ-PKG-003)', () async {
      // Arrange
      final harness = await _installedV1();
      harness.bundle(_gaz, '0.5.0', 'gaz-seed');

      // Act
      final report = await harness.importSeeds(nowUtcMs: harnessNow + hourMs);

      // Assert
      expect(report.imported, isEmpty);
      expect(await harness.activeVersion(_gaz), '1.0.0');
    });
  });

  group('expired metadata only warns (REQ-PKG-002)', () {
    test('an expired channel still installs and reports '
        'FRESHNESS_UNVERIFIED', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.channel.publish(_gaz, '1.0.0', utf8.encode('gaz-v1'));
      await harness.fetch.publish(
        sequence: 1,
        expires: '2026-10-01T00:00:00Z',
      );

      // Act
      final report = await harness.syncAt(0);

      // Assert
      expect(report.outcome, SyncOutcome.completed);
      expect(report.activated.single.version, '1.0.0');
      expect(report.warnings, hasLength(4));
      expect(
        report.warnings.map((w) => FreshnessWarning.code).toSet(),
        {FailureCode.pkgExpiredWarning},
      );
      expect(
        harness.events.events.whereType<FreshnessUnverified>().single,
        isA<FreshnessUnverified>().having((e) => e.expiredRoles, 'roles', 4),
      );
      expect(harness.trust.state.lastVerifiedUtcMs, isNull);
    });
  });

  group('rollback (REQ-PKG-001, REQ-DIST-002)', () {
    test(
      'a local rollback restores and re-applies the previous version',
      () async {
        // Arrange
        final harness = await _installedV2();

        // Act
        final result = await harness.rollBack(
          _gaz,
          nowUtcMs: harnessNow + 8 * hourMs,
        );

        // Assert
        expect(result, isA<Ok<ActivePackage, PackageFailure>>());
        final active = await harness.catalog.active(_gaz);
        expect(active?.version, '1.0.0');
        expect(active?.sequence, 2);
        expect(harness.apply.applied[_gaz], 'gaz-v1');
        expect(
          harness.events.events.whereType<PackageRolledBack>().single,
          isA<PackageRolledBack>()
              .having((e) => e.fromVersion, 'from', '2.0.0')
              .having((e) => e.toVersion, 'to', '1.0.0'),
        );
      },
    );

    test(
      'a rolled-back version is not chosen again by the next sync',
      () async {
        // Arrange
        final harness = await _installedV2();
        await harness.rollBack(_gaz, nowUtcMs: harnessNow + 8 * hourMs);
        await harness.fetch.publish(sequence: 3);

        // Act
        final report = await harness.syncAt(20);

        // Assert
        expect(report.activated, isEmpty);
        expect(report.targetFailures, isEmpty);
        expect(await harness.activeVersion(_gaz), '1.0.0');
        expect(harness.apply.applied[_gaz], 'gaz-v1');
      },
    );

    test(
      'a signed rollback target supersedes the version it rolls back',
      () async {
        // Arrange
        final harness = await _installedV2();
        harness.channel.publish(
          _gaz,
          '2.0.1',
          utf8.encode('gaz-v1'),
          rollbackOf: '2.0.0',
          effectiveFrom: '2026-10-22',
        );
        await harness.fetch.publish(sequence: 3);

        // Act
        final report = await harness.syncAt(14);

        // Assert
        expect(report.activated.single.version, '2.0.1');
        expect(harness.apply.applied[_gaz], 'gaz-v1');
        expect((await harness.catalog.active(_gaz))?.previousVersion, '2.0.0');
      },
    );

    test('a failed apply step keeps the previous version active', () async {
      // Arrange
      final harness = await _installedV1();
      harness.apply.failing.add('2.0.0');
      harness.channel.publish(_gaz, '2.0.0', utf8.encode('gaz-v2'));
      await harness.fetch.publish(sequence: 2);

      // Act
      final report = await harness.syncAt(7);

      // Assert
      expect(
        report.targetFailures['gazetteer/2.0.0']?.code,
        FailureCode.pkgStorage,
      );
      expect(await harness.activeVersion(_gaz), '1.0.0');
      final refused = (await harness.catalog.files(_gaz))
          .where((f) => f.version == '2.0.0')
          .single;
      expect(refused.state, PackageFileState.garbage);
    });

    test('rollback without a previous version changes nothing', () async {
      // Arrange
      final harness = await _installedV1();

      // Act
      final result = await harness.rollBack(
        _gaz,
        nowUtcMs: harnessNow + hourMs,
      );

      // Assert
      expect(
        result,
        isA<Err<ActivePackage, PackageFailure>>().having(
          (e) => e.failure.code,
          'code',
          FailureCode.pkgStorage,
        ),
      );
      expect(await harness.activeVersion(_gaz), '1.0.0');
    });
  });
}
