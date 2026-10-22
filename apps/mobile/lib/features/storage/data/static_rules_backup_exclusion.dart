import 'package:daily_muslim/features/storage/domain/exclude_from_backup.dart';

/// Android: `places/` is excluded by `res/xml/backup_rules.xml`
/// (`fullBackupContent`, API ≤ 30) and `res/xml/data_extraction_rules.xml`
/// (`dataExtractionRules`, API 31+), both referenced by the manifest, so
/// there is nothing to do at run time.
final class StaticRulesBackupExclusion implements ExcludeFromBackup {
  /// The adapter.
  const new();

  @override
  Future<bool> call(String directoryPath) async => true;
}
