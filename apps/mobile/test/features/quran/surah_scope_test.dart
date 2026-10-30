import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_layout.dart';
import 'package:daily_muslim/features/quran/domain/surah_scope.dart';
import 'package:flutter_test/flutter_test.dart';

SuraEntry _sura(int number, int startPage) => SuraEntry(
  number: number,
  header: 'سُورَةُ $number',
  startPage: startPage,
  verseCount: 10,
);

/// Surah 1 on page 1; 2 on 2–14; 3 starts on 14, the page 2 ends on, and
/// runs to 20; 112, 113 and 114 share page 604.
final List<SuraEntry> _suras = [
  _sura(1, 1),
  _sura(2, 2),
  _sura(3, 14),
  _sura(112, 604),
  _sura(113, 604),
  _sura(114, 604),
];

const Map<int, ({int first, int last})> _pages = {
  1: (first: 1, last: 1),
  2: (first: 2, last: 14),
  3: (first: 14, last: 20),
  112: (first: 604, last: 604),
  113: (first: 604, last: 604),
  114: (first: 604, last: 604),
};

SurahScope? _pick(int page, {int? selected}) => SurahScope.pick(
  page: page,
  selected: selected,
  suras: _suras,
  pagesOf: (sura) => _pages[sura],
);

void main() {
  group('SurahScope (§15 D120)', () {
    test(
      'REQ-QRN-024: the place of the page counts only the pages of the surah',
      () {
        final scope = _pick(5, selected: 2)!;

        expect(scope.sura.number, 2);
        expect((scope.position, scope.count), (4, 13));
        expect(scope.atStart || scope.atEnd || scope.single, isFalse);
      },
    );

    test('REQ-QRN-024: a page shared by two surahs stays in the chosen one, '
        'where it is the last page', () {
      final chosen = _pick(14, selected: 2)!;
      final next = _pick(14, selected: 3)!;

      expect(
        (chosen.sura.number, chosen.position, chosen.atEnd),
        (2, 13, true),
      );
      expect((next.sura.number, next.position, next.atStart), (3, 1, true));
    });

    test('REQ-QRN-024: without a choice, or once the page leaves the chosen '
        'surah, the surah of the last header at or before the page', () {
      expect(_pick(14)!.sura.number, 3);
      expect(_pick(16, selected: 2)!.sura.number, 3);
      expect(_pick(604)!.sura.number, 114);
    });

    test('REQ-QRN-024: several short surahs on one page: each chosen one is '
        'a one-page surah', () {
      for (final n in [112, 113, 114]) {
        final scope = _pick(604, selected: n)!;
        expect((scope.sura.number, scope.single), (n, true));
        expect(scope.atStart && scope.atEnd, isTrue);
      }
    });

    test('REQ-QRN-024: nothing until the pages of the surah are known', () {
      final scope = SurahScope.pick(
        page: 5,
        selected: 2,
        suras: _suras,
        pagesOf: (_) => null,
      );

      expect(scope, isNull);
    });
  });

  group('parseTypedNumber (§15 D120)', () {
    test('REQ-QRN-025: Western, Arabic-Indic and Eastern Arabic-Indic digits '
        'read the same; anything else is refused', () {
      expect(parseTypedNumber(' 255 '), 255);
      expect(parseTypedNumber('٢٥٥'), 255);
      expect(parseTypedNumber('۲۵۵'), 255);
      expect(parseTypedNumber('2a'), isNull);
      expect(parseTypedNumber(''), isNull);
    });
  });
}
