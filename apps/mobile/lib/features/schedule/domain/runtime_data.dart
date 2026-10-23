import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_profiles/geo_salah_profiles.dart';
import 'package:meta/meta.dart';

/// The active packages a calculation reads, parsed once per process
/// (`LoadRuntimeData`, §7.4): the pinned TZDB (REQ-TIME-020), both polygon
/// indexes and the profile set allowed on this build's channel.
@immutable
final class RuntimeData {
  /// The parsed packages.
  const new({
    required this.tzdb,
    required this.zones,
    required this.countries,
    required this.profiles,
  });

  /// The app's pinned TZDB, never the OS one.
  final PinnedTzDatabase tzdb;

  /// The `tz_polygons` index.
  final PolygonIndex zones;

  /// The `country_polygons` index.
  final PolygonIndex countries;

  /// The validated profiles that may load on this channel (Appendix E).
  final ProfileSet profiles;
}
