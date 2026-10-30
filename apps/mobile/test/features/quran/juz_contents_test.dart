import 'package:daily_muslim/features/quran/domain/juz_contents.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:flutter_test/flutter_test.dart';

SuraEntry _s(int n, int page) =>
    SuraEntry(number: n, header: 'h$n', startPage: page, verseCount: 10);

void main() {
  // Juz 3 to 5 and the end of the Mushaf, as in the pinned package.
  final suras = [
    _s(2, 2),
    _s(3, 50),
    _s(4, 77),
    _s(5, 106),
    _s(113, 604),
    _s(114, 604),
  ];
  const juz = [
    JuzEntry(number: 3, sura: 2, aya: 253, page: 42),
    JuzEntry(number: 4, sura: 3, aya: 93, page: 62),
    JuzEntry(number: 5, sura: 4, aya: 24, page: 82),
    JuzEntry(number: 30, sura: 113, aya: 1, page: 604),
  ];

  test('REQ-QRN-023: a juz lists the surah it opens inside, from that '
      'verse, then the surahs that start in it', () {
    final contents = juzContents(juz, suras);

    expect(contents[0].$2, [
      JuzSurah(sura: suras[0], aya: 253, page: 42),
      JuzSurah(sura: suras[1], aya: 1, page: 50),
    ]);
    expect(contents[1].$2, [
      JuzSurah(sura: suras[1], aya: 93, page: 62),
      JuzSurah(sura: suras[2], aya: 1, page: 77),
    ]);
  });

  test('REQ-QRN-023: a surah the next juz starts with is left to that '
      'juz, and the last juz runs to the last surah', () {
    final contents = juzContents(juz, suras);

    expect([for (final s in contents[2].$2) s.sura.number], [4, 5]);
    expect(contents[3].$2, [
      JuzSurah(sura: suras[4], aya: 1, page: 604),
      JuzSurah(sura: suras[5], aya: 1, page: 604),
    ]);
  });
}
