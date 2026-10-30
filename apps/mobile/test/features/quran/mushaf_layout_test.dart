import 'package:daily_muslim/features/quran/domain/mushaf_layout.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const layout = MushafLayout(604);

  test('REQ-QRN-020: the first and last pages have no page beyond them', () {
    expect(layout.previous(1), isNull);
    expect(layout.next(1), 2);
    expect(layout.next(604), isNull);
    expect(layout.previous(604), 603);
  });

  test('REQ-QRN-020: a spread is the odd page on the right and the next '
      'page on the left', () {
    expect(layout.spreadCount, 302);
    expect(layout.pagesOf(0), (right: 1, left: 2));
    expect(layout.pagesOf(292), (right: 585, left: 586));
    expect(layout.spreadOf(586), 292);
    expect(layout.spreadOf(585), 292);
    expect(const MushafLayout(5).pagesOf(2), (right: 5, left: null));
  });

  test('REQ-QRN-022: a typed page accepts Western and Arabic-Indic digits', () {
    expect(layout.parsePage(' 586 '), 586);
    expect(layout.parsePage('٥٨٦'), 586);
    expect(layout.parsePage('۵۸۶'), 586);
    expect(layout.parsePage('1'), 1);
    expect(layout.parsePage('604'), 604);
  });

  test('REQ-QRN-022: a typed page outside the Mushaf is refused', () {
    expect(layout.parsePage('0'), isNull);
    expect(layout.parsePage('605'), isNull);
    expect(layout.parsePage(''), isNull);
    expect(layout.parsePage('12a'), isNull);
    expect(layout.parsePage('-3'), isNull);
  });
}
