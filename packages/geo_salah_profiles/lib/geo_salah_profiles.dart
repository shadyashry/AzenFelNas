/// Parses and validates prayer profiles and resolves place + date to a
/// profile (DESIGN.md §6.5, ADR-007, ADR-008).
///
/// Pure Dart set (DESIGN.md §0.2 rule 2): imports nothing from Flutter or the
/// platform. Since S07 it holds the use cases over profile **data**:
/// `ParsePrayerProfile` (wire model and mapping from `geo_salah_core`, plus
/// the rules the schema cannot express), `ValidateProfileSet` (non-overlap),
/// `CheckProfileChannel` (`DRAFT_UNVERIFIED` and `CANDIDATE` on dev/lab only)
/// and `ResolveProfile` (country + day → profile, `engine.default` as the
/// fallback). The `prayer_profile.v1` wire model moved to `geo_salah_core`
/// in S07 (§15 D51).
library;

export 'package:geo_salah_profiles/src/check_profile_channel.dart';
export 'package:geo_salah_profiles/src/parse_prayer_profile.dart';
export 'package:geo_salah_profiles/src/parse_profile_set_payload.dart';
export 'package:geo_salah_profiles/src/profile_failure.dart';
export 'package:geo_salah_profiles/src/profile_set.dart';
export 'package:geo_salah_profiles/src/release_channel.dart';
export 'package:geo_salah_profiles/src/resolve_profile.dart';
export 'package:geo_salah_profiles/src/validate_profile_set.dart';
