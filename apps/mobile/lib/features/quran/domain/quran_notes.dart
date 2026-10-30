import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';

/// Bookmarks of one page layout, stored apart from the downloaded package
/// so removing the package keeps them (§15 D107, REQ-QRN-060).
abstract interface class BookmarkStore {
  /// Bookmarks of [layoutId], newest first; emits on every change.
  Stream<List<Bookmark>> watchBookmarks(String layoutId);

  /// Adds [page] unless it is bookmarked; removes it otherwise. Returns
  /// whether the page is bookmarked afterwards.
  Future<bool> toggleBookmark(
    String layoutId,
    int page, {
    required int nowUtcMs,
  });
}

/// Highlights of one page layout, stored apart from the package.
abstract interface class HighlightStore {
  /// Highlights of [layoutId] in Mushaf order; emits on every change.
  Stream<List<Highlight>> watchHighlights(String layoutId);

  /// Stores a new highlight over [regions] (at least one) and returns its
  /// id.
  Future<int> addHighlight(
    String layoutId,
    HighlightColor color,
    List<HighlightRegion> regions, {
    required int nowUtcMs,
  });

  /// Changes the colour of highlight [id].
  Future<void> recolorHighlight(
    int id,
    HighlightColor color, {
    required int nowUtcMs,
  });

  /// Deletes highlight [id] and its regions.
  Future<void> deleteHighlight(int id);
}

/// The last page read, per layout.
abstract interface class ReadingPositionStore {
  /// The last page of [layoutId], or `null` before the first read.
  Future<int?> readPosition(String layoutId);

  /// Remembers [page].
  Future<void> writePosition(
    String layoutId,
    int page, {
    required int nowUtcMs,
  });
}

/// The reader's saved choices.
abstract interface class ReaderPreferencesStore {
  /// The saved choices (defaults before the first save).
  Future<ReaderPreferences> readPreferences();

  /// Saves [preferences].
  Future<void> writePreferences(ReaderPreferences preferences);
}
