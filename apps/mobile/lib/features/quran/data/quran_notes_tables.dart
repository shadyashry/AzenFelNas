import 'package:drift/drift.dart';

/// Bookmarked pages per page layout (`quran_notes.sqlite`, §15 D107).
@DataClassName('QuranBookmarkRow')
class QuranBookmarks extends Table {
  /// The page layout (`QuranPackageManifest.layoutId`).
  TextColumn get layoutId => text()();

  /// Page number.
  IntColumn get page => integer()();

  /// Created (UTC epoch ms).
  IntColumn get createdUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {layoutId, page};
}

/// Highlights per page layout; their areas are in [QuranHighlightRegions].
@DataClassName('QuranHighlightRow')
class QuranHighlights extends Table {
  /// Row id.
  IntColumn get id => integer().autoIncrement()();

  /// The page layout.
  TextColumn get layoutId => text()();

  /// `HighlightColor.name`.
  TextColumn get color => text()();

  /// First page covered, for ordering.
  IntColumn get firstPage => integer()();

  /// Created (UTC epoch ms).
  IntColumn get createdUtc => integer()();

  /// Last edited (UTC epoch ms).
  IntColumn get updatedUtc => integer()();
}

/// One page-relative area of a highlight (0..1 of the page image).
@DataClassName('QuranHighlightRegionRow')
class QuranHighlightRegions extends Table {
  /// Row id.
  IntColumn get id => integer().autoIncrement()();

  /// The highlight.
  IntColumn get highlightId => integer().references(
    QuranHighlights,
    #id,
    onDelete: KeyAction.cascade,
  )();

  /// Page number.
  IntColumn get page => integer()();

  /// Left edge.
  RealColumn get x0 => real()();

  /// Top edge.
  RealColumn get y0 => real()();

  /// Right edge.
  RealColumn get x1 => real()();

  /// Bottom edge.
  RealColumn get y1 => real()();
}

/// The last page read per page layout.
@DataClassName('QuranReadingPositionRow')
class QuranReadingPositions extends Table {
  /// The page layout.
  TextColumn get layoutId => text()();

  /// Page number.
  IntColumn get page => integer()();

  /// Saved (UTC epoch ms).
  IntColumn get updatedUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {layoutId};
}

/// The reader's choices: one row with id 1.
@DataClassName('QuranReaderPrefsRow')
class QuranReaderPrefs extends Table {
  /// Always 1.
  IntColumn get id => integer()();

  /// `PageFit.name`.
  TextColumn get fit => text()();

  /// Two facing pages on wide windows.
  BoolColumn get facingPages => boolean()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Whole-verse highlights per page layout (§15 D113, schema version 2): one
/// per verse.
@DataClassName('QuranAyahHighlightRow')
class QuranAyahHighlights extends Table {
  /// The page layout.
  TextColumn get layoutId => text()();

  /// Surah.
  IntColumn get sura => integer()();

  /// Verse.
  IntColumn get aya => integer()();

  /// `HighlightColor.name`.
  TextColumn get color => text()();

  /// Created (UTC epoch ms).
  IntColumn get createdUtc => integer()();

  /// Last changed (UTC epoch ms).
  IntColumn get updatedUtc => integer()();

  @override
  Set<Column<Object>> get primaryKey => {layoutId, sura, aya};
}
