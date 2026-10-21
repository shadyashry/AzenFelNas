import 'package:json_annotation/json_annotation.dart';

/// Package type (§9.5).
@JsonEnum(fieldRename: FieldRename.snake)
enum PackageTypeCode {
  /// `prayer_profiles`.
  prayerProfiles,

  /// `tzdata`.
  tzdata,

  /// `tz_polygons`.
  tzPolygons,

  /// `country_polygons`.
  countryPolygons,

  /// `gazetteer`.
  gazetteer,

  /// `hijri`.
  hijri,

  /// `athan_audio_manifest`.
  athanAudioManifest,
}
