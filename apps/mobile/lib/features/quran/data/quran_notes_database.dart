import 'package:daily_muslim/features/quran/data/quran_notes_tables.dart';
import 'package:daily_muslim/features/storage/data/forward_only_migration.dart';
import 'package:drift/drift.dart';

part 'quran_notes_database.g.dart';

/// `quran_notes.sqlite` (§7.3, §15 D107): bookmarks, highlights, the last
/// page read and the reader's choices. Kept apart from the downloaded
/// package, so removing or replacing the package never touches it; rows are
/// keyed by page layout, so another edition never shows them in the wrong
/// place.
@DriftDatabase(
  tables: [
    QuranBookmarks,
    QuranHighlights,
    QuranHighlightRegions,
    QuranReadingPositions,
    QuranReaderPrefs,
  ],
)
final class QuranNotesDatabase extends _$QuranNotesDatabase {
  /// The database on [e].
  new(super.e);

  /// The file name under the app support directory.
  static const fileName = 'quran_notes.sqlite';

  /// The steps above version 1.
  static const migrations = ForwardOnlyMigration({});

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => migrations.strategy(this);
}
