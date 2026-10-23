// S14 done-test, app half: the real bundled gazetteer seed is imported on
// first launch through the drift catalog, the type's payload check and
// ImportGazetteer, exactly once (REQ-PKG-003); a payload that does not
// decode never becomes active (REQ-PKG-001). The package half (tamper,
// downgrade, expiry warning, rollback) is
// packages/dm_packages/test/client/package_client_done_test.dart.
import 'dart:io';

import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/features/contexts/application/import_gazetteer.dart';
import 'package:daily_muslim/features/contexts/data/drift_gazetteer_store.dart';
import 'package:daily_muslim/features/contexts/data/json_gazetteer_payload_decoder.dart';
import 'package:daily_muslim/features/packages/application/importing_apply_package.dart';
import 'package:daily_muslim/features/packages/data/asset_bundled_seeds.dart';
import 'package:daily_muslim/features/packages/data/drift_package_catalog.dart';
import 'package:daily_muslim/features/packages/data/package_payload_checks.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// 2026-10-22T12:00:00Z.
const int _now = 1792670400000;

final class _Events implements RecordPackageEvent {
  final List<PackageEvent> events = [];

  @override
  Future<void> record(PackageEvent event) async => events.add(event);
}

void main() {
  late DmDatabase db;
  late DriftPackageCatalog catalog;
  late _Events events;
  late ImportBundledSeeds importSeeds;

  setUp(() {
    db = DmDatabase(NativeDatabase.memory());
    catalog = DriftPackageCatalog(db);
    events = _Events();
    importSeeds = ImportBundledSeeds(
      seeds: AssetBundledSeeds((key) => File(key).readAsBytes()),
      catalog: catalog,
      app: AppBuild.compat,
      checkPayload: const PackagePayloadChecks(),
      activate: ActivateStaged(
        read: catalog,
        write: catalog,
        apply: ImportingApplyPackage(
          ImportGazetteer(
            const JsonGazetteerPayloadDecoder(),
            DriftGazetteerStore(db),
          ),
        ),
        events: events,
      ),
    );
  });
  tearDown(() async {
    await db.close();
  });

  Future<int> places() async =>
      (await db.customSelect('SELECT COUNT(*) AS n FROM gazetteer').getSingle())
          .read<int>('n');

  test('REQ-PKG-003 the bundled gazetteer seed is imported on first launch '
      'and never again', () async {
    // Act
    final first = await importSeeds(nowUtcMs: _now);
    final second = await importSeeds(nowUtcMs: _now + 1000);

    // Assert
    expect(first.failures, isEmpty);
    expect(
      first.imported.singleWhere((a) => a.type == PackageType.gazetteer),
      isA<ActivePackage>()
          .having((a) => a.type, 'type', PackageType.gazetteer)
          .having((a) => a.version, 'version', '3.0.2')
          .having((a) => a.source, 'source', PackageSource.bundled)
          .having((a) => a.sequence, 'sequence', 0),
    );
    expect(second.imported, isEmpty);
    expect(await places(), 34006);
    expect(
      events.events.whereType<PackageActivated>(),
      hasLength(first.imported.length),
    );
  });

  test('REQ-PKG-001 a gazetteer payload that does not decode is refused '
      'by the payload check', () {
    final result = const PackagePayloadChecks()(
      PackageType.gazetteer,
      '3.0.3',
      1,
      '{"schemaVersion": 1}'.codeUnits,
    );

    expect(
      result,
      isA<Err<void, PackageFailure>>().having(
        (e) => e.failure.code,
        'code',
        FailureCode.pkgIncompatible,
      ),
    );
  });

  test('REQ-PKG-006 types without a reader in this build are refused', () {
    for (final type in [
      PackageType.hijri,
      PackageType.athanAudioManifest,
    ]) {
      expect(
        const PackagePayloadChecks()(type, '1.0.0', 1, const [1]),
        isA<Err<void, PackageFailure>>(),
      );
    }
    expect(
      const PackagePayloadChecks()(PackageType.tzdata, '2026e', 1, const [1]),
      isA<Err<void, PackageFailure>>(),
    );
  });

  test('REQ-PKG-006 a prayer_profiles payload must parse as a valid profile '
      'set (§15 D60)', () {
    const checks = PackagePayloadChecks();
    expect(
      checks(PackageType.prayerProfiles, '2026.10.1', 1, const [1]),
      isA<Err<void, PackageFailure>>(),
    );
    final bundled = File(
      'assets/packages/prayer_profiles/2026.10.1/profiles.json',
    ).readAsBytesSync();
    expect(
      checks(PackageType.prayerProfiles, '2026.10.1', 1, bundled),
      const Result<void, PackageFailure>.ok(null),
    );
  });
}
