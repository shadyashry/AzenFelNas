// S16 done-test (migrations): every recorded schema version of both files
// migrates to the current one and matches it; a downgrade or a missing step
// is refused as DB_MIGRATION_FAILED and the file is left untouched.
import 'dart:io';

import 'package:daily_muslim/features/storage/data/database_files.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/forward_only_migration.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:daily_muslim/features/storage/data/static_rules_backup_exclusion.dart';
import 'package:daily_muslim/features/storage/domain/storage_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../drift/dm/generated/schema.dart' as dm_schema;
import '../../drift/places/generated/schema.dart' as places_schema;

void main() {
  late Directory root;

  setUp(() => root = Directory.systemTemp.createTempSync('dm_storage'));
  tearDown(() => root.deleteSync(recursive: true));

  DatabaseFiles files() => DatabaseFiles(
    supportDirectory: () async => root,
    excludeFromBackup: const StaticRulesBackupExclusion(),
    executorFor: NativeDatabase.new,
  );

  group('every recorded schema migrates to the current one', () {
    test('dm.sqlite', () async {
      final verifier = SchemaVerifier(dm_schema.GeneratedHelper());
      for (final from in dm_schema.GeneratedHelper.versions) {
        final db = DmDatabase((await verifier.startAt(from)).executor);
        await verifier.migrateAndValidate(db, db.schemaVersion);
        await db.close();
      }
    });

    test('places.sqlite', () async {
      final verifier = SchemaVerifier(places_schema.GeneratedHelper());
      for (final from in places_schema.GeneratedHelper.versions) {
        final db = PlacesDatabase((await verifier.startAt(from)).executor);
        await verifier.migrateAndValidate(db, db.schemaVersion);
        await db.close();
      }
    });

    test('the newest recorded schema is the current one', () async {
      final dm = DmDatabase(NativeDatabase.memory());
      final places = PlacesDatabase(NativeDatabase.memory());
      expect(dm_schema.GeneratedHelper.versions.last, dm.schemaVersion);
      expect(places_schema.GeneratedHelper.versions.last, places.schemaVersion);
      await dm.close();
      await places.close();
    });
  });

  test(
    'a fresh start creates both files and opens them (REQ-ERR-001)',
    () async {
      final opened = switch (await files()()) {
        Ok(:final value) => value,
        Err(:final failure) => fail('$failure'),
      };
      expect(File('${root.path}/dm.sqlite').existsSync(), isTrue);
      expect(File('${root.path}/places/places.sqlite').existsSync(), isTrue);
      await opened.close();
    },
  );

  test(
    'a dm.sqlite from a newer app is refused as DB_MIGRATION_FAILED and left '
    'untouched (REQ-ERR-001)',
    () async {
      final file = File('${root.path}/dm.sqlite');
      sqlite3.open(file.path)
        ..execute('CREATE TABLE future (x INTEGER)')
        ..execute('PRAGMA user_version = 99')
        ..close();

      final result = await files()();

      expect(
        result,
        const Result<Object, StorageFailure>.err(
          MigrationFailed('dm.sqlite'),
        ),
      );
      expect(
        const MigrationFailed('dm.sqlite').code,
        FailureCode.dbMigrationFailed,
      );
      final raw = sqlite3.open(file.path);
      expect(raw.select('PRAGMA user_version').single.values.single, 99);
      expect(
        raw.select("SELECT name FROM sqlite_master WHERE name = 'future'"),
        hasLength(1),
      );
      raw.close();
    },
  );

  test('a places.sqlite from a newer app is refused (REQ-ERR-001)', () async {
    Directory('${root.path}/places').createSync();
    sqlite3.open('${root.path}/places/places.sqlite')
      ..execute('PRAGMA user_version = 2')
      ..close();

    expect(
      await files()(),
      const Result<Object, StorageFailure>.err(
        MigrationFailed('places.sqlite'),
      ),
    );
  });

  group('ForwardOnlyMigration', () {
    late DmDatabase db;
    setUp(() => db = DmDatabase(NativeDatabase.memory()));
    tearDown(() => db.close());

    test('runs each step once, in version order', () async {
      final ran = <int>[];
      final migration = ForwardOnlyMigration({
        3: (_) async => ran.add(3),
        2: (_) async => ran.add(2),
      });
      await migration.upgrade(db.createMigrator(), 1, 3);
      expect(ran, [2, 3]);
    });

    test('refuses a missing step before running any later one', () async {
      final ran = <int>[];
      final migration = ForwardOnlyMigration({3: (_) async => ran.add(3)});
      await expectLater(
        migration.upgrade(db.createMigrator(), 1, 3),
        throwsA(isA<MigrationRefused>()),
      );
      expect(ran, isEmpty);
    });

    test('refuses a downgrade', () async {
      await expectLater(
        const ForwardOnlyMigration({}).upgrade(db.createMigrator(), 2, 1),
        throwsA(isA<MigrationRefused>()),
      );
    });
  });

  test('foreign keys are enforced on every connection', () async {
    final places = PlacesDatabase(NativeDatabase.memory());
    final row = await places.customSelect('PRAGMA foreign_keys').getSingle();
    expect(row.data.values.single, 1);
    await places.close();
  });
}
