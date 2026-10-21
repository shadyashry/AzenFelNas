import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/src/model/authority_type.dart';
import 'package:geo_salah_core/src/model/engine_failure.dart';
import 'package:geo_salah_core/src/model/event_rule.dart';
import 'package:geo_salah_core/src/model/high_latitude_method.dart';
import 'package:geo_salah_core/src/model/horizon_elevation_policy.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_profile.dart';
import 'package:geo_salah_core/src/model/profile_status.dart';
import 'package:geo_salah_core/src/model/reference_mode.dart';
import 'package:geo_salah_core/src/model/reference_point.dart';
import 'package:geo_salah_core/src/model/rounding_mode.dart';
import 'package:geo_salah_core/src/wire/high_latitude_method_document.dart';
import 'package:geo_salah_core/src/wire/profile/authority_type_code.dart';
import 'package:geo_salah_core/src/wire/profile/elevation_policy_code.dart';
import 'package:geo_salah_core/src/wire/profile/interval_base_code.dart';
import 'package:geo_salah_core/src/wire/profile/prayer_profile_document.dart';
import 'package:geo_salah_core/src/wire/profile/profile_status_code.dart';
import 'package:geo_salah_core/src/wire/profile/reference_mode_code.dart';
import 'package:geo_salah_core/src/wire/profile/rounding_mode_code.dart';
import 'package:geo_salah_core/src/wire/profile/rule_document.dart';
import 'package:geo_salah_core/src/wire/profile/rules_document.dart';

/// Maps a `prayer_profile.v1` document (Appendix A) to the engine's
/// [PrayerProfile] (§6.2): one mapping for the app's loader
/// (`geo_salah_profiles`) and the engine bench (§15 D51).
///
/// It is a translation, not a policy: every value comes from the document
/// (§0.2 rule 1). An absent optional parameter keeps its §6.2 meaning (no
/// transit offset, the ADR-003 horizon constants). It fails only where the
/// document's free-form members do not name what they must:
/// - a `rounding`, `perEventMinutes` or `ramadan` key that is not an event
///   (or `default`);
/// - a date that is not `YYYY-MM-DD`;
/// - a missing `rounding.default`.
///
/// Those are `EngineFailure.invalidProfile`. The religious and governance
/// checks belong to the validator in `geo_salah_profiles`. Pure and
/// deterministic.
abstract final class PrayerProfileMapper {
  /// The profile [document] describes.
  static Result<PrayerProfile, EngineFailure> map(
    PrayerProfileDocument document,
  ) {
    try {
      return Result.ok(_map(document));
    } on FormatException catch (e) {
      return Result.err(
        EngineFailure.invalidProfile('${document.profileId}: ${e.message}'),
      );
    }
  }

  static PrayerProfile _map(PrayerProfileDocument document) {
    final roundingDefault = switch (document.rounding['default']) {
      final RoundingModeCode code => _rounding(code),
      null => throw const FormatException('rounding.default is missing'),
    };
    return PrayerProfile(
      profileId: document.profileId,
      version: document.version,
      status: _status(document.status),
      effectiveFrom: _date(document.effectiveFrom, 'effectiveFrom'),
      effectiveTo: switch (document.effectiveTo) {
        final String text => _date(text, 'effectiveTo'),
        null => null,
      },
      countries: List.unmodifiable(document.scope.countries),
      authorityName: document.authority.name,
      authorityType: _authority(document.authority.type),
      referenceMode: _referenceMode(document.referenceMode),
      referencePoints: [
        for (final point in document.referencePoints)
          ReferencePoint(area: point.area, lat: point.lat, lon: point.lon),
      ],
      rules: _rules(document.rules),
      highLatitudeChain: [
        for (final method in document.highLatitude.chain) _method(method),
      ],
      roundingDefault: roundingDefault,
      roundingOverrides: {
        for (final MapEntry(:key, :value) in document.rounding.entries)
          if (key != 'default') _event(key, 'rounding'): _rounding(value),
      },
      perEventMinutes: {
        for (final MapEntry(:key, :value)
            in document.adjustments.perEventMinutes.entries)
          _event(key, 'adjustments.perEventMinutes'): value,
      },
      maxAbsMinutes: document.adjustments.maxAbsMinutes,
      ramadanRules: {
        for (final MapEntry(:key, :value)
            in document.adjustments.ramadan.entries)
          _event(key, 'adjustments.ramadan'): _rule(value),
      },
      elevationPolicy: _elevationPolicy(document.horizon.elevationPolicy),
      benchmarkReportId: document.evidence.benchmarkReportId,
      hasReligiousApproval: document.approvals.religious != null,
      minEngineSchema: document.compatibility.minEngineSchema,
    );
  }

  static Map<PrayerEvent, EventRule> _rules(RulesDocument rules) => {
    if (rules.imsak case final RuleDocument imsak)
      PrayerEvent.imsak: _rule(imsak),
    PrayerEvent.fajr: _rule(rules.fajr),
    PrayerEvent.sunrise: _rule(rules.sunrise),
    PrayerEvent.dhuhr: _rule(rules.dhuhr),
    PrayerEvent.asr: _rule(rules.asr),
    PrayerEvent.maghrib: _rule(rules.maghrib),
    PrayerEvent.isha: _rule(rules.isha),
  };

  static EventRule _rule(RuleDocument rule) => switch (rule) {
    SolarAltitudeRuleDocument(:final degrees) => EventRule.solarAltitude(
      degrees: degrees,
    ),
    TransitRuleDocument(offsetMinutes: null) => const EventRule.transit(),
    TransitRuleDocument(offsetMinutes: final int minutes) => EventRule.transit(
      offset: Duration(minutes: minutes),
    ),
    ShadowFactorRuleDocument(:final k) => EventRule.shadowFactor(k: k),
    HorizonRuleDocument(:final refractionArcmin, :final semidiameterArcmin) =>
      _horizon(refractionArcmin, semidiameterArcmin),
    IntervalAfterRuleDocument(:final base, :final minutes) =>
      EventRule.intervalAfter(
        base: _base(base),
        duration: Duration(minutes: minutes),
      ),
    IntervalBeforeRuleDocument(:final base, :final minutes) =>
      EventRule.intervalBefore(
        base: _base(base),
        duration: Duration(minutes: minutes),
      ),
  };

  /// An absent member keeps the §6.2 [HorizonRule] default (ADR-003).
  static EventRule _horizon(double? refraction, double? semidiameter) {
    const defaults = HorizonRule();
    return EventRule.horizon(
      refractionArcmin: refraction ?? defaults.refractionArcmin,
      semidiameterArcmin: semidiameter ?? defaults.semidiameterArcmin,
    );
  }

  static PrayerEvent _base(IntervalBaseCode base) => switch (base) {
    IntervalBaseCode.maghrib => PrayerEvent.maghrib,
    IntervalBaseCode.fajr => PrayerEvent.fajr,
  };

  static HighLatitudeMethod _method(
    HighLatitudeMethodDocument method,
  ) => switch (method) {
    AnglePortionMethodDocument() => const HighLatitudeMethod.anglePortion(),
    MiddleOfNightMethodDocument() => const HighLatitudeMethod.middleOfNight(),
    SeventhOfNightMethodDocument() => const HighLatitudeMethod.seventhOfNight(),
    NearestLatitudeMethodDocument(:final latDeg) =>
      HighLatitudeMethod.nearestLatitude(latDeg: latDeg),
    NearestValidDayMethodDocument(:final maxDays) =>
      HighLatitudeMethod.nearestValidDay(maxDays: maxDays),
  };

  static PrayerEvent _event(String name, String member) =>
      PrayerEvent.values.asNameMap()[name] ??
      (throw FormatException('$member.$name is not an event'));

  static CivilDate _date(String text, String member) =>
      CivilDate.tryParse(text) ??
      (throw FormatException('$member $text is not a date'));

  static ProfileStatus _status(ProfileStatusCode code) => switch (code) {
    ProfileStatusCode.draftUnverified => ProfileStatus.draftUnverified,
    ProfileStatusCode.candidate => ProfileStatus.candidate,
    ProfileStatusCode.approved => ProfileStatus.approved,
    ProfileStatusCode.retired => ProfileStatus.retired,
  };

  static AuthorityType _authority(AuthorityTypeCode code) => switch (code) {
    AuthorityTypeCode.government => AuthorityType.government,
    AuthorityTypeCode.recognizedBody => AuthorityType.recognizedBody,
    AuthorityTypeCode.communityConvention => AuthorityType.communityConvention,
    AuthorityTypeCode.engineDefault => AuthorityType.engineDefault,
  };

  static ReferenceMode _referenceMode(ReferenceModeCode code) => switch (code) {
    ReferenceModeCode.exactCoordinate => ReferenceMode.exactCoordinate,
    ReferenceModeCode.authorityReferencePoint =>
      ReferenceMode.authorityReferencePoint,
  };

  static RoundingMode _rounding(RoundingModeCode code) => switch (code) {
    RoundingModeCode.ceil => RoundingMode.ceil,
    RoundingModeCode.floor => RoundingMode.floor,
    RoundingModeCode.nearest => RoundingMode.nearest,
  };

  static HorizonElevationPolicy _elevationPolicy(ElevationPolicyCode code) =>
      switch (code) {
        ElevationPolicyCode.none => HorizonElevationPolicy.none,
        ElevationPolicyCode.aboveLocalTerrain =>
          HorizonElevationPolicy.aboveLocalTerrain,
        ElevationPolicyCode.authorityTable =>
          HorizonElevationPolicy.authorityTable,
      };
}
