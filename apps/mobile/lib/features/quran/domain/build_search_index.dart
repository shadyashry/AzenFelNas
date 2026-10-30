import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The search index's file name inside a package directory.
const searchIndexFileName = 'search.sqlite';

/// Builds the local search index of the package in `directory` from its
/// `quran.sqlite`, then runs a query to confirm it answers (§15 D106).
abstract interface class BuildSearchIndex {
  /// Builds the index; [QuranSearchUnavailable] when it fails or does not
  /// answer.
  Future<Result<void, QuranFailure>> call(String directory);
}

/// Free bytes on the volume of a directory.
abstract interface class ReadFreeSpace {
  /// Free bytes for [directory], or `null` when the platform cannot tell.
  Future<int?> call(String directory);
}
