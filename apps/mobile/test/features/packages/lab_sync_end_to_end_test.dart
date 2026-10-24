// S25 done-test, app half: the app's own sync wiring (AppBindings.syncPackages
// over HttpCdnChannel, drift, the blob store and the payload checks) syncs a
// lab channel that gsctl built, signed, published to an S3 bucket and pulled
// back on a fresh runner, served by `gsctl serve` in front of that bucket
// (§15 D85). tools/gsctl/scripts/lab-e2e.sh sets the variables and runs this
// file; without them it skips. The Go half (pull, sequences, promote) is
// tools/gsctl/internal/app/pull_promote_test.go.
import 'dart:io';

import 'package:daily_muslim/app/di.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/http_cdn_channel.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/drift_event_log.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final env = Platform.environment;
  final port = int.tryParse(env['DM_E2E_CDN_PORT'] ?? '');
  final rootKeys = env['DM_E2E_ROOT_KEYS'];
  final version = env['DM_E2E_EXPECT_VERSION'];
  final skip = port == null || rootKeys == null || version == null
      ? 'run by tools/gsctl/scripts/lab-e2e.sh'
      : null;

  late DmDatabase db;
  late Directory blobs;
  setUp(() {
    db = DmDatabase(NativeDatabase.memory());
    blobs = Directory.systemTemp.createTempSync('dm-e2e-blobs');
  });
  tearDown(() async {
    await db.close();
    blobs.deleteSync(recursive: true);
  });

  test(
    'REQ-PKG-001 REQ-PKG-004 REQ-PKG-005 the app syncs the lab channel end '
    'to end and activates its newest profiles package',
    () async {
      // Arrange
      final (cdnPort, rootKeysFile, expected) = switch ((
        port,
        rootKeys,
        version,
      )) {
        (final p?, final r?, final v?) => (p, r, v),
        _ => throw StateError('the test is skipped without its variables'),
      };
      final client = HttpClient();
      addTearDown(client.close);
      final sync = AppBindings.syncPackages(
        db: db,
        eventLog: DriftEventLog(db),
        blobRoot: blobs,
        fetch: HttpCdnChannel.loopback(cdnPort, 'lab', client),
        embeddedRoot: TrustedRoot.fromRootKeysJson(
          File(rootKeysFile).readAsStringSync(),
        ),
      );
      final now = DateTime.now().toUtc().millisecondsSinceEpoch;
      const sixHoursMs = 6 * 3600 * 1000;

      // Act
      final first = await sync(nowUtcMs: now);
      final soon = await sync(nowUtcMs: now + 1000);
      final later = await sync(nowUtcMs: now + sixHoursMs + 1000);

      // Assert
      expect(first.outcome, SyncOutcome.completed, reason: '$first');
      expect(first.targetFailures, isEmpty);
      expect(
        first.activated,
        contains(
          isA<ActivePackage>()
              .having((a) => a.type, 'type', PackageType.prayerProfiles)
              .having((a) => a.version, 'version', expected),
        ),
      );
      expect(soon.outcome, SyncOutcome.skippedInterval);
      expect(later.outcome, SyncOutcome.upToDate, reason: '$later');
      expect(later.activated, isEmpty);
      final active = await DriftPackageCatalog(
        db,
      ).active(PackageType.prayerProfiles);
      expect(active?.version, expected);
    },
    skip: skip,
  );
}
