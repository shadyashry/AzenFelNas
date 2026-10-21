import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// A set of prayer profiles that passed `ValidateProfileSet` (ADR-007): no
/// repeated `profileId@version`, no two profiles covering one country on one
/// day, and an `engine.default` to fall back on. Only the validator creates
/// one. Immutable.
@immutable
final class ProfileSet {
  /// Wraps [profiles]; for `ValidateProfileSet` only.
  @internal
  const new validated(this.profiles);

  /// The profiles, in the order they were given.
  final List<PrayerProfile> profiles;
}
