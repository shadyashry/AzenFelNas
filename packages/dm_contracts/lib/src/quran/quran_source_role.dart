import 'package:json_annotation/json_annotation.dart';

/// What a source of the Quran package supplies (§15 D106).
@JsonEnum()
enum QuranSourceRole {
  /// The page images (the KFGQPC digital Mushaf).
  pages,

  /// The verse text, page and line mapping, and the font.
  text,

  /// The juz boundaries.
  juz,
}
