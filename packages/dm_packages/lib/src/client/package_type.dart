/// The MVP package types (§7.4). [wire] is the `<packageType>` part of a
/// target name in `targets.json` and the `type` key of `active_packages`.
enum PackageType {
  /// `prayer_profiles` (§15 D60).
  prayerProfiles('prayer_profiles'),

  /// `tzdata` (§15 D66, D69).
  tzdata('tzdata'),

  /// `tz_polygons` (§15 D70).
  tzPolygons('tz_polygons'),

  /// `country_polygons` (§15 D70).
  countryPolygons('country_polygons'),

  /// `gazetteer` (§15 D72).
  gazetteer('gazetteer'),

  /// `hijri`.
  hijri('hijri'),

  /// `athan_audio_manifest`.
  athanAudioManifest('athan_audio_manifest');

  new(this.wire);

  /// The wire name.
  final String wire;

  /// The type named [wire]; null for a type this build does not know, which
  /// the client ignores.
  static PackageType? fromWire(String wire) {
    for (final type in values) {
      if (type.wire == wire) return type;
    }
    return null;
  }
}
