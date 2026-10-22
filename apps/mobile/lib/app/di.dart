import 'dart:io';

import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/packages/application/importing_apply_package.dart';
import 'package:daily_muslim/features/packages/data/asset_bundled_seeds.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/event_log_package_events.dart';
import 'package:daily_muslim/features/packages/data/io_package_blob_store.dart';
import 'package:daily_muslim/features/packages/data/package_payload_checks.dart';
import 'package:daily_muslim/features/settings/data/asset_attributions.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/application/start_app.dart';
import 'package:daily_muslim/features/shell/data/event_log_app_events.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/features/storage/data/drift_event_log.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';

/// The composition root (§7.1, §17.1 D): the only place adapters meet use
/// cases. Tests pass their own assets, clock and in-memory databases.
abstract final class AppBindings {
  /// The provider overrides for one app process.
  static List<Override> of({
    required OpenedDatabases databases,
    required AssetBundle assets,
    required Clock clock,
    required Directory blobRoot,
  }) {
    final settings = DriftSettingsStore(databases.dm);
    final eventLog = DriftEventLog(databases.dm);
    final catalog = DriftPackageCatalog(databases.dm);
    final startApp = StartApp(
      importSeeds: ImportBundledSeeds(
        seeds: AssetBundledSeeds(
          (key) async => (await assets.load(key)).buffer.asUint8List(),
        ),
        catalog: catalog,
        app: AppBuild.compat,
        checkPayload: const PackagePayloadChecks(),
        activate: ActivateStaged(
          read: catalog,
          write: catalog,
          apply: ImportingApplyPackage(
            ImportGazetteer(
              const JsonGazetteerPayloadDecoder(),
              DriftGazetteerStore(databases.dm),
            ),
          ),
          events: EventLogPackageEvents(eventLog.call),
        ),
      ),
      collectGarbage: CollectPackageGarbage(
        read: catalog,
        write: catalog,
        blobs: IoPackageBlobStore(blobRoot),
      ),
      recordStart: EventLogAppEvents(eventLog.call),
      clock: clock,
    );
    return [
      watchSettingProvider.overrideWithValue(settings),
      writeSettingProvider.overrideWithValue(settings),
      readAttributionsProvider.overrideWithValue(
        AssetAttributions(assets.loadString),
      ),
      startAppProvider.overrideWithValue(startApp),
    ];
  }
}
