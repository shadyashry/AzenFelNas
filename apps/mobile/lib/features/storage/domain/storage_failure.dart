import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why a database file could not be opened (§10.2).
sealed class StorageFailure implements Failure {
  const new();
}

/// The file needs a downgrade or a missing step, or its migration threw
/// (§7.3: forward only). The file is left untouched.
@immutable
final class MigrationFailed extends StorageFailure {
  /// The failure for the file named [file].
  const new(this.file);

  /// `dm.sqlite` or `places.sqlite`; never a full path.
  final String file;

  @override
  FailureCode get code => FailureCode.dbMigrationFailed;

  @override
  bool operator ==(Object other) =>
      other is MigrationFailed && other.file == file;

  @override
  int get hashCode => Object.hash(MigrationFailed, file);
}
