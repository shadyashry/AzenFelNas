import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:drift/drift.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'generated/schema.dart';
import 'generated/schema_v1.dart' as v1;
import 'generated/schema_v2.dart' as v2;

void main() {
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  group('simple database migrations', () {
    // These simple tests verify all possible schema updates with a simple (no
    // data) migration. This is a quick way to ensure that written database
    // migrations properly alter the schema.
    const versions = GeneratedHelper.versions;
    for (final (i, fromVersion) in versions.indexed) {
      group('from $fromVersion', () {
        for (final toVersion in versions.skip(i + 1)) {
          test('to $toVersion', () async {
            final schema = await verifier.schemaAt(fromVersion);
            final db = QuranNotesDatabase(schema.newConnection());
            await verifier.migrateAndValidate(db, toVersion);
            await db.close();
          });
        }
      });
    }
  });

  // Version 2 only adds the verse-highlight table (§15 D113); every note
  // a reader kept under version 1 must come through unchanged.
  test('REQ-QRN-060 migration from v1 to v2 keeps every note', () async {
    const layout = 'kfgqpc-hafs-1441-604';
    final oldQuranBookmarksData = <v1.QuranBookmarksData>[
      const v1.QuranBookmarksData(layoutId: layout, page: 62, createdUtc: 1),
    ];
    final expectedNewQuranBookmarksData = <v2.QuranBookmarksData>[
      const v2.QuranBookmarksData(layoutId: layout, page: 62, createdUtc: 1),
    ];

    final oldQuranHighlightsData = <v1.QuranHighlightsData>[
      const v1.QuranHighlightsData(
        id: 1,
        layoutId: layout,
        color: 'green',
        firstPage: 62,
        createdUtc: 2,
        updatedUtc: 3,
      ),
    ];
    final expectedNewQuranHighlightsData = <v2.QuranHighlightsData>[
      const v2.QuranHighlightsData(
        id: 1,
        layoutId: layout,
        color: 'green',
        firstPage: 62,
        createdUtc: 2,
        updatedUtc: 3,
      ),
    ];

    final oldQuranHighlightRegionsData = <v1.QuranHighlightRegionsData>[
      const v1.QuranHighlightRegionsData(
        id: 1,
        highlightId: 1,
        page: 62,
        x0: 0.2,
        y0: 0.3,
        x1: 0.8,
        y1: 0.4,
      ),
    ];
    final expectedNewQuranHighlightRegionsData = <v2.QuranHighlightRegionsData>[
      const v2.QuranHighlightRegionsData(
        id: 1,
        highlightId: 1,
        page: 62,
        x0: 0.2,
        y0: 0.3,
        x1: 0.8,
        y1: 0.4,
      ),
    ];

    final oldQuranReadingPositionsData = <v1.QuranReadingPositionsData>[
      const v1.QuranReadingPositionsData(
        layoutId: layout,
        page: 293,
        updatedUtc: 4,
      ),
    ];
    final expectedNewQuranReadingPositionsData = <v2.QuranReadingPositionsData>[
      const v2.QuranReadingPositionsData(
        layoutId: layout,
        page: 293,
        updatedUtc: 4,
      ),
    ];

    final oldQuranReaderPrefsData = <v1.QuranReaderPrefsData>[
      const v1.QuranReaderPrefsData(id: 1, fit: 'width', facingPages: 0),
    ];
    final expectedNewQuranReaderPrefsData = <v2.QuranReaderPrefsData>[
      const v2.QuranReaderPrefsData(id: 1, fit: 'width', facingPages: 0),
    ];

    await verifier.testWithDataIntegrity(
      oldVersion: 1,
      newVersion: 2,
      createOld: v1.DatabaseAtV1.new,
      createNew: v2.DatabaseAtV2.new,
      openTestedDatabase: QuranNotesDatabase.new,
      createItems: (batch, oldDb) => batch
        ..insertAll(oldDb.quranBookmarks, oldQuranBookmarksData)
        ..insertAll(oldDb.quranHighlights, oldQuranHighlightsData)
        ..insertAll(oldDb.quranHighlightRegions, oldQuranHighlightRegionsData)
        ..insertAll(oldDb.quranReadingPositions, oldQuranReadingPositionsData)
        ..insertAll(oldDb.quranReaderPrefs, oldQuranReaderPrefsData),
      validateItems: (newDb) async {
        expect(
          expectedNewQuranBookmarksData,
          await newDb.select(newDb.quranBookmarks).get(),
        );
        expect(
          expectedNewQuranHighlightsData,
          await newDb.select(newDb.quranHighlights).get(),
        );
        expect(
          expectedNewQuranHighlightRegionsData,
          await newDb.select(newDb.quranHighlightRegions).get(),
        );
        expect(
          expectedNewQuranReadingPositionsData,
          await newDb.select(newDb.quranReadingPositions).get(),
        );
        expect(
          expectedNewQuranReaderPrefsData,
          await newDb.select(newDb.quranReaderPrefs).get(),
        );
        expect(await newDb.select(newDb.quranAyahHighlights).get(), isEmpty);
      },
    );
  });
}
