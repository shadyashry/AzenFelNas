import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/quran_notes.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:drift/drift.dart';

/// The Quran notes ports over `quran_notes.sqlite` (§15 D107): one adapter,
/// four narrow ports, so each use case sees only what it calls.
final class DriftQuranNotes
    implements
        BookmarkStore,
        HighlightStore,
        ReadingPositionStore,
        ReaderPreferencesStore {
  /// The adapter over [_db].
  const new(this._db);

  final QuranNotesDatabase _db;

  @override
  Stream<List<Bookmark>> watchBookmarks(String layoutId) =>
      (_db.select(_db.quranBookmarks)
            ..where((t) => t.layoutId.equals(layoutId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdUtc)]))
          .watch()
          .map(
            (rows) => [
              for (final row in rows)
                Bookmark(
                  layoutId: row.layoutId,
                  page: row.page,
                  createdUtcMs: row.createdUtc,
                ),
            ],
          );

  @override
  Future<bool> toggleBookmark(
    String layoutId,
    int page, {
    required int nowUtcMs,
  }) => _db.transaction(() async {
    final removed =
        await (_db.delete(_db.quranBookmarks)..where(
              (t) => t.layoutId.equals(layoutId) & t.page.equals(page),
            ))
            .go();
    if (removed > 0) return false;
    await _db
        .into(_db.quranBookmarks)
        .insert(
          QuranBookmarksCompanion.insert(
            layoutId: layoutId,
            page: page,
            createdUtc: nowUtcMs,
          ),
        );
    return true;
  });

  @override
  Stream<List<Highlight>> watchHighlights(String layoutId) {
    final query =
        _db.select(_db.quranHighlights).join([
            innerJoin(
              _db.quranHighlightRegions,
              _db.quranHighlightRegions.highlightId.equalsExp(
                _db.quranHighlights.id,
              ),
            ),
          ])
          ..where(_db.quranHighlights.layoutId.equals(layoutId))
          ..orderBy([
            OrderingTerm.asc(_db.quranHighlights.firstPage),
            OrderingTerm.asc(_db.quranHighlights.id),
            OrderingTerm.asc(_db.quranHighlightRegions.page),
            OrderingTerm.asc(_db.quranHighlightRegions.id),
          ]);
    return query.watch().map((rows) {
      final byId = <int, (QuranHighlightRow, List<HighlightRegion>)>{};
      for (final row in rows) {
        final h = row.readTable(_db.quranHighlights);
        final r = row.readTable(_db.quranHighlightRegions);
        byId
            .putIfAbsent(h.id, () => (h, <HighlightRegion>[]))
            .$2
            .add(
              HighlightRegion(
                page: r.page,
                left: r.x0,
                top: r.y0,
                right: r.x1,
                bottom: r.y1,
              ),
            );
      }
      return [
        for (final (h, regions) in byId.values)
          Highlight(
            id: h.id,
            layoutId: h.layoutId,
            color: _color(h.color),
            regions: List.unmodifiable(regions),
            createdUtcMs: h.createdUtc,
            updatedUtcMs: h.updatedUtc,
          ),
      ];
    });
  }

  @override
  Future<int> addHighlight(
    String layoutId,
    HighlightColor color,
    List<HighlightRegion> regions, {
    required int nowUtcMs,
  }) {
    if (regions.isEmpty) throw ArgumentError.value(regions, 'regions');
    final sorted = [...regions]..sort((a, b) => a.page.compareTo(b.page));
    return _db.transaction(() async {
      final id = await _db
          .into(_db.quranHighlights)
          .insert(
            QuranHighlightsCompanion.insert(
              layoutId: layoutId,
              color: color.name,
              firstPage: sorted.first.page,
              createdUtc: nowUtcMs,
              updatedUtc: nowUtcMs,
            ),
          );
      await _db.batch((batch) {
        batch.insertAll(_db.quranHighlightRegions, [
          for (final r in sorted)
            QuranHighlightRegionsCompanion.insert(
              highlightId: id,
              page: r.page,
              x0: r.left,
              y0: r.top,
              x1: r.right,
              y1: r.bottom,
            ),
        ]);
      });
      return id;
    });
  }

  @override
  Future<void> recolorHighlight(
    int id,
    HighlightColor color, {
    required int nowUtcMs,
  }) async {
    await (_db.update(
      _db.quranHighlights,
    )..where((t) => t.id.equals(id))).write(
      QuranHighlightsCompanion(
        color: Value(color.name),
        updatedUtc: Value(nowUtcMs),
      ),
    );
  }

  @override
  Future<void> deleteHighlight(int id) async {
    await (_db.delete(
      _db.quranHighlights,
    )..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<int?> readPosition(String layoutId) async {
    final row = await (_db.select(
      _db.quranReadingPositions,
    )..where((t) => t.layoutId.equals(layoutId))).getSingleOrNull();
    return row?.page;
  }

  @override
  Future<void> writePosition(
    String layoutId,
    int page, {
    required int nowUtcMs,
  }) => _db
      .into(_db.quranReadingPositions)
      .insertOnConflictUpdate(
        QuranReadingPositionsCompanion.insert(
          layoutId: layoutId,
          page: page,
          updatedUtc: nowUtcMs,
        ),
      );

  @override
  Future<ReaderPreferences> readPreferences() async {
    final row = await (_db.select(
      _db.quranReaderPrefs,
    )..where((t) => t.id.equals(1))).getSingleOrNull();
    if (row == null) return const ReaderPreferences();
    return ReaderPreferences(
      fit: PageFit.values.firstWhere(
        (f) => f.name == row.fit,
        orElse: () => PageFit.page,
      ),
      facingPages: row.facingPages,
    );
  }

  @override
  Future<void> writePreferences(ReaderPreferences preferences) => _db
      .into(_db.quranReaderPrefs)
      .insertOnConflictUpdate(
        QuranReaderPrefsCompanion.insert(
          id: const Value(1),
          fit: preferences.fit.name,
          facingPages: preferences.facingPages,
        ),
      );

  static HighlightColor _color(String name) => HighlightColor.values.firstWhere(
    (c) => c.name == name,
    orElse: () => HighlightColor.yellow,
  );
}
