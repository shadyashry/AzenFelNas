import 'dart:io';

import 'package:daily_muslim/app/di.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/features/storage/data/drift_event_log.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late OpenedDatabases dbs;
  late Directory blobs;

  setUp(() {
    dbs = memoryDatabases();
    blobs = Directory.systemTemp.createTempSync('dm_blobs');
  });
  tearDown(() async {
    await dbs.close();
    blobs.deleteSync(recursive: true);
  });

  ProviderContainer container() => ProviderContainer(
    overrides: AppBindings.of(
      databases: dbs,
      assets: rootBundle,
      clock: FixedClock(harnessNowUtcMs),
      blobRoot: blobs,
    ),
  );

  test(
    'the first start logs APP_START and imports the bundled seeds offline '
    '(REQ-PKG-003)',
    () async {
      final c = container();
      final report = await c.read(appStartProvider.future);
      c.dispose();

      expect(report.seeds.failures, isEmpty);
      expect(
        report.seeds.imported.map((p) => p.type),
        [PackageType.gazetteer],
      );
      expect(report.garbage, const Result<int, PackageFailure>.ok(0));
      final events = await DriftEventLog(dbs.dm).entries();
      expect(events.first.code, EventCode.appStart);
      expect(events.map((e) => e.code), contains(EventCode.pkgActivated));
    },
  );

  test('a later start imports nothing again', () async {
    final first = container();
    await first.read(appStartProvider.future);
    first.dispose();
    final second = container();
    final report = await second.read(appStartProvider.future);
    second.dispose();
    expect(report.seeds.imported, isEmpty);
  });
}
