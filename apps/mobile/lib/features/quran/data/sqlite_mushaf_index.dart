import 'package:daily_muslim/features/quran/data/sqlite_search_index.dart';
import 'package:daily_muslim/features/quran/domain/arabic_search_text.dart';
import 'package:daily_muslim/features/quran/domain/hizb_quarter.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/read_mushaf_index.dart';
import 'package:daily_muslim/features/quran/domain/read_verse_places.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:sqlite3/sqlite3.dart';

/// [ReadMushafIndex] and [ReadVersePlaces] over the package's
/// `quran.sqlite` with the local `search.sqlite` attached, both read-only
/// (§15 D107, D114). Queries are small and indexed, so they run on the
/// calling isolate.
final class SqliteMushafIndex implements ReadMushafIndex, ReadVersePlaces {
  /// The index of the package in [directory].
  new(this.directory);

  /// The package directory.
  final String directory;

  Database? _db;

  Result<Database, QuranFailure> _open() {
    final open = _db;
    if (open != null) return Result.ok(open);
    try {
      final db =
          sqlite3.open(
            '$directory/quran.sqlite',
            mode: OpenMode.readOnly,
          )..execute('ATTACH DATABASE ? AS s', [
            '$directory/${SqliteSearchIndex.fileName}',
          ]);
      _db = db;
      return Result.ok(db);
    } on SqliteException {
      return const Result.err(QuranSearchUnavailable());
    }
  }

  Result<T, QuranFailure> _query<T>(T Function(Database db) body) {
    switch (_open()) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final db):
        try {
          return Result.ok(body(db));
        } on SqliteException {
          return const Result.err(QuranSearchUnavailable());
        } on FormatException {
          return const Result.err(QuranSearchUnavailable());
        }
    }
  }

  @override
  Future<Result<List<SuraEntry>, QuranFailure>> suras() async => _query(
    (db) => [
      for (final row in db.select(
        'SELECT number, header, start_page, verse_count FROM sura '
        'ORDER BY number',
      ))
        SuraEntry(
          number: _int(row['number']),
          header: _string(row['header']),
          startPage: _int(row['start_page']),
          verseCount: _int(row['verse_count']),
        ),
    ],
  );

  @override
  Future<Result<List<JuzEntry>, QuranFailure>> juz() async => _query(
    (db) => [
      for (final row in db.select(
        'SELECT number, sura, aya, page FROM juz ORDER BY number',
      ))
        JuzEntry(
          number: _int(row['number']),
          sura: _int(row['sura']),
          aya: _int(row['aya']),
          page: _int(row['page']),
        ),
    ],
  );

  @override
  Future<Result<List<HizbQuarter>, QuranFailure>> quarters() async => _query(
    (db) {
      final table = db.select(
        "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = 'quarter'",
      );
      if (table.isEmpty) return const <HizbQuarter>[];
      return [
        for (final row in db.select(
          'SELECT number, sura, aya, page FROM quarter ORDER BY number',
        ))
          HizbQuarter(
            number: _int(row['number']),
            sura: _int(row['sura']),
            aya: _int(row['aya']),
            page: _int(row['page']),
          ),
      ];
    },
  );

  @override
  Future<Result<SearchResults, QuranFailure>> search(
    String query, {
    required int limit,
  }) async {
    final folded = ArabicSearchText.query(query);
    if (folded.isEmpty) {
      return const Result.ok(SearchResults(hits: [], total: 0));
    }
    final pattern = '%$folded%';
    return _query((db) {
      final total = _int(
        db.select(
          'SELECT count(*) AS n FROM s.verse_fts WHERE norm LIKE ?',
          [pattern],
        ).first['n'],
      );
      final rows = db.select(
        'SELECT v.sura, v.aya, v.page, v.text FROM s.verse_fts f '
        'JOIN verse v ON v.id = f.rowid WHERE f.norm LIKE ? '
        'ORDER BY v.id LIMIT ?',
        [pattern, limit],
      );
      return SearchResults(
        total: total,
        hits: [for (final row in rows) _hit(row, folded)],
      );
    });
  }

  static const _placeColumns =
      'sura, aya, page, line_start, page_end, line_end, text';

  @override
  Future<Result<List<VersePlace>, QuranFailure>> versesOnPage(
    int page,
  ) async => _query(
    (db) => [
      for (final row in db.select(
        'SELECT $_placeColumns FROM verse WHERE page <= ? AND page_end >= ? '
        'ORDER BY id',
        [page, page],
      ))
        _place(row),
    ],
  );

  @override
  Future<Result<VersePlace?, QuranFailure>> verse(int sura, int aya) async =>
      _query((db) {
        final rows = db.select(
          'SELECT $_placeColumns FROM verse WHERE sura = ? AND aya = ?',
          [sura, aya],
        );
        return rows.isEmpty ? null : _place(rows.first);
      });

  static VersePlace _place(Row row) => VersePlace(
    sura: _int(row['sura']),
    aya: _int(row['aya']),
    page: _int(row['page']),
    lineStart: _int(row['line_start']),
    pageEnd: _int(row['page_end']),
    lineEnd: _int(row['line_end']),
    text: _string(row['text']),
  );

  static VerseHit _hit(Row row, String folded) {
    final text = _string(row['text']);
    final fold = ArabicSearchText.fold(text);
    final at = fold.text.indexOf(folded);
    final range = at < 0
        ? (start: 0, end: 0)
        : fold.sourceRange(text, at, at + folded.length);
    return VerseHit(
      sura: _int(row['sura']),
      aya: _int(row['aya']),
      page: _int(row['page']),
      text: text,
      matchStart: range.start,
      matchEnd: range.end,
    );
  }

  @override
  Future<void> close() async {
    _db?.close();
    _db = null;
  }

  static int _int(Object? value) => switch (value) {
    final int v => v,
    _ => throw const FormatException('expected an integer'),
  };

  static String _string(Object? value) => switch (value) {
    final String v => v,
    _ => throw const FormatException('expected text'),
  };
}
