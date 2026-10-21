import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';

part 'prayer_profile.freezed.dart';

/// The rule policy a day is calculated with (§6.2, ADR-007): data, never
/// code (§0.2 rule 1).
///
/// S05 carries the fields its events need: identity, the per-event rules
/// and the elevation policy. S07 completes the §6.2 shape (status, scope,
/// authority, high-latitude chain, rounding, adjustments, Ramadan rules)
/// when the `geo_salah_profiles` loader arrives. The engine calculates the
/// events present in [rules], in [PrayerEvent] order.
@freezed
abstract class PrayerProfile with _$PrayerProfile {
  /// Creates a [PrayerProfile].
  const factory({
    /// `<iso2>.<authority>.<variant>` or `engine.default` (Appendix A).
    required String profileId,

    /// Profile version, `YYYY.M.N` (Appendix A).
    required String version,

    /// The rule of each calculated event.
    required Map<PrayerEvent, EventRule> rules,

    /// How elevation enters horizon events.
    @Default(HorizonElevationPolicy.none)
    HorizonElevationPolicy elevationPolicy,
  }) = _PrayerProfile;
}
