import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = 'kfgqpc-hafs-1441-604';
  late QuranNotesDatabase db;
  late DriftQuranNotes notes;

  setUp(() {
    db = QuranNotesDatabase(NativeDatabase.memory());
    notes = DriftQuranNotes(db);
  });

  tearDown(() => db.close());

  test('REQ-QRN-060: a bookmark toggles on and off', () async {
    expect(await notes.toggleBookmark(layout, 586, nowUtcMs: 1), isTrue);
    expect(await notes.toggleBookmark(layout, 2, nowUtcMs: 2), isTrue);

    final marked = await notes.watchBookmarks(layout).first;
    expect(marked.map((b) => b.page), [2, 586]);

    expect(await notes.toggleBookmark(layout, 586, nowUtcMs: 3), isFalse);
    expect((await notes.watchBookmarks(layout).first).map((b) => b.page), [2]);
  });

  test('REQ-QRN-050: a highlight over two pages keeps its regions, and can '
      'be recoloured and deleted', () async {
    const a = HighlightRegion(
      page: 587,
      left: 0.1,
      top: 0.2,
      right: 0.9,
      bottom: 0.25,
    );
    const b = HighlightRegion(
      page: 586,
      left: 0.1,
      top: 0.8,
      right: 0.9,
      bottom: 0.85,
    );

    final id = await notes.addHighlight(layout, HighlightColor.yellow, [
      a,
      b,
    ], nowUtcMs: 10);
    await notes.recolorHighlight(id, HighlightColor.blue, nowUtcMs: 20);

    final saved = (await notes.watchHighlights(layout).first).single;
    expect(saved.regions, [b, a]);
    expect((saved.firstPage, saved.lastPage), (586, 587));
    expect(saved.color, HighlightColor.blue);
    expect(saved.updatedUtcMs, 20);

    await notes.deleteHighlight(id);
    expect(await notes.watchHighlights(layout).first, isEmpty);
    final orphans = await db.select(db.quranHighlightRegions).get();
    expect(orphans, isEmpty);
  });

  test('REQ-QRN-030: notes of another page layout never show', () async {
    await notes.toggleBookmark('another-layout', 10, nowUtcMs: 1);
    await notes.addHighlight(
      'another-layout',
      HighlightColor.green,
      const [
        HighlightRegion(page: 10, left: 0, top: 0, right: 0.5, bottom: 0.5),
      ],
      nowUtcMs: 1,
    );

    expect(await notes.watchBookmarks(layout).first, isEmpty);
    expect(await notes.watchHighlights(layout).first, isEmpty);
  });

  test('REQ-QRN-021: the last page and the reader choices are kept', () async {
    expect(await notes.readPosition(layout), isNull);
    expect(await notes.readPreferences(), const ReaderPreferences());

    await notes.writePosition(layout, 42, nowUtcMs: 1);
    await notes.writePosition(layout, 440, nowUtcMs: 2);
    await notes.writePreferences(
      const ReaderPreferences(fit: PageFit.width, facingPages: false),
    );

    expect(await notes.readPosition(layout), 440);
    expect(
      await notes.readPreferences(),
      const ReaderPreferences(fit: PageFit.width, facingPages: false),
    );
  });

  test('REQ-QRN-050: an area too small to be deliberate is not a region', () {
    expect(
      HighlightRegion.between(1, (x: 0.5, y: 0.5), (x: 0.505, y: 0.6)),
      isNull,
    );
    final r = HighlightRegion.between(1, (x: 0.9, y: 1.4), (x: 0.2, y: 0.3));
    expect(
      r,
      const HighlightRegion(
        page: 1,
        left: 0.2,
        top: 0.3,
        right: 0.9,
        bottom: 1,
      ),
    );
  });

  test('REQ-QRN-052 a verse highlight is kept per verse, recoloured in '
      'place and removed (§15 D113)', () async {
    await notes.setAyahHighlight(
      layout,
      2,
      255,
      HighlightColor.yellow,
      nowUtcMs: 1,
    );
    await notes.setAyahHighlight(
      layout,
      1,
      7,
      HighlightColor.green,
      nowUtcMs: 2,
    );
    await notes.setAyahHighlight(
      layout,
      2,
      255,
      HighlightColor.blue,
      nowUtcMs: 3,
    );

    final saved = await notes.watchAyahHighlights(layout).first;
    expect(
      [for (final h in saved) (h.sura, h.aya, h.color)],
      [
        (1, 7, HighlightColor.green),
        (2, 255, HighlightColor.blue),
      ],
    );
    final kursi = saved.last;
    expect((kursi.createdUtcMs, kursi.updatedUtcMs), (1, 3));

    await notes.removeAyahHighlight(layout, 2, 255);
    expect(
      [for (final h in await notes.watchAyahHighlights(layout).first) h.aya],
      [7],
    );
  });

  test(
    'REQ-QRN-060 verse highlights of another layout are not shown',
    () async {
      await notes.setAyahHighlight(
        'other-layout',
        2,
        255,
        HighlightColor.pink,
        nowUtcMs: 1,
      );
      expect(await notes.watchAyahHighlights(layout).first, isEmpty);
    },
  );
}
