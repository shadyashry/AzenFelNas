// The built Quran package, checked end to end on the host (§15 D107). Runs
// only when DM_QURAN_PACKAGE names a directory holding the package that
// `dm-pipelines quran build` wrote; CI has no copy of the package.
import 'dart:io';

import 'package:daily_muslim/features/quran/data/quran_manifest_codec.dart';
import 'package:daily_muslim/features/quran/data/sqlite_mushaf_index.dart';
import 'package:daily_muslim/features/quran/data/sqlite_search_index.dart';
import 'package:daily_muslim/features/quran/domain/juz_contents.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_lines.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final source = Platform.environment['DM_QURAN_PACKAGE'];
  final skip = source == null ? 'DM_QURAN_PACKAGE not set' : null;
  late Directory dir;
  late SqliteMushafIndex index;

  setUpAll(() {
    if (source == null) return;
    dir = Directory.systemTemp.createTempSync('quran_pkg');
    for (final name in ['manifest.json', 'quran.sqlite']) {
      File('$source/$name').copySync('${dir.path}/$name');
    }
    index = SqliteMushafIndex(dir.path);
  });

  tearDownAll(() async {
    if (source == null) return;
    await index.close();
    dir.deleteSync(recursive: true);
  });

  Future<SearchResults> search(String q) async =>
      switch (await index.search(q, limit: 50)) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError('$failure'),
      };

  test('REQ-QRN-011: the built manifest is the pinned one', () {
    final bytes = File('$source/manifest.json').readAsBytesSync();

    final manifest = QuranManifestCodec.acceptPinned(bytes);

    expect(manifest, isNotNull);
    expect(manifest?.files, hasLength(606));
  }, skip: skip);

  test('REQ-QRN-040: the search index builds, answers, and its size is '
      'the pinned one', () {
    final built = SqliteSearchIndex.buildSync(dir.path);

    final size = File('${dir.path}/search.sqlite').lengthSync();
    // The measured size is the pin; printing it helps re-pin after a change.
    // ignore: avoid_print
    print('search.sqlite: $size bytes');
    expect(built, isTrue);
    expect(SqliteSearchIndex.isCurrent(dir.path), isTrue);
    expect(size, QuranEditionPin.searchIndexBytes);
  }, skip: skip);

  test('REQ-QRN-023: 114 surahs and 30 juz with their pages', () async {
    final suras = (await index.suras()).fold();
    final juz = (await index.juz()).fold();

    expect(suras, hasLength(114));
    expect(suras.first.startPage, 1);
    expect(suras.last.startPage, 604);
    expect(suras.map((s) => s.verseCount).reduce((a, b) => a + b), 6236);
    expect(juz.map((j) => j.page), [
      1, 22, 42, 62, 82, 102, 121, 142, 162, 182, 201, 222, 242, 262, 282, //
      302, 322, 342, 362, 382, 402, 422, 442, 462, 482, 502, 522, 542, 562,
      582,
    ]);
  }, skip: skip);

  test(
    'REQ-QRN-040: a phrase typed without diacritics opens its verse',
    () async {
      final results = await search('الله لا إله إلا هو الحي القيوم');

      final kursi = results.hits.where((h) => h.sura == 2 && h.aya == 255);
      expect(kursi, hasLength(1));
      expect(kursi.single.page, 42);
      expect(kursi.single.matchEnd, greaterThan(kursi.single.matchStart));
    },
    skip: skip,
  );

  test('REQ-QRN-040: everyday spelling finds the Uthmani spelling', () async {
    final salah = await search('الصلاة');
    final book = await search('الكتاب');

    final vocative = await search('يا أيها الذين آمنوا');

    expect(salah.total, greaterThan(50));
    expect(vocative.total, greaterThan(50));
    expect(book.hits.any((h) => h.sura == 2 && h.aya == 2), isTrue);
  }, skip: skip);

  test(
    'REQ-QRN-040: the first and last verses are found on their pages',
    () async {
      final first = await search('الحمد لله رب العالمين');
      final last = await search('من الجنة والناس');

      expect(first.hits.first.page, 1);
      expect(last.hits.any((h) => h.sura == 114 && h.page == 604), isTrue);
    },
    skip: skip,
  );

  test('REQ-QRN-023: every surah sits under a juz, juz 4 opens inside '
      'Ali Imran at 3:93, and juz 30 closes with An-Nas', () async {
    final contents = juzContents(
      (await index.juz()).fold(),
      (await index.suras()).fold(),
    );

    final listed = {
      for (final (_, inside) in contents)
        for (final s in inside) s.sura.number,
    };
    expect(listed, {for (var n = 1; n <= 114; n++) n});
    final juz4 = contents[3].$2;
    expect(
      (juz4.first.sura.number, juz4.first.aya, juz4.first.page),
      (
        3,
        93,
        62,
      ),
    );
    expect(contents.last.$2.last.sura.number, 114);
  }, skip: skip);

  test(
    'REQ-QRN-040 REQ-QRN-052: an ayah copied from its sheet and pasted into '
    'search finds that ayah, with the English or the Arabic reference',
    () async {
      final place = switch (await index.verse(3, 96)) {
        Ok(:final value) => value!,
        Err(:final failure) => throw StateError('$failure'),
      };
      for (final reference in ["Ali 'Imran 3:96", 'آل عمران، الآية ٩٦']) {
        final results = await search('﴿${place.text}﴾\n$reference');

        expect(
          [
            for (final h in results.hits) (h.sura, h.aya),
          ],
          [(3, 96)],
          reason: reference,
        );
      }
    },
    skip: skip,
  );

  test('REQ-QRN-023 every verse sits on lines the geometry knows, and '
      'every page line holds a verse or a surah title (§15 D114)', () async {
    // The search index is attached on open; build it once for this test.
    SqliteSearchIndex.buildSync(dir.path);
    final covered = <(int, int)>{};
    for (var page = 1; page <= QuranEditionPin.layout.pageCount; page++) {
      final verses = switch (await index.versesOnPage(page)) {
        Ok(:final value) => value,
        Err(:final failure) => throw StateError('$failure'),
      };
      expect(verses, isNotEmpty, reason: 'page $page');
      for (final v in verses) {
        for (final (:page, :line) in v.lines(MushafLines.linesOn)) {
          expect(MushafLines.band(page, line), isNotNull);
          covered.add((page, line));
        }
      }
    }
    final suras = switch (await index.suras()) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError('$failure'),
    };
    var lines = 0;
    for (var page = 1; page <= QuranEditionPin.layout.pageCount; page++) {
      lines += MushafLines.linesOn(page);
    }
    // Uncovered lines are surah titles and basmalahs: at most two a surah.
    expect(lines - covered.length, lessThanOrEqualTo(2 * suras.length));
  }, skip: skip);

  test('REQ-QRN-023 al-Kahf opens on page 293: its first verse on line '
      '12 (§15 D114)', () async {
    final place = switch (await index.verse(18, 1)) {
      Ok(:final value) => value,
      Err(:final failure) => throw StateError('$failure'),
    };
    expect(
      (place?.page, place?.lineStart, place?.pageEnd, place?.lineEnd),
      (293, 12, 293, 12),
    );
  }, skip: skip);
}

extension<T> on Result<T, Object> {
  T fold() => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('$failure'),
  };
}
