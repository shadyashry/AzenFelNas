import 'package:meta/meta.dart';

/// The page order of a Mushaf, independent of the interface language
/// (§15 D106, REQ-QRN-020).
///
/// Pages are numbered 1..[pageCount] and read right to left: the next page
/// lies to the left of the current one, and a spread shows the odd page on
/// the right and the even page after it on the left, as in the printed
/// Madinah Mushaf. Nothing here depends on the app's text direction.
@immutable
final class MushafLayout {
  /// A layout of [pageCount] pages.
  const new(this.pageCount) : assert(pageCount > 0, 'pageCount > 0');

  /// Pages in the Mushaf.
  final int pageCount;

  /// Whether [page] exists.
  bool contains(int page) => page >= 1 && page <= pageCount;

  /// [page] moved into 1..[pageCount].
  int clamp(int page) => page.clamp(1, pageCount);

  /// The page after [page], or `null` on the last page.
  int? next(int page) => page < pageCount ? page + 1 : null;

  /// The page before [page], or `null` on the first page.
  int? previous(int page) => page > 1 ? page - 1 : null;

  /// Spreads in the Mushaf (two pages each; the last may hold one).
  int get spreadCount => (pageCount + 1) ~/ 2;

  /// The spread holding [page], 0-based.
  int spreadOf(int page) => (clamp(page) - 1) ~/ 2;

  /// The pages of [spread]: the right page (odd) and the left page (even),
  /// `null` when the Mushaf ends on the right page.
  ({int right, int? left}) pagesOf(int spread) {
    final right = spread * 2 + 1;
    return (right: right, left: right + 1 <= pageCount ? right + 1 : null);
  }

  /// The page number typed by a reader, or `null` when [input] is not a
  /// page of this Mushaf. Accepts Western and Arabic-Indic digits.
  int? parsePage(String input) {
    final digits = StringBuffer();
    for (final rune in input.trim().runes) {
      if (rune >= 0x30 && rune <= 0x39) {
        digits.writeCharCode(rune);
      } else if (rune >= 0x0660 && rune <= 0x0669) {
        digits.writeCharCode(rune - 0x0660 + 0x30);
      } else if (rune >= 0x06F0 && rune <= 0x06F9) {
        digits.writeCharCode(rune - 0x06F0 + 0x30);
      } else {
        return null;
      }
    }
    final page = int.tryParse(digits.toString());
    return page != null && contains(page) ? page : null;
  }
}
