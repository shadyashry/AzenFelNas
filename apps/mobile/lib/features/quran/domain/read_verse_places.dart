import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Where verses stand in the installed package (§15 D114). Works offline
/// and reads only the package's own `verse` table.
abstract interface class ReadVersePlaces {
  /// The verses that touch [page], in Mushaf order.
  Future<Result<List<VersePlace>, QuranFailure>> versesOnPage(int page);

  /// Verse [aya] of surah [sura]; `null` when the package has no such
  /// verse.
  Future<Result<VersePlace?, QuranFailure>> verse(int sura, int aya);

  /// Releases the database handles.
  Future<void> close();
}
