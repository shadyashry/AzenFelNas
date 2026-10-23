import 'dart:io';

import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/application/locate_with_permission.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/drift_location_context_store.dart';
import 'package:daily_muslim/features/contexts/data/event_log_context_events.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/packages/application/importing_apply_package.dart';
import 'package:daily_muslim/features/packages/data/asset_bundled_seeds.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/event_log_package_events.dart';
import 'package:daily_muslim/features/packages/data/io_gzip_inflate.dart';
import 'package:daily_muslim/features/packages/data/io_package_blob_store.dart';
import 'package:daily_muslim/features/packages/data/package_payload_checks.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/application/load_runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/data/asset_attributions.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/application/start_app.dart';
import 'package:daily_muslim/features/shell/data/event_log_app_events.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/features/storage/data/drift_event_log.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
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
    required LocateDevice locator,
    required RequestLocationAccess locationAccess,
  }) {
    final settings = DriftSettingsStore(databases.dm);
    final eventLog = DriftEventLog(databases.dm);
    final catalog = DriftPackageCatalog(databases.dm);
    final blobs = IoPackageBlobStore(blobRoot);
    final bundledSeeds = AssetBundledSeeds(
      (key) async => (await assets.load(key)).buffer.asUint8List(),
    );
    final startApp = StartApp(
      importSeeds: ImportBundledSeeds(
        seeds: bundledSeeds,
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
        blobs: blobs,
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
      clockProvider.overrideWithValue(clock),
      loadRuntimeDataProvider.overrideWithValue(
        LoadRuntimeData(
          catalog: catalog,
          load: LoadPackagePayload(
            blobs: blobs,
            inflate: const IoGzipInflate(),
            seeds: bundledSeeds,
          ),
          channel: AppBuild.channel,
        ),
      ),
      calculateScheduleProvider.overrideWithValue(CalculateSchedule(clock)),
      contextUseCasesFactoryProvider.overrideWithValue(
        (data) => _contextUseCases(
          data: data,
          databases: databases,
          clock: clock,
          locator: locator,
          locationAccess: locationAccess,
          eventLog: eventLog,
        ),
      ),
      completeFirstRunProvider.overrideWithValue(CompleteFirstRun(settings)),
    ];
  }

  static ContextUseCases _contextUseCases({
    required RuntimeData data,
    required OpenedDatabases databases,
    required Clock clock,
    required LocateDevice locator,
    required RequestLocationAccess locationAccess,
    required DriftEventLog eventLog,
  }) {
    final contexts = DriftLocationContextStore(databases.places);
    final resolvePlace = ResolvePlace(
      ResolveZone(data.zones),
      ResolveCountry(data.countries),
    );
    final locate = LocateObserver(
      clock: clock,
      locator: locator,
      read: contexts,
      write: contexts,
      resolvePlace: resolvePlace,
      events: EventLogContextEvents(eventLog.call),
    );
    return ContextUseCases(
      locate: LocateWithPermission(locationAccess, locate),
      resolve: ResolveObserverContext(contexts, locate, resolvePlace),
      pin: PinPlace(
        clock: clock,
        read: contexts,
        write: contexts,
        resolvePlace: resolvePlace,
      ),
      search: SearchGazetteer(DriftGazetteerStore(databases.dm)),
    );
  }
}
