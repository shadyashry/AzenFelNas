import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:meta/meta.dart';

/// The surah the reader navigates within, and where the current page
/// stands in it (§15 D120, REQ-QRN-024). Its pages run from its header
/// page [first] to the page of its last verse [last]; a page may also hold
/// the end of the surah before it or the start of the one after it.
@immutable
final class SurahScope {
  /// The scope of [sura] on [page].
  const new({
    required this.sura,
    required this.first,
    required this.last,
    required this.page,
  });

  /// The surah's index entry.
  final SuraEntry sura;

  /// Its first page.
  final int first;

  /// Its last page.
  final int last;

  /// The current page, within [first]..[last].
  final int page;

  /// How many pages the surah is on.
  int get count => last - first + 1;

  /// The current page's place among them, 1..[count].
  int get position => page - first + 1;

  /// Whether the surah is on one page only.
  bool get single => count == 1;

  /// Whether the current page is its first.
  bool get atStart => page == first;

  /// Whether the current page is its last.
  bool get atEnd => page == last;

  /// Whether [p] is one of its pages.
  bool contains(int p) => p >= first && p <= last;

  /// Picks the scope for [page]: the surah the reader chose ([selected])
  /// while the page is one of its pages, so a page shared with the next or
  /// the previous surah stays in the chosen one; otherwise the surah whose
  /// header is the last at or before the page. [pagesOf] gives a surah's
  /// pages, `null` while they are not known. `null` when nothing is known.
  static SurahScope? pick({
    required int page,
    required int? selected,
    required List<SuraEntry> suras,
    required ({int first, int last})? Function(int sura) pagesOf,
  }) {
    SurahScope? scopeOf(SuraEntry? entry) {
      if (entry == null) return null;
      final pages = pagesOf(entry.number);
      if (pages == null || page < pages.first || page > pages.last) {
        return null;
      }
      return SurahScope(
        sura: entry,
        first: pages.first,
        last: pages.last,
        page: page,
      );
    }

    SuraEntry? entry(int number) {
      for (final s in suras) {
        if (s.number == number) return s;
      }
      return null;
    }

    SuraEntry? onPage;
    for (final s in suras) {
      if (s.startPage <= page) onPage = s;
    }
    final chosen = selected == null ? null : scopeOf(entry(selected));
    return chosen ?? scopeOf(onPage);
  }
}
