// The built Quran package, checked end to end on the host (§15 D106). Runs
// only when DM_QURAN_PACKAGE names a directory holding the package that
// `dm-pipelines quran build` wrote; CI has no copy of the package.
import 'dart:io';

import 'package:daily_muslim/features/quran/data/quran_manifest_codec.dart';
import 'package:daily_muslim/features/quran/data/sqlite_mushaf_index.dart';
import 'package:daily_muslim/features/quran/data/sqlite_search_index.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
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
}

extension<T> on Result<T, Object> {
  T fold() => switch (this) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('$failure'),
  };
}
