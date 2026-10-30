import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:meta/meta.dart';

/// A surah as it appears inside one juz: from [aya] (1 when the surah
/// starts in the juz, else the juz's first verse) on [page].
@immutable
final class JuzSurah {
  /// The entry.
  const new({required this.sura, required this.aya, required this.page});

  /// The surah.
  final SuraEntry sura;

  /// Its first verse inside the juz.
  final int aya;

  /// The page of that verse.
  final int page;

  @override
  bool operator ==(Object other) =>
      other is JuzSurah &&
      other.sura == sura &&
      other.aya == aya &&
      other.page == page;

  @override
  int get hashCode => Object.hash(sura, aya, page);
}

/// The surahs of every juz, in Mushaf order (§15 D111). A juz holds the
/// surah its first verse is in, then every surah that starts before the
/// next juz does; a surah that the next juz starts inside at verse 1 is
/// left to that juz. Built from the package's `juz` and `sura` tables only.
List<(JuzEntry, List<JuzSurah>)> juzContents(
  List<JuzEntry> juz,
  List<SuraEntry> suras,
) {
  final byNumber = {for (final s in suras) s.number: s};
  return [
    for (var i = 0; i < juz.length; i++)
      (
        juz[i],
        [
          for (
            var n = juz[i].sura;
            n <= _lastSura(i + 1 < juz.length ? juz[i + 1] : null, suras);
            n++
          )
            if (byNumber[n] case final sura?)
              if (n == juz[i].sura && juz[i].aya > 1)
                JuzSurah(sura: sura, aya: juz[i].aya, page: juz[i].page)
              else
                JuzSurah(sura: sura, aya: 1, page: sura.startPage),
        ],
      ),
  ];
}

/// The last surah before [next] starts; the last surah of all at the end.
int _lastSura(JuzEntry? next, List<SuraEntry> suras) => switch (next) {
  null => suras.isEmpty ? 0 : suras.last.number,
  JuzEntry(:final sura, aya: 1) => sura - 1,
  JuzEntry(:final sura) => sura,
};
