import 'package:meta/meta.dart';

/// One surah in the index: its header as printed in the source, its first
/// page and its verse count (all from the KFGQPC text, §15 D107).
@immutable
final class SuraEntry {
  /// The entry.
  const new({
    required this.number,
    required this.header,
    required this.startPage,
    required this.verseCount,
  });

  /// 1..114.
  final int number;

  /// The header line exactly as in the source, e.g. `سُورَةُ البَقَرَةِ`.
  final String header;

  /// Page of the header.
  final int startPage;

  /// Verses.
  final int verseCount;

  @override
  bool operator ==(Object other) =>
      other is SuraEntry &&
      other.number == number &&
      other.header == header &&
      other.startPage == startPage &&
      other.verseCount == verseCount;

  @override
  int get hashCode => Object.hash(number, header, startPage, verseCount);
}

/// One juz: where it starts.
@immutable
final class JuzEntry {
  /// The entry.
  const new({
    required this.number,
    required this.sura,
    required this.aya,
    required this.page,
  });

  /// 1..30.
  final int number;

  /// Surah of the first verse.
  final int sura;

  /// The first verse.
  final int aya;

  /// Page of the first verse.
  final int page;

  @override
  bool operator ==(Object other) =>
      other is JuzEntry &&
      other.number == number &&
      other.sura == sura &&
      other.aya == aya &&
      other.page == page;

  @override
  int get hashCode => Object.hash(number, sura, aya, page);
}

/// A verse found by search: its place, its text as published, and the
/// range of that text the query matched.
@immutable
final class VerseHit {
  /// The hit.
  const new({
    required this.sura,
    required this.aya,
    required this.page,
    required this.text,
    required this.matchStart,
    required this.matchEnd,
  });

  /// Surah.
  final int sura;

  /// Verse.
  final int aya;

  /// Page of the verse.
  final int page;

  /// The verse text from the KFGQPC source, unchanged.
  final String text;

  /// Start of the matched range in [text].
  final int matchStart;

  /// End (exclusive) of the matched range in [text].
  final int matchEnd;

  @override
  bool operator ==(Object other) =>
      other is VerseHit &&
      other.sura == sura &&
      other.aya == aya &&
      other.page == page &&
      other.text == text &&
      other.matchStart == matchStart &&
      other.matchEnd == matchEnd;

  @override
  int get hashCode => Object.hash(sura, aya, page, text, matchStart, matchEnd);
}

/// The result of one search: the first hits and how many verses matched.
@immutable
final class SearchResults {
  /// [hits] (at most the requested limit) of [total] matching verses.
  const new({required this.hits, required this.total});

  /// The hits in Mushaf order.
  final List<VerseHit> hits;

  /// Every matching verse.
  final int total;
}
