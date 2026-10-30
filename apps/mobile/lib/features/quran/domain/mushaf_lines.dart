import 'package:daily_muslim/features/quran/domain/highlight.dart';

/// Where each numbered line sits on the page images of the pinned edition
/// `kfgqpc-hafs-1441-604` (§15 D114), in page-relative units (0..1 of the
/// image's width and height). Measured once from the package's own page
/// images, which are never changed: on pages 3–604 the 15 lines are evenly
/// spaced (line 1 centred at 0.15609, pitch 0.04912; over 20 sampled pages
/// no line centre is more than 0.008 off) inside a frame that alternates
/// with the page's side; pages 1 and 2 set 8 lines in a circle, each line
/// with its own measured width. Another layout has no geometry here.
abstract final class MushafLines {
  /// The layout this geometry was measured on.
  static const String layoutId = 'kfgqpc-hafs-1441-604';

  static const double _firstCentre = 0.15609;
  static const double _pitch = 0.04912;

  // The frame's inner edges, measured where it is green.
  static const ({double left, double right}) _evenFrame = (
    left: 0.2264,
    right: 0.8943,
  );
  static const ({double left, double right}) _oddFrame = (
    left: 0.105,
    right: 0.7729,
  );

  // Pages 1 and 2: the title band, then lines 2..8 in a circle.
  static const double _openingPitch = 0.0389;
  static const double _openingSecondCentre = 0.3836;
  static const List<({double left, double right})> _openingWidths = [
    (left: 0.38, right: 0.62), // 1: the surah title
    (left: 0.38, right: 0.625),
    (left: 0.337, right: 0.673),
    (left: 0.304, right: 0.72),
    (left: 0.277, right: 0.718),
    (left: 0.294, right: 0.71),
    (left: 0.339, right: 0.669),
    (left: 0.47, right: 0.61),
  ];

  /// The number of lines on [page].
  static int linesOn(int page) => page <= 2 ? 8 : 15;

  /// The band of [line] on [page]; `null` outside the page's lines.
  static HighlightRegion? band(int page, int line) {
    if (page < 1 || line < 1 || line > linesOn(page)) return null;
    if (page <= 2) {
      final width = _openingWidths[line - 1];
      final (top, bottom) = line == 1
          ? (0.235, 0.302)
          : (
              _openingSecondCentre + (line - 2.5) * _openingPitch,
              _openingSecondCentre + (line - 1.5) * _openingPitch,
            );
      return HighlightRegion(
        page: page,
        left: width.left,
        top: top,
        right: width.right,
        bottom: bottom,
      );
    }
    final frame = page.isEven ? _evenFrame : _oddFrame;
    final centre = _firstCentre + (line - 1) * _pitch;
    return HighlightRegion(
      page: page,
      left: frame.left,
      top: centre - _pitch / 2,
      right: frame.right,
      bottom: centre + _pitch / 2,
    );
  }

  /// The line under the page-relative point ([x], [y]) of [page]; `null`
  /// outside every line (the margins, the page title, the page number).
  static int? lineAt(int page, double x, double y) {
    for (var line = 1; line <= linesOn(page); line++) {
      final b = band(page, line);
      if (b != null &&
          y >= b.top &&
          y < b.bottom &&
          x >= b.left - 0.02 &&
          x <= b.right + 0.02) {
        return line;
      }
    }
    return null;
  }
}
