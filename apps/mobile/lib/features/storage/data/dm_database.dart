import 'package:daily_muslim/features/contexts/data/gazetteer_tables.dart';
import 'package:daily_muslim/features/packages/data/package_tables.dart';
import 'package:daily_muslim/features/settings/data/settings_table.dart';
import 'package:daily_muslim/features/storage/data/event_log_table.dart';
import 'package:daily_muslim/features/storage/data/forward_only_migration.dart';
import 'package:drift/drift.dart';

part 'dm_database.g.dart';

/// `dm.sqlite` (§7.3, backed up): packages, gazetteer, settings and the
/// event log. Later slices add their tables here with a new schema version
/// and a [ForwardOnlyMigration] step; `drift_schemas/dm/` keeps every
/// version for the migrations test.
@DriftDatabase(
  tables: [
    ActivePackages,
    PackageFiles,
    PackageTrust,
    Gazetteer,
    GazetteerNames,
    Settings,
    EventLog,
  ],
)
final class DmDatabase extends _$DmDatabase {
  /// The database on [e].
  new(super.e);

  /// The file name under the app support directory.
  static const fileName = 'dm.sqlite';

  /// The steps above version 1.
  static const migrations = ForwardOnlyMigration({});

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => migrations.strategy(this);
}
