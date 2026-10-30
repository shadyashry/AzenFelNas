import 'package:dm_contracts/src/quran/quran_source.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'quran_edition.freezed.dart';
part 'quran_edition.g.dart';

/// The Mushaf edition a Quran package carries.
@freezed
abstract class QuranEdition with _$QuranEdition {
  /// Creates a [QuranEdition].
  const factory({
    /// The riwayah; `hafs` only in v1.
    required String riwayah,

    /// The publisher of the Mushaf.
    required String publisher,

    /// The digital edition, e.g. `1441`.
    required String printEdition,

    /// Pages in the Mushaf.
    required int pageCount,

    /// Surahs.
    required int suraCount,

    /// Verses.
    required int verseCount,

    /// Every source with its licence.
    required List<QuranSource> sources,
  }) = _QuranEdition;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$QuranEditionFromJson(json);
}
