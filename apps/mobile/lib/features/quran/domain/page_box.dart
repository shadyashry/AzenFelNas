import 'dart:convert';

import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:meta/meta.dart';

/// The part of a Mushaf page its frameless image holds (§15 D123): the
/// bounds of every letter, mark, verse marker, heading and basmalah with a
/// small margin, measured by the package build from the Complex's vector
/// page. Edges are fractions of the whole page (origin top left), the unit
/// bookmarks, highlights and line positions are stored in, so they keep
/// their place whatever the box.
@immutable
final class PageBox {
  /// The box [left]..[right] × [top]..[bottom], drawn [pixelWidth] ×
  /// [pixelHeight].
  const new({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
    required this.pixelWidth,
    required this.pixelHeight,
  });

  /// The whole page, for a package whose images are whole pages.
  const new whole({required this.pixelWidth, required this.pixelHeight})
    : left = 0,
      top = 0,
      right = 1,
      bottom = 1;

  /// Left edge, 0..1 of the page's width.
  final double left;

  /// Top edge, 0..1 of the page's height.
  final double top;

  /// Right edge.
  final double right;

  /// Bottom edge.
  final double bottom;

  /// The image's width in pixels.
  final int pixelWidth;

  /// The image's height in pixels.
  final int pixelHeight;

  /// Width / height of what is shown: the reader fits this, never the page.
  double get aspect => pixelWidth / pixelHeight;

  /// The page point at ([x], [y]) of the box (0..1 of the box).
  ({double x, double y}) toPage(double x, double y) => (
    x: left + x * (right - left),
    y: top + y * (bottom - top),
  );

  /// The box point (0..1 of the box) at page point ([x], [y]).
  ({double x, double y}) fromPage(double x, double y) => (
    x: (x - left) / (right - left),
    y: (y - top) / (bottom - top),
  );

  /// [region] (page fractions) in box fractions; it may reach outside 0..1.
  HighlightRegion toBox(HighlightRegion region) {
    final a = fromPage(region.left, region.top);
    final b = fromPage(region.right, region.bottom);
    return HighlightRegion(
      page: region.page,
      left: a.x,
      top: a.y,
      right: b.x,
      bottom: b.y,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PageBox &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom &&
      other.pixelWidth == pixelWidth &&
      other.pixelHeight == pixelHeight;

  @override
  int get hashCode =>
      Object.hash(left, top, right, bottom, pixelWidth, pixelHeight);
}

/// Why `pages/boxes.json` could not be read.
final class PageBoxesFormatException implements Exception {
  /// The failure, with what was wrong.
  const new(this.message);

  /// What was wrong.
  final String message;

  @override
  String toString() => 'PageBoxesFormatException: $message';
}

/// Every page's [PageBox] from the package's `pages/boxes.json`
/// (`quran_page_boxes.v1`, §15 D123).
@immutable
final class PageBoxes {
  /// The boxes of pages 1..[pageCount], in order.
  const new(this._boxes);

  /// Reads [source]; throws [PageBoxesFormatException] unless it lists
  /// pages 1..[pageCount] in order, each inside the page with a positive
  /// size.
  factory parse(String source, {required int pageCount}) {
    final Object? document;
    try {
      document = jsonDecode(source);
    } on FormatException catch (e) {
      throw PageBoxesFormatException('not JSON: ${e.message}');
    }
    if (document is! Map<String, Object?> || document['schemaVersion'] != 1) {
      throw const PageBoxesFormatException('not quran_page_boxes.v1');
    }
    final pages = document['pages'];
    if (pages is! List<Object?> || pages.length != pageCount) {
      throw PageBoxesFormatException('expected $pageCount pages');
    }
    final boxes = <PageBox>[];
    for (final (i, entry) in pages.indexed) {
      if (entry is! Map<String, Object?> || entry['page'] != i + 1) {
        throw PageBoxesFormatException('page ${i + 1} out of order');
      }
      double edge(String key) => switch (entry[key]) {
        final num v when v >= 0 && v <= 1 => v.toDouble(),
        _ => throw PageBoxesFormatException('page ${i + 1}: bad $key'),
      };
      int pixels(String key) => switch (entry[key]) {
        final int v when v > 0 => v,
        _ => throw PageBoxesFormatException('page ${i + 1}: bad $key'),
      };
      final box = PageBox(
        left: edge('left'),
        top: edge('top'),
        right: edge('right'),
        bottom: edge('bottom'),
        pixelWidth: pixels('width'),
        pixelHeight: pixels('height'),
      );
      if (box.right <= box.left || box.bottom <= box.top) {
        throw PageBoxesFormatException('page ${i + 1}: empty box');
      }
      boxes.add(box);
    }
    return PageBoxes(List.unmodifiable(boxes));
  }

  final List<PageBox> _boxes;

  /// Number of pages.
  int get pageCount => _boxes.length;

  /// The box of [page] (1-based).
  PageBox of(int page) => _boxes[page - 1];
}
