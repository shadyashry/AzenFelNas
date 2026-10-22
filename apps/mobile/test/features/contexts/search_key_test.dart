import 'package:daily_muslim/features/contexts/domain/search_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SearchKey folds spelling variants (§15 D72)', () {
    test('Arabic: harakat, tatweel, alef forms, ta marbuta, alef maqsura', () {
      final key = SearchKey.of('القاهرة');
      expect(SearchKey.of('القَاهِرَة'), key);
      expect(SearchKey.of('القاهره'), key);
      expect(SearchKey.of('القاهـــرة'), key);
      expect(SearchKey.of('إسكندرية'), SearchKey.of('اسكندريه'));
      expect(SearchKey.of('دبى'), SearchKey.of('دبي'));
      expect(SearchKey.of('مكّة'), SearchKey.of('مكة'));
    });

    test('Latin: case, diacritics, spelled-out letters, punctuation', () {
      expect(SearchKey.of('Zürich').value, 'zurich');
      expect(SearchKey.of('  São   Paulo ').value, 'sao paulo');
      expect(SearchKey.of('Łódź').value, 'lodz');
      expect(SearchKey.of('El-Qâhira').value, 'el qahira');
      expect(SearchKey.of("Ma'an").value, 'maan');
      expect(SearchKey.of('Straße').value, 'strasse');
    });

    test('digits fold to ASCII and a query without letters is empty', () {
      expect(SearchKey.of('٦ أكتوبر'), SearchKey.of('6 اكتوبر'));
      expect(SearchKey.of(' - , . ').isEmpty, isTrue);
    });

    test('an Arabic name with the article is also indexed without it', () {
      expect(SearchKey.indexKeysOf('القاهرة'), {
        SearchKey.of('القاهرة'),
        SearchKey.of('قاهرة'),
      });
      expect(SearchKey.indexKeysOf('Cairo'), {SearchKey.of('cairo')});
      expect(SearchKey.indexKeysOf('ال'), {SearchKey.of('ال')});
      expect(SearchKey.indexKeysOf('...'), isEmpty);
    });
  });
}
