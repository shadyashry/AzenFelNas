import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The navigation metadata and the local search of an installed package
/// (§15 D106). Works offline; never contacts the network.
abstract interface class ReadMushafIndex {
  /// The 114 surahs in order.
  Future<Result<List<SuraEntry>, QuranFailure>> suras();

  /// The 30 juz in order.
  Future<Result<List<JuzEntry>, QuranFailure>> juz();

  /// Verses whose folded text contains the folded [query], in Mushaf order;
  /// at most [limit] hits. An empty folded query finds nothing.
  Future<Result<SearchResults, QuranFailure>> search(
    String query, {
    required int limit,
  });

  /// Releases the database handles.
  Future<void> close();
}
