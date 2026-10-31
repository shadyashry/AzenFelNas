import 'dart:convert';

import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/hizb_quarter.dart';
import 'package:daily_muslim/features/quran/domain/page_box.dart';
import 'package:flutter_test/flutter_test.dart';

String _boxes(List<Map<String, Object>> pages) =>
    jsonEncode({'schemaVersion': 1, 'pages': pages});

Map<String, Object> _page(int page) => {
  'page': page,
  'left': 0.1,
  'top': 0.12,
  'right': 0.8,
  'bottom': 0.88,
  'width': 1600,
  'height': 2400,
};

void main() {
  group('PageBox (§15 D123)', () {
    const box = PageBox(
      left: 0.1,
      top: 0.2,
      right: 0.6,
      bottom: 0.7,
      pixelWidth: 1600,
      pixelHeight: 1600,
    );

    test('REQ-QRN-030: the reader fits the content box, never the canvas', () {
      expect(box.aspect, 1);
    });

    test('REQ-QRN-050: a point on the box maps to the same page point and '
        'back, so highlights and taps keep their content', () {
      final p = box.toPage(0.5, 0.25);
      expect(p.x, closeTo(0.35, 1e-9));
      expect(p.y, closeTo(0.325, 1e-9));
      final back = box.fromPage(p.x, p.y);
      expect(back.x, closeTo(0.5, 1e-9));
      expect(back.y, closeTo(0.25, 1e-9));
    });

    test('REQ-QRN-050: a saved highlight is drawn through the box', () {
      final r = box.toBox(
        const HighlightRegion(
          page: 5,
          left: 0.1,
          top: 0.2,
          right: 0.35,
          bottom: 0.7,
        ),
      );
      expect(r.left, closeTo(0, 1e-9));
      expect(r.right, closeTo(0.5, 1e-9));
      expect(r.top, closeTo(0, 1e-9));
      expect(r.bottom, closeTo(1, 1e-9));
    });

    test('a package of whole pages draws the whole page', () {
      const whole = PageBox.whole(pixelWidth: 1400, pixelHeight: 2002);
      expect(whole.toPage(0.3, 0.4), (x: 0.3, y: 0.4));
      expect(whole.aspect, 1400 / 2002);
    });
  });

  group('PageBoxes (quran_page_boxes.v1)', () {
    test('reads every page in order', () {
      final boxes = PageBoxes.parse(
        _boxes([_page(1), _page(2)]),
        pageCount: 2,
      );
      expect(boxes.pageCount, 2);
      expect(boxes.of(2).pixelHeight, 2400);
    });

    test('refuses a missing page, pages out of order, an edge outside the '
        'page and an empty box', () {
      void refused(String source) => expect(
        () => PageBoxes.parse(source, pageCount: 2),
        throwsA(isA<PageBoxesFormatException>()),
      );
      refused(_boxes([_page(1)]));
      refused(_boxes([_page(2), _page(1)]));
      refused(
        _boxes([
          _page(1),
          {..._page(2), 'right': 1.2},
        ]),
      );
      refused(
        _boxes([
          _page(1),
          {..._page(2), 'bottom': 0.1},
        ]),
      );
      refused('{"schemaVersion": 2, "pages": []}');
      refused('not json');
    });
  });

  group('HizbQuarter (§15 D123)', () {
    test('numbers the hizb and the quarter from the quarter number', () {
      const q = HizbQuarter(number: 7, sura: 2, aya: 142, page: 22);
      expect(q.hizb, 2);
      expect(q.part, HizbPart.half);
      expect(
        const HizbQuarter(number: 240, sura: 100, aya: 9, page: 600).part,
        HizbPart.threeQuarters,
      );
      expect(
        const HizbQuarter(number: 9, sura: 2, aya: 203, page: 32).part,
        HizbPart.start,
      );
    });

    test('finds the quarter that starts on a page, none elsewhere', () {
      const quarters = [
        HizbQuarter(number: 1, sura: 1, aya: 1, page: 1),
        HizbQuarter(number: 2, sura: 2, aya: 26, page: 5),
        HizbQuarter(number: 3, sura: 2, aya: 44, page: 7),
      ];
      expect(HizbQuarter.on(quarters, 5)?.number, 2);
      expect(HizbQuarter.on(quarters, 6), isNull);
    });
  });
}
