import 'package:daily_muslim/features/quran/domain/highlight_color.dart';
import 'package:meta/meta.dart';

/// A highlight of one whole verse (§15 D114): the verse, not an area, is
/// what is kept, so it is drawn over the lines the package places that
/// verse on and listed by its reference. Stored against a page layout.
@immutable
final class AyahHighlight {
  /// The highlight of verse [aya] of surah [sura].
  const new({
    required this.layoutId,
    required this.sura,
    required this.aya,
    required this.color,
    required this.createdUtcMs,
    required this.updatedUtcMs,
  });

  /// The page layout.
  final String layoutId;

  /// Surah.
  final int sura;

  /// Verse.
  final int aya;

  /// Colour.
  final HighlightColor color;

  /// Created, UTC epoch ms.
  final int createdUtcMs;

  /// Last changed, UTC epoch ms.
  final int updatedUtcMs;

  @override
  bool operator ==(Object other) =>
      other is AyahHighlight &&
      other.layoutId == layoutId &&
      other.sura == sura &&
      other.aya == aya &&
      other.color == color &&
      other.createdUtcMs == createdUtcMs &&
      other.updatedUtcMs == updatedUtcMs;

  @override
  int get hashCode =>
      Object.hash(layoutId, sura, aya, color, createdUtcMs, updatedUtcMs);
}

/// Verse highlights of one page layout, stored apart from the package
/// (§15 D114): at most one per verse.
abstract interface class AyahHighlightStore {
  /// The verse highlights of [layoutId] in Mushaf order; emits on every
  /// change.
  Stream<List<AyahHighlight>> watchAyahHighlights(String layoutId);

  /// Highlights verse [aya] of [sura] in [color], or recolours it.
  Future<void> setAyahHighlight(
    String layoutId,
    int sura,
    int aya,
    HighlightColor color, {
    required int nowUtcMs,
  });

  /// Removes the highlight of verse [aya] of [sura], if any.
  Future<void> removeAyahHighlight(String layoutId, int sura, int aya);
}
