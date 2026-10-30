import 'package:daily_muslim/features/quran/domain/surah_names.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('English surah names (§15 D110)', () {
    test('there is one distinct name for each of the 114 surahs', () {
      expect(SurahNames.english, hasLength(114));
      expect(SurahNames.english.toSet(), hasLength(114));
    });

    test('they follow the Mushaf order', () {
      expect(SurahNames.englishOf(1), 'Al-Fatihah');
      expect(SurahNames.englishOf(3), "Ali 'Imran");
      expect(SurahNames.englishOf(18), 'Al-Kahf');
      expect(SurahNames.englishOf(36), 'Ya-Sin');
      expect(SurahNames.englishOf(114), 'An-Nas');
    });

    test('a number outside the Mushaf has no name', () {
      expect(SurahNames.englishOf(0), isNull);
      expect(SurahNames.englishOf(115), isNull);
    });
  });
}
