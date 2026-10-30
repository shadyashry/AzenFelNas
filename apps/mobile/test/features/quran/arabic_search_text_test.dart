import 'package:daily_muslim/features/quran/domain/arabic_search_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  String fold(String s) => ArabicSearchText.normalize(s);

  test('REQ-QRN-040: the Uthmani and the everyday spelling fold alike', () {
    expect(fold('ٱلصَّلَوٰةَ'), fold('الصلاة'));
    expect(fold('ٱلۡكِتَٰبُ'), fold('الكتاب'));
    expect(fold('ٱلرَّحۡمَٰنِ'), fold('الرحمن'));
    expect(fold('يَٰٓأَيُّهَا'), fold('يا أيها'));
    expect(fold('ءَامَنُواْ'), fold('آمنوا'));
    expect(fold('ٱلنَّبِيِّـۧنَ'), fold('النبيين'));
  });

  test('REQ-QRN-040: diacritics, Quranic marks and verse numbers are '
      'ignored', () {
    expect(fold('بِسۡمِ ٱللَّهِ'), fold('بسم الله'));
    expect(fold('۞ وَٱلۡمُحۡصَنَٰتُ'), fold('والمحصنات'));
    expect(fold('عَلِيمًا ۝٢٤'), fold('عليما'));
    expect(fold('   '), isEmpty);
  });

  test('REQ-QRN-040 REQ-QRN-052: a query quoted in ornate parentheses is '
      'searched by what is inside them', () {
    const ayah = 'بِسۡمِ ٱللَّهِ ٱلرَّحۡمَٰنِ ٱلرَّحِيمِ';

    expect(ArabicSearchText.query('﴿$ayah﴾\nAl-Fatihah 1:1'), fold(ayah));
    expect(ArabicSearchText.query('﴿$ayah﴾\nالفاتحة، الآية ١'), fold(ayah));
    expect(ArabicSearchText.query('﴿$ayah'), fold(ayah));
    expect(ArabicSearchText.query('بسم الله'), fold('بسم الله'));
    expect(ArabicSearchText.query('﴿﴾'), isEmpty);
    expect(fold('﴿بسم﴾'), fold('بسم'));
  });

  test('REQ-QRN-040: the match maps back onto the published text', () {
    const text = 'ٱلۡحَمۡدُ لِلَّهِ رَبِّ ٱلۡعَٰلَمِينَ';
    final folded = ArabicSearchText.fold(text);
    final query = fold('رب');
    final at = folded.text.indexOf(query);

    final range = folded.sourceRange(text, at, at + query.length);

    expect(text.substring(range.start, range.end), 'رَبِّ');
  });

  test('REQ-QRN-040: folding never changes the text it was given', () {
    const text = 'ٱللَّهُ لَآ إِلَٰهَ إِلَّا هُوَ';
    final copy = String.fromCharCodes(text.codeUnits);

    ArabicSearchText.fold(text);

    expect(text, copy);
  });
}
