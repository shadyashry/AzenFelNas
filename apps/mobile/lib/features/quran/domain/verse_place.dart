import 'package:meta/meta.dart';

/// Where one verse stands in the Mushaf, from the package's `verse` table
/// (§15 D111): it starts on [page] at [lineStart] and ends on [pageEnd] at
/// [lineEnd] (lines counted 1..15 down a page, the surah title and
/// basmalah lines included), with its [text] as the KFGQPC source gives
/// it. A verse may start or end in the middle of a line; the data does not
/// say where within the line.
@immutable
final class VersePlace {
  /// The place of verse [aya] of surah [sura].
  const new({
    required this.sura,
    required this.aya,
    required this.page,
    required this.lineStart,
    required this.pageEnd,
    required this.lineEnd,
    required this.text,
  });

  /// Surah, 1..114.
  final int sura;

  /// Verse number within the surah.
  final int aya;

  /// The page it starts on.
  final int page;

  /// The line it starts on.
  final int lineStart;

  /// The page it ends on.
  final int pageEnd;

  /// The line it ends on.
  final int lineEnd;

  /// The verse text from the KFGQPC source, unchanged.
  final String text;

  /// Every (page, line) the verse touches, in reading order; a page holds
  /// [linesPerPage] lines.
  List<({int page, int line})> lines(int Function(int page) linesPerPage) => [
    for (var p = page; p <= pageEnd; p++)
      for (
        var line = p == page ? lineStart : 1;
        line <= (p == pageEnd ? lineEnd : linesPerPage(p));
        line++
      )
        (page: p, line: line),
  ];

  /// Whether the verse touches [line] of [onPage].
  bool covers(int onPage, int line) {
    if (onPage < page || onPage > pageEnd) return false;
    if (onPage == page && line < lineStart) return false;
    if (onPage == pageEnd && line > lineEnd) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      other is VersePlace &&
      other.sura == sura &&
      other.aya == aya &&
      other.page == page &&
      other.lineStart == lineStart &&
      other.pageEnd == pageEnd &&
      other.lineEnd == lineEnd &&
      other.text == text;

  @override
  int get hashCode =>
      Object.hash(sura, aya, page, lineStart, pageEnd, lineEnd, text);
}
