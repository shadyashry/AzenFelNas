import 'dart:io';
import 'dart:isolate';

import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/features/athan/application/plan_schedule.dart';
import 'package:daily_muslim/features/athan/application/reconcile_schedule_plan.dart';
import 'package:daily_muslim/features/athan/application/record_athan_test_result.dart';
import 'package:daily_muslim/features/athan/data/arb_plan_texts.dart';
import 'package:daily_muslim/features/athan/data/asset_athan_sounds.dart';
import 'package:daily_muslim/features/athan/data/event_log_last_test.dart';
import 'package:daily_muslim/features/athan/data/pigeon_arm_athan_test.dart';
import 'package:daily_muslim/features/athan/data/pigeon_drain_native_events.dart';
import 'package:daily_muslim/features/athan/data/pigeon_platform_health.dart';
import 'package:daily_muslim/features/athan/data/pigeon_write_schedule_plan.dart';
import 'package:daily_muslim/features/athan/data/pigeon_write_widget_snapshot.dart';
import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/presentation/athan_plan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/widget_snapshot_providers.dart';
import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/contexts/application/follow_device_location.dart';
import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/locate_observer.dart';
import 'package:daily_muslim/features/contexts/application/locate_with_permission.dart';
import 'package:daily_muslim/features/contexts/application/name_nearest_place.dart';
import 'package:daily_muslim/features/contexts/application/name_stored_place.dart';
import 'package:daily_muslim/features/contexts/application/name_zone.dart';
import 'package:daily_muslim/features/contexts/application/pin_place.dart';
import 'package:daily_muslim/features/contexts/application/resolve_observer_context.dart';
import 'package:daily_muslim/features/contexts/application/resolve_place.dart';
import 'package:daily_muslim/features/contexts/application/search_gazetteer.dart';
import 'package:daily_muslim/features/contexts/application/suggest_places.dart';
import 'package:daily_muslim/features/contexts/data/channel_device_zone.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/drift_location_context_store.dart';
import 'package:daily_muslim/features/contexts/data/event_log_context_events.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/contexts/domain/device_zone.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:daily_muslim/features/onboarding/application/complete_first_run.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/packages/application/importing_apply_package.dart';
import 'package:daily_muslim/features/packages/data/asset_bundled_seeds.dart';
import 'package:daily_muslim/features/packages/data/assume_metered_network.dart';
import 'package:daily_muslim/features/packages/data/background_hash_payload.dart';
import 'package:daily_muslim/features/packages/data/dev_root_keys.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/drift_package_trust_store.dart';
import 'package:daily_muslim/features/packages/data/event_log_package_events.dart';
import 'package:daily_muslim/features/packages/data/http_cdn_channel.dart';
import 'package:daily_muslim/features/packages/data/io_gzip_inflate.dart';
import 'package:daily_muslim/features/packages/data/io_package_blob_store.dart';
import 'package:daily_muslim/features/packages/data/package_payload_checks.dart';
import 'package:daily_muslim/features/packages/domain/run_payload_work.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';
import 'package:daily_muslim/features/qibla/presentation/qibla_providers.dart';
import 'package:daily_muslim/features/quran/data/channel_free_space.dart';
import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/http_quran_origin.dart';
import 'package:daily_muslim/features/quran/data/io_quran_package_disk.dart';
import 'package:daily_muslim/features/quran/data/quran_manifest_codec.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/data/sqlite_mushaf_index.dart';
import 'package:daily_muslim/features/quran/data/sqlite_search_index.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/application/load_runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/application/assemble_diagnostic_bundle.dart';
import 'package:daily_muslim/features/settings/application/export_diagnostic_bundle.dart';
import 'package:daily_muslim/features/settings/data/asset_attributions.dart';
import 'package:daily_muslim/features/settings/data/clipboard_diagnostic_text.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/presentation/diagnostics_providers.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/application/start_app.dart';
import 'package:daily_muslim/features/shell/data/event_log_app_events.dart';
import 'package:daily_muslim/features/shell/domain/open_system_settings.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/drift_event_log.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:daily_muslim/features/travel/application/handle_zone_change.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

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
    required HeadingSource heading,
    required AthanSchedulerApi athan,
    required RequestAthanGrant athanGrant,
    required OpenSystemSettings systemSettings,
    ReadDeviceZone deviceZone = const ChannelDeviceZone(),
    RunPayloadWork runPayloadWork = Isolate.run,
    QuranNotesDatabase? quranNotes,
    ReadFreeSpace freeSpace = const ChannelFreeSpace(),
  }) {
    final settings = DriftSettingsStore(databases.dm);
    final eventLog = DriftEventLog(databases.dm);
    final drainNativeEvents = PigeonDrainNativeEvents(athan, eventLog.call);
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
        checkPayload: PackagePayloadChecks(run: runPayloadWork),
        activate: _activate(databases.dm, eventLog, runPayloadWork),
        hash: BackgroundHashPayload(run: runPayloadWork),
      ),
      collectGarbage: CollectPackageGarbage(
        read: catalog,
        write: catalog,
        blobs: blobs,
      ),
      recordStart: EventLogAppEvents(eventLog.call),
      drainNativeEvents: drainNativeEvents,
      clock: clock,
    );
    return [
      ..._quran(
        root: Directory('${blobRoot.parent.path}/quran'),
        notes: DriftQuranNotes(
          quranNotes ?? QuranNotesDatabase(NativeDatabase.memory()),
        ),
        freeSpace: freeSpace,
      ),
      watchSettingProvider.overrideWithValue(settings),
      writeSettingProvider.overrideWithValue(settings),
      readAttributionsProvider.overrideWithValue(
        AssetAttributions(assets.loadString),
      ),
      startAppProvider.overrideWithValue(startApp),
      openSystemSettingsProvider.overrideWithValue(systemSettings),
      syncPackagesProvider.overrideWithValue(switch (_embeddedRoot()) {
        final root? => syncPackages(
          db: databases.dm,
          eventLog: eventLog,
          blobRoot: blobRoot,
          fetch: HttpCdnChannel.cdn(AppBuild.channel.name),
          embeddedRoot: root,
          runPayloadWork: runPayloadWork,
        ),
        null => null,
      }),
      clockProvider.overrideWithValue(clock),
      loadRuntimeDataProvider.overrideWithValue(
        LoadRuntimeData(
          catalog: catalog,
          load: LoadPackagePayload(
            blobs: blobs,
            inflate: const IoGzipInflate(),
            seeds: bundledSeeds,
            hash: BackgroundHashPayload(run: runPayloadWork),
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
          deviceZone: deviceZone,
        ),
      ),
      completeFirstRunProvider.overrideWithValue(CompleteFirstRun(settings)),
      headingSourceProvider.overrideWithValue(heading),
      readPlatformHealthProvider.overrideWithValue(
        PigeonPlatformHealth(athan, clock),
      ),
      armAthanTestProvider.overrideWithValue(PigeonArmAthanTest(athan)),
      requestAthanGrantProvider.overrideWithValue(athanGrant),
      writeWidgetSnapshotProvider.overrideWithValue(
        PigeonWriteWidgetSnapshot(athan),
      ),
      drainNativeEventsProvider.overrideWithValue(drainNativeEvents),
      recordAthanTestResultProvider.overrideWithValue(
        RecordAthanTestResult(eventLog.call),
      ),
      readLastTestHeardProvider.overrideWithValue(
        EventLogLastTest(eventLog.entries),
      ),
      readAthanSoundsProvider.overrideWithValue(
        AssetAthanSounds(
          assets,
          // The CC0 test Athan is offered on dev and lab only (§15 D94).
          includeTestSounds: switch (AppBuild.channel) {
            ReleaseChannel.dev || ReleaseChannel.lab => true,
            ReleaseChannel.beta || ReleaseChannel.production => false,
          },
        ),
      ),
      planScheduleProvider.overrideWithValue(
        PlanSchedule(clock, ArbPlanTexts()),
      ),
      applySchedulePlanProvider.overrideWithValue(
        ReconcileSchedulePlan(PigeonWriteSchedulePlan(athan)),
      ),
      assembleDiagnosticBundleProvider.overrideWithValue(
        AssembleDiagnosticBundle(
          events: eventLog.entries,
          platformHealth: PigeonPlatformHealth(athan, clock),
          lastTestHeard: EventLogLastTest(eventLog.entries),
          contexts: DriftLocationContextStore(databases.places),
          activePackages: catalog.activeAll,
          clock: clock,
          os: DiagnosticOs.values.byName(Platform.operatingSystem),
          appVersion: AppBuild.version,
        ),
      ),
      exportDiagnosticBundleProvider.overrideWithValue(
        const ExportDiagnosticBundle(ClipboardDiagnosticText()),
      ),
    ];
  }

  /// The offline Quran (§15 D106): the package under [root] (persistent
  /// app support storage, never a cache), the CDN for the download only,
  /// and the notes, which live apart from the package.
  static List<Override> _quran({
    required Directory root,
    required DriftQuranNotes notes,
    required ReadFreeSpace freeSpace,
  }) => [
    quranPackageDiskProvider.overrideWithValue(
      IoQuranPackageDisk(
        root,
        pinnedManifestSha256: QuranEditionPin.manifestSha256,
      ),
    ),
    quranOriginProvider.overrideWithValue(_quranOrigin()),
    acceptManifestProvider.overrideWithValue(QuranManifestCodec.acceptPinned),
    readFreeSpaceProvider.overrideWithValue(freeSpace),
    buildSearchIndexProvider.overrideWithValue(const SqliteSearchIndex()),
    searchIndexIsCurrentProvider.overrideWithValue(SqliteSearchIndex.isCurrent),
    openMushafIndexProvider.overrideWithValue(SqliteMushafIndex.new),
    bookmarkStoreProvider.overrideWithValue(notes),
    highlightStoreProvider.overrideWithValue(notes),
    readingPositionStoreProvider.overrideWithValue(notes),
    readerPreferencesStoreProvider.overrideWithValue(notes),
  ];

  /// The CDN of this build's channel. A dev build may name a loopback port
  /// (`--dart-define DM_QURAN_LOOPBACK_PORT=8787`, with `adb reverse`) to
  /// test the download against a local copy of the package.
  static QuranOrigin _quranOrigin() {
    const port = int.fromEnvironment('DM_QURAN_LOOPBACK_PORT');
    return switch (AppBuild.channel) {
      ReleaseChannel.dev when port > 0 => HttpQuranOrigin.loopback(
        port,
        AppBuild.channel.name,
        QuranEditionPin.cdnPath,
      ),
      _ => HttpQuranOrigin.cdn(AppBuild.channel.name, QuranEditionPin.cdnPath),
    };
  }

  /// The package sync of §7.4 against [fetch]: the CDN in the app, a
  /// loopback stand-in in the lab end-to-end test (§15 D85).
  static SyncPackages syncPackages({
    required DmDatabase db,
    required DriftEventLog eventLog,
    required Directory blobRoot,
    required FetchChannel fetch,
    required TrustedRoot embeddedRoot,
    RunPayloadWork runPayloadWork = Isolate.run,
  }) {
    final catalog = DriftPackageCatalog(db);
    return SyncPackages(
      network: const AssumeMeteredNetwork(),
      trust: DriftPackageTrustStore(db),
      fetch: fetch,
      verify: const VerifyMetadataChain(CryptographyEd25519()),
      embeddedRoot: embeddedRoot,
      catalog: catalog,
      stage: StageTarget(
        compatibility: CheckCompatibility(AppBuild.compat),
        fetch: fetch,
        inflate: const IoGzipInflate(),
        checkPayload: PackagePayloadChecks(run: runPayloadWork),
        blobs: IoPackageBlobStore(blobRoot),
        catalog: catalog,
      ),
      activate: _activate(db, eventLog, runPayloadWork),
      events: EventLogPackageEvents(eventLog.call),
    );
  }

  /// The root keys this channel's binary embeds; none for beta and
  /// production until the S27 ceremony keys exist.
  static TrustedRoot? _embeddedRoot() => switch (AppBuild.channel) {
    ReleaseChannel.dev ||
    ReleaseChannel.lab => TrustedRoot.fromRootKeysJson(devRootKeysJson),
    ReleaseChannel.beta || ReleaseChannel.production => null,
  };

  static ActivateStaged _activate(
    DmDatabase db,
    DriftEventLog eventLog,
    RunPayloadWork run,
  ) {
    final catalog = DriftPackageCatalog(db);
    return ActivateStaged(
      read: catalog,
      write: catalog,
      apply: ImportingApplyPackage(
        ImportGazetteer(
          JsonGazetteerPayloadDecoder(run: run),
          DriftGazetteerStore(db),
        ),
      ),
      events: EventLogPackageEvents(eventLog.call),
    );
  }

  static ContextUseCases _contextUseCases({
    required RuntimeData data,
    required OpenedDatabases databases,
    required Clock clock,
    required LocateDevice locator,
    required RequestLocationAccess locationAccess,
    required DriftEventLog eventLog,
    required ReadDeviceZone deviceZone,
  }) {
    final contexts = DriftLocationContextStore(databases.places);
    final gazetteer = DriftGazetteerStore(databases.dm);
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
      search: SearchGazetteer(gazetteer),
      travel: HandleZoneChange(contexts, locator, resolvePlace, clock),
      follow: FollowDeviceLocation(locate),
      suggest: SuggestPlaces(deviceZone, gazetteer),
      nameNearest: NameNearestPlace(gazetteer),
      nameZone: NameZone(gazetteer),
      nameStored: NameStoredPlace(gazetteer),
    );
  }
}
