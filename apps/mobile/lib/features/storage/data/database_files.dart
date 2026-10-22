import 'dart:io';

import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:daily_muslim/features/storage/domain/exclude_from_backup.dart';
import 'package:daily_muslim/features/storage/domain/storage_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/drift.dart';

/// Opens `dm.sqlite` and `places/places.sqlite` under the app support
/// directory (§7.3), excluding `places/` from backup first (REQ-PRIV-003).
///
/// Both files are opened eagerly so a migration failure surfaces here as
/// `DB_MIGRATION_FAILED` instead of at the first query (REQ-ERR-001).
final class DatabaseFiles {
  /// The opener for files under [supportDirectory], built with [executorFor].
  const new({
    required this.supportDirectory,
    required this.excludeFromBackup,
    required this.executorFor,
  });

  /// The app support directory (`filesDir` on Android).
  final Future<Directory> Function() supportDirectory;

  /// The platform's backup exclusion.
  final ExcludeFromBackup excludeFromBackup;

  /// The SQLite executor for a file.
  final QueryExecutor Function(File file) executorFor;

  /// Opens both files.
  Future<Result<OpenedDatabases, StorageFailure>> call() async {
    final root = await supportDirectory();
    final placesDir = Directory(
      '${root.path}/${PlacesDatabase.directoryName}',
    );
    await placesDir.create(recursive: true);
    final excluded = await excludeFromBackup(placesDir.path);
    final dm = DmDatabase(
      executorFor(File('${root.path}/${DmDatabase.fileName}')),
    );
    final places = PlacesDatabase(
      executorFor(File('${placesDir.path}/${PlacesDatabase.fileName}')),
    );
    final failure =
        await _migrate(dm, DmDatabase.fileName) ??
        await _migrate(places, PlacesDatabase.fileName);
    if (failure != null) {
      await dm.close();
      await places.close();
      return Result.err(failure);
    }
    return Result.ok(
      OpenedDatabases(
        dm: dm,
        places: places,
        placesExcludedFromBackup: excluded,
      ),
    );
  }

  static Future<StorageFailure?> _migrate(
    GeneratedDatabase db,
    String file,
  ) async {
    try {
      await db.customSelect('SELECT 1').get();
      return null;
    } on Exception {
      // MigrationRefused, or SQLite refusing the file.
      return MigrationFailed(file);
    }
  }
}
