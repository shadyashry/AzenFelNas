import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:meta/meta.dart';

/// One marked area of a page, in page-relative coordinates (0..1 of the
/// page image's width and height, origin top left).
///
/// An area highlight marks a visual region the reader drew; it does not
/// identify words or verses (§15 D106, REQ-QRN-050).
@immutable
final class HighlightRegion {
  /// The area [left]..[right] × [top]..[bottom] of [page].
  const new({
    required this.page,
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  /// The smallest side, as a fraction of the page.
  static const double minSize = 0.01;

  /// The region spanned by two corners, clamped to the page; `null` when
  /// it is too small to be a deliberate mark.
  static HighlightRegion? between(
    int page,
    ({double x, double y}) a,
    ({double x, double y}) b,
  ) {
    double c(double v) => v.clamp(0, 1).toDouble();
    final left = c(a.x < b.x ? a.x : b.x);
    final right = c(a.x < b.x ? b.x : a.x);
    final top = c(a.y < b.y ? a.y : b.y);
    final bottom = c(a.y < b.y ? b.y : a.y);
    if (right - left < minSize || bottom - top < minSize) return null;
    return HighlightRegion(
      page: page,
      left: left,
      top: top,
      right: right,
      bottom: bottom,
    );
  }

  /// Page number.
  final int page;

  /// Left edge, 0..1.
  final double left;

  /// Top edge, 0..1.
  final double top;

  /// Right edge, 0..1.
  final double right;

  /// Bottom edge, 0..1.
  final double bottom;

  @override
  bool operator ==(Object other) =>
      other is HighlightRegion &&
      other.page == page &&
      other.left == left &&
      other.top == top &&
      other.right == right &&
      other.bottom == bottom;

  @override
  int get hashCode => Object.hash(page, left, top, right, bottom);
}

/// A highlight: one colour over one or more regions, possibly on several
/// pages, stored against a page layout ([layoutId]).
@immutable
final class Highlight {
  /// The highlight.
  const new({
    required this.id,
    required this.layoutId,
    required this.color,
    required this.regions,
    required this.createdUtcMs,
    required this.updatedUtcMs,
  });

  /// Store id.
  final int id;

  /// The page layout the regions belong to.
  final String layoutId;

  /// Colour.
  final HighlightColor color;

  /// At least one region, ordered by page.
  final List<HighlightRegion> regions;

  /// Created, UTC epoch ms.
  final int createdUtcMs;

  /// Last edited, UTC epoch ms.
  final int updatedUtcMs;

  /// The first page it covers.
  int get firstPage => regions.first.page;

  /// The last page it covers.
  int get lastPage => regions.last.page;
}

/// A bookmarked page.
@immutable
final class Bookmark {
  /// The bookmark.
  const new({
    required this.layoutId,
    required this.page,
    required this.createdUtcMs,
  });

  /// The page layout.
  final String layoutId;

  /// The page.
  final int page;

  /// Created, UTC epoch ms.
  final int createdUtcMs;

  @override
  bool operator ==(Object other) =>
      other is Bookmark &&
      other.layoutId == layoutId &&
      other.page == page &&
      other.createdUtcMs == createdUtcMs;

  @override
  int get hashCode => Object.hash(layoutId, page, createdUtcMs);
}
