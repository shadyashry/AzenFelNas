import 'dart:io';

import 'package:daily_muslim/features/quran/data/sqlite_mushaf_index.dart';
import 'package:daily_muslim/features/quran/data/sqlite_search_index.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// A few made-up rows in the shape of the package's `verse` table, as the
/// pipeline writes it (`data-pipelines/src/dm_pipelines/quran/pipeline.py`).
void _writePackage(String dir) {
  sqlite3.open('$dir/quran.sqlite')
    ..execute('''
      CREATE TABLE verse(
        id INTEGER PRIMARY KEY, sura INTEGER NOT NULL, aya INTEGER NOT NULL,
        page INTEGER NOT NULL, line_start INTEGER NOT NULL,
        page_end INTEGER NOT NULL, line_end INTEGER NOT NULL,
        text TEXT NOT NULL, UNIQUE(sura, aya));
    ''')
    ..execute(
      'INSERT INTO verse VALUES '
      "(1, 17, 111, 293, 7, 293, 9, 'a'), "
      "(2, 18, 1, 293, 12, 293, 13, 'b'), "
      "(3, 18, 2, 293, 13, 293, 14, 'c'), "
      "(4, 18, 3, 293, 15, 293, 15, 'd'), "
      "(5, 18, 4, 293, 15, 294, 1, 'e')",
    )
    ..close();
  sqlite3.open('$dir/${SqliteSearchIndex.fileName}').close();
}

void main() {
  late Directory dir;
  late SqliteMushafIndex index;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('verse_places');
    _writePackage(dir.path);
    index = SqliteMushafIndex(dir.path);
  });

  tearDown(() async {
    await index.close();
    dir.deleteSync(recursive: true);
  });

  group('Verse places from the package (§15 D114)', () {
    test('a page lists every verse that touches it, in Mushaf order, '
        'including one that runs on from or to the next page', () async {
      final on293 = switch (await index.versesOnPage(293)) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError('$failure'),
      };
      expect(
        [for (final v in on293) (v.sura, v.aya)],
        [
          (17, 111),
          (18, 1),
          (18, 2),
          (18, 3),
          (18, 4),
        ],
      );
      final on294 = switch (await index.versesOnPage(294)) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError('$failure'),
      };
      expect([for (final v in on294) (v.sura, v.aya)], [(18, 4)]);
    });

    test(
      'a verse is found by its reference, with its lines and text',
      () async {
        final place = switch (await index.verse(18, 1)) {
          Ok(:final value) => value,
          Err(:final failure) => throw StateError('$failure'),
        };
        expect(
          place,
          const VersePlace(
            sura: 18,
            aya: 1,
            page: 293,
            lineStart: 12,
            pageEnd: 293,
            lineEnd: 13,
            text: 'b',
          ),
        );
        final none = switch (await index.verse(18, 200)) {
          Ok(:final value) => value,
          Err(:final failure) => throw StateError('$failure'),
        };
        expect(none, isNull);
      },
    );
  });
}
