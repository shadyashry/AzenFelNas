import 'dart:io';
import 'dart:isolate';

import 'package:daily_muslim/features/quran/domain/arabic_search_text.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:sqlite3/sqlite3.dart';

/// [BuildSearchIndex] with SQLite FTS5 (trigram tokenizer): `search.sqlite`
/// beside `quran.sqlite`, holding the folded text of every verse
/// ([ArabicSearchText]) under the verse's id (§15 D106, REQ-QRN-040).
///
/// The index is derived data: it is built on the device, after every
/// package file was verified and before the package is activated, and
/// rebuilt whenever it is missing or was folded by another version.
final class SqliteSearchIndex implements BuildSearchIndex {
  /// The builder; [run] moves the work off the UI isolate.
  const new({this.run = Isolate.run});

  /// Runs a computation on another isolate.
  final Future<bool> Function(bool Function() work) run;

  /// The index file name.
  static const fileName = searchIndexFileName;

  /// Bumped whenever [ArabicSearchText] folds differently.
  static const foldVersion = '2';

  @override
  Future<Result<void, QuranFailure>> call(String directory) async {
    final ok = await run(() => buildSync(directory));
    return ok
        ? const Result.ok(null)
        : const Result.err(QuranSearchUnavailable());
  }

  /// Whether the index in [directory] exists and was folded by this build.
  static bool isCurrent(String directory) {
    final file = File('$directory/$fileName');
    if (!file.existsSync()) return false;
    try {
      final db = sqlite3.open(file.path, mode: OpenMode.readOnly);
      try {
        final rows = db.select(
          "SELECT value FROM meta WHERE key = 'foldVersion'",
        );
        return rows.length == 1 && rows.first['value'] == foldVersion;
      } finally {
        db.close();
      }
    } on SqliteException {
      return false;
    }
  }

  /// Builds the index in [directory] and confirms a query answers; `false`
  /// on any failure (nothing half-built is left behind).
  static bool buildSync(String directory) {
    final target = File('$directory/$fileName');
    final tmp = File('${target.path}.tmp');
    try {
      if (tmp.existsSync()) tmp.deleteSync();
      final source = sqlite3.open(
        '$directory/quran.sqlite',
        mode: OpenMode.readOnly,
      );
      final verses = source.select('SELECT id, text FROM verse ORDER BY id');
      source.close();
      final db = sqlite3.open(tmp.path);
      try {
        db
          ..execute('CREATE TABLE meta(key TEXT PRIMARY KEY, value TEXT)')
          ..execute(
            "CREATE VIRTUAL TABLE verse_fts USING fts5(norm, tokenize='trigram')",
          )
          ..execute('BEGIN');
        final insert = db.prepare(
          'INSERT INTO verse_fts(rowid, norm) VALUES (?, ?)',
        );
        for (final row in verses) {
          insert.execute([
            row['id'],
            ArabicSearchText.normalize(row['text'] as String),
          ]);
        }
        insert.close();
        db
          ..execute('INSERT INTO meta VALUES (?, ?)', [
            'foldVersion',
            foldVersion,
          ])
          ..execute('COMMIT');
        if (!_answers(db, verses.length)) return false;
      } finally {
        db.close();
      }
      tmp.renameSync(target.path);
      return true;
    } on SqliteException {
      if (tmp.existsSync()) tmp.deleteSync();
      return false;
    } on FileSystemException {
      return false;
    }
  }

  /// Every verse is indexed and a substring query finds the first one.
  static bool _answers(Database db, int verses) {
    final count = db.select('SELECT count(*) AS n FROM verse_fts').first['n'];
    if (count != verses || verses == 0) return false;
    final first = db.select('SELECT norm FROM verse_fts WHERE rowid = 1');
    if (first.isEmpty) return false;
    final norm = first.first['norm'] as String;
    final probe = norm.substring(0, norm.length < 6 ? norm.length : 6);
    final hits = db.select(
      'SELECT rowid FROM verse_fts WHERE norm LIKE ? LIMIT 1',
      ['%$probe%'],
    );
    return hits.isNotEmpty;
  }
}
