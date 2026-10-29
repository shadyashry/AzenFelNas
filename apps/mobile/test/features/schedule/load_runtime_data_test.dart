import 'dart:io';

import 'package:daily_muslim/app/di.dart';
import 'package:daily_muslim/features/packages/data/asset_bundled_seeds.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/io_gzip_inflate.dart';
import 'package:daily_muslim/features/packages/data/io_package_blob_store.dart';
import 'package:daily_muslim/features/packages/domain/run_payload_work.dart';
import 'package:daily_muslim/features/schedule/application/load_runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

import '../../support/app_harness.dart';
import '../../support/fake_athan_grant.dart';
import '../../support/fake_location_access.dart';
import '../contexts/support/fake_device_locator.dart';
import '../qibla/support/fake_heading_source.dart';

String _code(Result<RuntimeData, Failure> result) => switch (result) {
  Ok() => 'ok',
  Err(:final failure) => failure.code.wire,
};

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

  LoadRuntimeData load(ReleaseChannel channel) => LoadRuntimeData(
    catalog: DriftPackageCatalog(dbs.dm),
    load: LoadPackagePayload(
      blobs: IoPackageBlobStore(blobs),
      inflate: const IoGzipInflate(),
      seeds: AssetBundledSeeds((key) => File(key).readAsBytes()),
    ),
    channel: channel,
  );

  Future<void> importSeeds() async {
    final container = ProviderContainer(
      overrides: AppBindings.of(
        databases: dbs,
        assets: rootBundle,
        clock: FixedClock(harnessNowUtcMs),
        blobRoot: blobs,
        locator: FakeDeviceLocator(),
        locationAccess: FakeLocationAccess(),
        heading: FakeHeadingSource(),
        athan: noAthanHost(),
        athanGrant: FakeAthanGrant(),
        runPayloadWork: runPayloadWorkInPlace,
      ),
    );
    await container.read(appStartProvider.future);
    container.dispose();
  }

  test('REQ-PKG-003 after the first start the bundled tzdata, polygons and '
      'profiles load offline on dev', () async {
    await importSeeds();
    final result = await load(ReleaseChannel.dev)();
    expect(_code(result), 'ok');
    expect(switch (result) {
      Ok(:final value) => value.tzdb.version,
      Err() => null,
    }, '2026e');
  });

  test('REQ-PKG-003 draft seed profiles never load on production '
      '(PROFILE_INVALID, Appendix E)', () async {
    await importSeeds();
    expect(_code(await load(ReleaseChannel.production)()), 'PROFILE_INVALID');
    expect(_code(await load(ReleaseChannel.beta)()), 'PROFILE_INVALID');
  });

  test(
    'REQ-ERR-001 no active package is PKG_STORAGE, not an exception',
    () async {
      expect(_code(await load(ReleaseChannel.dev)()), 'PKG_STORAGE');
    },
  );
}
