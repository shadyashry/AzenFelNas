import 'package:dm_core_types/dm_core_types.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/authority_type.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/high_latitude_method.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/profile_status.dart';
import 'package:geo_salah_core/src/model/reference_mode.dart';
import 'package:geo_salah_core/src/model/reference_point.dart';
import 'package:geo_salah_core/src/model/rounding_mode.dart';

part 'prayer_profile.freezed.dart';

/// The rule policy a day is calculated with (§6.2, ADR-007): data, never
/// code (§0.2 rule 1).
///
/// The full §6.2 shape since S07. It is built from a `prayer_profile.v1`
/// document by `PrayerProfileMapper` and validated by `geo_salah_profiles`.
/// The engine reads the rules, the elevation policy, the reference mode and
/// points, the adjustments, the rounding modes and the governance standing.
/// The high-latitude chain and the Ramadan rules are read from S08; the
/// validity dates and scope by the resolver. The rounding mode has no code
/// default (ADR-005, §15 D4).
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

    /// First day the profile applies.
    required CivilDate effectiveFrom,

    /// Countries in scope (ISO 3166-1 alpha-2), or `*` for every country
    /// (`engine.default` only).
    required List<String> countries,

    /// The authority's name (Appendix A `authority.name`).
    required String authorityName,

    /// Who stands behind the profile (Appendix A `authority.type`).
    required AuthorityType authorityType,

    /// Where the times are calculated (ADR-006).
    required ReferenceMode referenceMode,

    /// The rule of each calculated event.
    required Map<PrayerEvent, EventRule> rules,

    /// The ordered high-latitude chain (§6.4 ¶7).
    required List<HighLatitudeMethod> highLatitudeChain,

    /// Rounding of every event without an override (Appendix A
    /// `rounding.default`).
    required RoundingMode roundingDefault,

    /// Largest allowed `|perEventMinutes|` (Appendix A
    /// `adjustments.maxAbsMinutes`); an offset beyond it is
    /// `EngineFailure.invalidProfile`.
    required int maxAbsMinutes,

    /// Whether `approvals.religious` is present (ADR-008).
    required bool hasReligiousApproval,

    /// Oldest engine schema that can evaluate the profile (Appendix A
    /// `compatibility.minEngineSchema`).
    required int minEngineSchema,

    /// Last day the profile applies, or `null` when open-ended.
    CivilDate? effectiveTo,

    /// The authority's calculation points, per area (ADR-006). The resolver
    /// narrows them to the observer's area, so the engine sees one.
    @Default([]) List<ReferencePoint> referencePoints,

    /// Per-event rounding overrides (Appendix A `rounding.<event>`).
    @Default({}) Map<PrayerEvent, RoundingMode> roundingOverrides,

    /// Additive whole-minute offsets per event (Appendix A
    /// `adjustments.perEventMinutes`, §6.4 ¶8).
    @Default({}) Map<PrayerEvent, int> perEventMinutes,

    /// Rules that replace an event's rule during Ramadan (Appendix A
    /// `adjustments.ramadan`, §6.4 ¶6; applied from S08).
    @Default({}) Map<PrayerEvent, EventRule> ramadanRules,

    /// How elevation enters horizon events.
    @Default(HorizonElevationPolicy.none)
    HorizonElevationPolicy elevationPolicy,

    /// The benchmark report an `Authority aligned` label cites (Appendix A
    /// `evidence.benchmarkReportId`).
    String? benchmarkReportId,
  }) = _PrayerProfile;
}
