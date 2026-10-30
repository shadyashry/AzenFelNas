import 'package:daily_muslim/features/quran/domain/mushaf_lines.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/verse_place.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Line geometry of the pinned Mushaf (§15 D113)', () {
    test('it belongs to the pinned layout', () {
      expect(MushafLines.layoutId, QuranEditionPin.layoutId);
    });

    test('pages 3–604 have 15 lines and pages 1–2 have 8, as the package '
        'numbers them', () {
      expect(MushafLines.linesOn(1), 8);
      expect(MushafLines.linesOn(2), 8);
      expect(MushafLines.linesOn(3), 15);
      expect(MushafLines.linesOn(604), 15);
    });

    test('every line is a band inside the page, below the previous one and '
        'without overlap', () {
      for (final page in [1, 2, 3, 62, 293, 604]) {
        double? lastBottom;
        for (var line = 1; line <= MushafLines.linesOn(page); line++) {
          final b = MushafLines.band(page, line)!;
          expect(b.page, page);
          expect(b.left, greaterThanOrEqualTo(0));
          expect(b.right, lessThanOrEqualTo(1));
          expect(b.top, greaterThan(0));
          expect(b.bottom, lessThan(1));
          expect(b.right, greaterThan(b.left));
          if (lastBottom != null) {
            expect(b.top, greaterThanOrEqualTo(lastBottom - 1e-9));
          }
          lastBottom = b.bottom;
        }
      }
    });

    test('the frame follows the page side: even pages sit right of the '
        'margin ornament, odd pages left of it', () {
      final even = MushafLines.band(62, 1)!;
      final odd = MushafLines.band(293, 1)!;
      expect(even.left, greaterThan(odd.left));
      expect(even.right, greaterThan(odd.right));
    });

    test('a point is read back as the line whose band holds it; the '
        'margins, the page title and the page number hold none', () {
      for (final page in [2, 62, 293]) {
        for (var line = 1; line <= MushafLines.linesOn(page); line++) {
          final b = MushafLines.band(page, line)!;
          expect(
            MushafLines.lineAt(
              page,
              (b.left + b.right) / 2,
              (b.top + b.bottom) / 2,
            ),
            line,
          );
        }
      }
      expect(MushafLines.lineAt(62, 0.5, 0.05), isNull); // page title
      expect(MushafLines.lineAt(62, 0.5, 0.95), isNull); // page number
      expect(MushafLines.lineAt(62, 0.05, 0.5), isNull); // outer margin
      expect(MushafLines.band(62, 16), isNull);
      expect(MushafLines.band(1, 9), isNull);
    });
  });

  group('A verse place (§15 D113)', () {
    const kahf1 = VersePlace(
      sura: 18,
      aya: 1,
      page: 293,
      lineStart: 12,
      pageEnd: 293,
      lineEnd: 12,
      text: 'text',
    );

    test('it lists the lines it is on, in reading order', () {
      expect(kahf1.lines(MushafLines.linesOn), [(page: 293, line: 12)]);
    });

    // No verse of the pinned package crosses a page (checked on the built
    // package); the rule stays general for another layout.
    test('a verse running on to the next page covers the rest of its first '
        'page and the start of the next', () {
      const across = VersePlace(
        sura: 2,
        aya: 282,
        page: 47,
        lineStart: 14,
        pageEnd: 48,
        lineEnd: 2,
        text: 'text',
      );
      expect(across.lines(MushafLines.linesOn), [
        (page: 47, line: 14),
        (page: 47, line: 15),
        (page: 48, line: 1),
        (page: 48, line: 2),
      ]);
      expect(across.covers(48, 2), isTrue);
      expect(across.covers(48, 3), isFalse);
      expect(across.covers(47, 13), isFalse);
    });

    test('it covers its own lines only', () {
      expect(kahf1.covers(293, 11), isFalse); // the basmalah line
      expect(kahf1.covers(293, 12), isTrue);
      expect(kahf1.covers(293, 13), isFalse);
      expect(kahf1.covers(294, 12), isFalse);
    });
  });
}
