import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/authority_type.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/profile_status.dart';
import 'package:geo_salah_core/src/model/rounding_mode.dart';

part 'prayer_profile.freezed.dart';

/// The rule policy a day is calculated with (§6.2, ADR-007): data, never
/// code (§0.2 rule 1).
///
/// S06 carries the fields the engine reads: identity, governance standing
/// (for the confidence mapping, REQ-DOM-050), the per-event rules, the
/// elevation policy, the additive adjustments and the rounding modes. S07
/// completes the §6.2 shape (validity dates, scope, authority name,
/// reference mode, high-latitude chain, Ramadan rules) with the
/// `geo_salah_profiles` loader. The engine calculates the events present in
/// [rules]; the rounding mode has no code default (ADR-005, §15 D4).
@freezed
abstract class PrayerProfile with _$PrayerProfile {
  /// Creates a [PrayerProfile].
  const factory({
    /// `<iso2>.<authority>.<variant>` or `engine.default` (Appendix A).
    required String profileId,

    /// Profile version, `YYYY.M.N` (Appendix A).
    required String version,

    /// Governance status (Appendix A `status`).
    required ProfileStatus status,

    /// Who stands behind the profile (Appendix A `authority.type`).
    required AuthorityType authorityType,

    /// The rule of each calculated event.
    required Map<PrayerEvent, EventRule> rules,

    /// Rounding of every event without an override (Appendix A
    /// `rounding.default`).
    required RoundingMode roundingDefault,

    /// Per-event rounding overrides (Appendix A `rounding.<event>`).
    @Default({}) Map<PrayerEvent, RoundingMode> roundingOverrides,

    /// Additive whole-minute offsets per event (Appendix A
    /// `adjustments.perEventMinutes`, §6.4 ¶8).
    @Default({}) Map<PrayerEvent, int> perEventMinutes,

    /// Largest allowed `|perEventMinutes|` (Appendix A
    /// `adjustments.maxAbsMinutes`); an offset beyond it is
    /// `EngineFailure.invalidProfile`.
    @Default(0) int maxAbsMinutes,

    /// How elevation enters horizon events.
    @Default(HorizonElevationPolicy.none)
    HorizonElevationPolicy elevationPolicy,

    /// The benchmark report an `Authority aligned` label cites (Appendix A
    /// `evidence.benchmarkReportId`).
    String? benchmarkReportId,
  }) = _PrayerProfile;
}
