import 'package:daily_muslim/features/contexts/data/places_tables.dart';
import 'package:daily_muslim/features/storage/data/forward_only_migration.dart';
import 'package:drift/drift.dart';

part 'places_database.g.dart';

/// `places.sqlite` (§7.3): the location tables, kept in their own file so the
/// file's directory can be excluded from backup (REQ-PRIV-003).
@DriftDatabase(tables: [LocationContexts, ElevationSamples])
final class PlacesDatabase extends _$PlacesDatabase {
  /// The database on [e].
  new(super.e);

  /// The directory under the app support directory; the whole directory is
  /// excluded from backup, so `-wal` and `-shm` files are covered too.
  static const directoryName = 'places';

  /// The file name inside [directoryName].
  static const fileName = 'places.sqlite';

  /// The steps above version 1.
  static const migrations = ForwardOnlyMigration({});

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => migrations.strategy(this);
}
