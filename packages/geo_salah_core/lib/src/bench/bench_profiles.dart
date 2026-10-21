import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';

/// The profiles the S05 bench knows (§13 S05, §15 D40).
///
/// Until S07 loads `profiles/engine/engine.default.yaml`, `engine.default`
/// is this stand-in: the rule *types* of §6.5 for the S05 events —
/// `sunrise: {type: horizon}`, `dhuhr: {type: transit}` (no
/// `offsetMinutes`), `maghrib: {type: horizon}` — with every value left at
/// the §6.2 [EventRule] defaults (ADR-003; no religious value is written
/// here, §0.2 rule 1). Its version `0000.0.0` is a sentinel no published
/// profile uses.
abstract final class BenchProfiles {
  /// `engine.default` as the S05 stand-in.
  static const PrayerProfile engineDefault = PrayerProfile(
    profileId: 'engine.default',
    version: '0000.0.0',
    rules: {
      PrayerEvent.sunrise: EventRule.horizon(),
      PrayerEvent.dhuhr: EventRule.transit(),
      PrayerEvent.maghrib: EventRule.horizon(),
    },
  );

  /// Every profile by id.
  static const Map<String, PrayerProfile> byId = {
    'engine.default': engineDefault,
  };
}
