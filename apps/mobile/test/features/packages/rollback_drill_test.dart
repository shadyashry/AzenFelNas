// S27 done-test (§13): the package-rollback drill of §19.4 restores the
// prior schedule atomically. A second profile set goes live and changes
// Makkah's plan; both rollback paths bring the first plan back entry for
// entry under a higher generation: the signed CDN rollback (a target with
// `rollbackOf`, re-activated at a higher sequence, REQ-DIST-002) and the
// on-device RollBackAndReplan. A rollback that cannot be planned changes
// neither the pointer nor the armed plan (REQ-PKG-001).
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/features/athan/application/plan_schedule.dart';
import 'package:daily_muslim/features/athan/application/plan_subject.dart';
import 'package:daily_muslim/features/athan/data/arb_plan_texts.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/packages/application/importing_apply_package.dart';
import 'package:daily_muslim/features/packages/application/roll_back_and_replan.dart';
import 'package:daily_muslim/features/packages/data/asset_bundled_seeds.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/io_gzip_inflate.dart';
import 'package:daily_muslim/features/packages/data/io_package_blob_store.dart';
import 'package:daily_muslim/features/packages/data/package_payload_checks.dart';
import 'package:daily_muslim/features/schedule/application/load_runtime_data.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';

import '../../support/runtime_fixtures.dart';
import '../athan/plan_fixtures.dart';
import '../athan/support/fake_plan_host.dart';

/// 2026-11-10T12:00:00Z: inside the seed's country profiles' effective
/// range (from 2026-11-01).
const int _now = 1794312000000;

const String _seedVersion = '2026.10.1';
const String _nextVersion = '2026.10.2';
const String _profilesPath =
    'assets/packages/prayer_profiles/$_seedVersion/profiles.json';

final class _Events implements RecordPackageEvent {
  final List<PackageEvent> events = [];

  @override
  Future<void> record(PackageEvent event) async => events.add(event);
}

/// The seed set without its `SA` profile, so Makkah falls back to
/// `engine.default`: a different schedule built only from the seed's own
/// draft data (§0.2 rule 1).
List<int> _setWithoutSaudi() {
  final set =
      jsonDecode(File(_profilesPath).readAsStringSync()) as List<Object?>;
  return utf8.encode(
    jsonEncode([
      for (final profile in set)
        if (profile is Map<String, Object?> &&
            profile['profileId'] != 'sa.ummalqura.standard')
          profile,
    ]),
  );
}

T _ok<T>(Result<T, Failure> result) => switch (result) {
  Ok(:final value) => value,
  Err(:final failure) => throw StateError('$failure'),
};

void main() {
  late DmDatabase db;
  late Directory blobs;
  late DriftPackageCatalog catalog;
  late IoPackageBlobStore store;
  late _Events events;
  late ActivateStaged activate;
  late LoadRuntimeData runtime;
  late PlanSchedule plan;
  late FakePlanHost host;
  var generation = 0;

  PlanSubject subject() => PlanSubject(
    context: manualContext(
      latitudeDeg: 21.4225,
      longitudeDeg: 39.8262,
      zoneId: 'Asia/Riyadh',
      country: 'SA',
      label: 'Makkah',
    ),
    preferences: allEvents,
    target: const AndroidPlanTarget(),
    generation: ++generation,
  );

  Future<SchedulePlan> armFromActive() async {
    final built = _ok((await runtime()).flatMap((d) => plan(d, subject())));
    expect(await host(built), isTrue);
    return built;
  }

  Future<PackageFile> stage(String version, List<int> payload) async {
    final dmpkg = gzip.encode(payload);
    final sha = sha256.convert(dmpkg).toString();
    final file = PackageFile(
      type: PackageType.prayerProfiles,
      version: version,
      path: PackageFile.downloadedPath(
        PackageType.prayerProfiles,
        version,
        sha,
      ),
      sha256: sha,
      source: PackageSource.downloaded,
      state: PackageFileState.staged,
      updatedUtcMs: _now,
    );
    _ok(await store.write(file.path, dmpkg));
    _ok(await catalog.record(file));
    return file;
  }

  Future<void> goLive(PackageFile file, List<int> payload, int sequence) async {
    _ok(
      await activate(
        StagedPackage(file: file, payload: payload),
        sequence: sequence,
        nowUtcMs: _now,
      ),
    );
  }

  RollBackAndReplan rollBackAndReplan() => RollBackAndReplan(
    read: catalog,
    runtime: runtime,
    plan: plan,
    rollBack: RollBackPackage(
      read: catalog,
      write: catalog,
      load: _loader(store),
      apply: _apply(db),
      events: events,
    ),
    apply: host,
  );

  setUp(() async {
    db = DmDatabase(NativeDatabase.memory());
    blobs = Directory.systemTemp.createTempSync('dm_drill');
    catalog = DriftPackageCatalog(db);
    store = IoPackageBlobStore(blobs);
    events = _Events();
    host = FakePlanHost();
    generation = 0;
    activate = ActivateStaged(
      read: catalog,
      write: catalog,
      apply: _apply(db),
      events: events,
    );
    runtime = LoadRuntimeData(
      catalog: catalog,
      load: _loader(store),
      channel: ReleaseChannel.dev,
    );
    plan = PlanSchedule(FixedClock(_now), ArbPlanTexts());
    final report = await ImportBundledSeeds(
      seeds: _seeds(),
      catalog: catalog,
      app: AppBuild.compat,
      checkPayload: const PackagePayloadChecks(),
      activate: activate,
    )(nowUtcMs: _now);
    expect(report.failures, isEmpty);
  });

  tearDown(() async {
    await db.close();
    blobs.deleteSync(recursive: true);
  });

  test('REQ-DIST-002 a signed rollback (higher sequence, rollbackOf) '
      're-arms the prior schedule entry for entry', () async {
    final before = await armFromActive();
    final next = _setWithoutSaudi();
    await goLive(await stage(_nextVersion, next), next, 1);
    final bad = await armFromActive();
    expect(bad.entries, isNot(before.entries), reason: 'drill needs a change');

    // Act: release-package with rollback_of re-publishes the seed payload
    // as a new version under a higher sequence (package-rollback.md).
    final seed = File(_profilesPath).readAsBytesSync();
    await goLive(await stage('2026.10.3', seed), seed, 2);
    final restored = await armFromActive();

    // Assert
    expect(restored.entries, before.entries);
    expect(restored.generation, greaterThan(bad.generation));
    expect(host.stored, restored);
    expect((await catalog.active(PackageType.prayerProfiles))?.sequence, 2);
  });

  test('REQ-PKG-001 the on-device rollback flips the pointer and re-arms '
      'the prior schedule in one step', () async {
    final before = await armFromActive();
    final next = _setWithoutSaudi();
    await goLive(await stage(_nextVersion, next), next, 1);
    final bad = await armFromActive();

    // Act
    final result = await rollBackAndReplan()(
      PackageType.prayerProfiles,
      subject(),
      nowUtcMs: _now + 1000,
    );

    // Assert
    final restored = _ok(result);
    expect(restored.entries, before.entries);
    expect(restored.generation, greaterThan(bad.generation));
    expect(host.stored, restored);
    expect(
      (await catalog.active(PackageType.prayerProfiles))?.version,
      _seedVersion,
    );
    expect(events.events.whereType<PackageRolledBack>(), hasLength(1));
  });

  test('REQ-PKG-001 a previous version that cannot be loaded leaves the '
      'pointer and the armed plan unchanged', () async {
    // Arrange: the downloaded previous file is corrupted on disk.
    final first = _setWithoutSaudi();
    final firstFile = await stage(_nextVersion, first);
    await goLive(firstFile, first, 1);
    final seed = File(_profilesPath).readAsBytesSync();
    await goLive(await stage('2026.10.3', seed), seed, 2);
    final armed = await armFromActive();
    _ok(await store.write(firstFile.path, const [1, 2, 3]));
    final offered = host.offered.length;

    // Act
    final result = await rollBackAndReplan()(
      PackageType.prayerProfiles,
      subject(),
      nowUtcMs: _now + 1000,
    );

    // Assert
    expect(
      result,
      isA<Err<SchedulePlan, Failure>>().having(
        (e) => e.failure.code,
        'code',
        FailureCode.pkgHashMismatch,
      ),
    );
    expect(
      (await catalog.active(PackageType.prayerProfiles))?.version,
      '2026.10.3',
    );
    expect(host.offered, hasLength(offered));
    expect(host.stored, armed);
  });

  test('REQ-ALM-035 a refused plan keeps the host plan whole and the next '
      'start re-plans from the restored pointer', () async {
    final before = await armFromActive();
    final next = _setWithoutSaudi();
    await goLive(await stage(_nextVersion, next), next, 1);
    final bad = await armFromActive();
    host.accepts = false;

    final result = await rollBackAndReplan()(
      PackageType.prayerProfiles,
      subject(),
      nowUtcMs: _now + 1000,
    );

    expect(
      result,
      isA<Err<SchedulePlan, Failure>>().having(
        (e) => e.failure.code,
        'code',
        FailureCode.planWriteFailed,
      ),
    );
    expect(host.stored, bad);
    host.accepts = true;
    expect((await armFromActive()).entries, before.entries);
  });
}

AssetBundledSeeds _seeds() =>
    AssetBundledSeeds((key) => File(key).readAsBytes());

LoadPackagePayload _loader(IoPackageBlobStore store) => LoadPackagePayload(
  blobs: store,
  inflate: const IoGzipInflate(),
  seeds: _seeds(),
);

ImportingApplyPackage _apply(DmDatabase db) => ImportingApplyPackage(
  ImportGazetteer(const JsonGazetteerPayloadDecoder(), DriftGazetteerStore(db)),
);
