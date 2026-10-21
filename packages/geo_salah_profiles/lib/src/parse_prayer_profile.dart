import 'package:dm_core_types/dm_core_types.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:geo_salah_profiles/src/profile_failure.dart';
import 'package:json_annotation/json_annotation.dart';

/// Parses one decoded `prayer_profile.v1` document (Appendix A) into a
/// validated [PrayerProfile] (§6.5, ADR-007, ADR-008).
///
/// The document is decoded by the engine's wire model, which rejects
/// unknown members and wrong shapes. It is mapped by [PrayerProfileMapper],
/// then checked against the rules the schema cannot express (§15 D52):
/// - **Governance** (Appendix A CI gate, §9.2): `APPROVED` needs both
///   approvals and a holdout report; `nearest` rounding of an entry event
///   needs `rounding` in the religious approval's scope.
/// - **Adjustments** (§9.2): every `|perEventMinutes|` within
///   `maxAbsMinutes`; Ramadan rules only for Imsak, Fajr and Isha (§6.4 ¶6).
/// - **Scope and dates:** `effectiveTo ≥ effectiveFrom`. `*` belongs to
///   `engine.default` alone, which is `ENGINE_DEFAULT` with scope `[*]`.
///   `adminAreas` and `polygonsRef` stay empty until V1.
/// - **Reference points** (ADR-006): `AUTHORITY_REFERENCE_POINT` needs at
///   most one point per scope country and at least one; `EXACT_COORDINATE`
///   has none.
/// - **Compatibility** (REQ-PKG-006): `minEngineSchema ≤
///   EngineVersion.profileSchema`.
///
/// Every failure is `ProfileFailure.invalid` naming the profile and the
/// rule. No value is chosen here: the checks only accept or refuse data
/// (§0.2 rule 1). Pure and deterministic.
final class ParsePrayerProfile {
  /// The use case.
  const new();

  static const Set<PrayerEvent> _ramadanEvents = {
    PrayerEvent.imsak,
    PrayerEvent.fajr,
    PrayerEvent.isha,
  };

  /// The profile [json] describes, or why it cannot be used.
  Result<PrayerProfile, ProfileFailure> call(Object? json) {
    final PrayerProfileDocument document;
    try {
      document = switch (json) {
        final Map<String, Object?> object => PrayerProfileDocument.fromJson(
          object,
        ),
        _ => throw const FormatException('a profile is a JSON object'),
      };
    } on CheckedFromJsonException catch (e) {
      return Result.err(ProfileFailure.invalid('not prayer_profile.v1: $e'));
    } on FormatException catch (e) {
      return Result.err(ProfileFailure.invalid(e.message));
    }
    final problem = _documentProblem(document);
    if (problem != null) {
      return Result.err(
        ProfileFailure.invalid('${document.profileId}: $problem'),
      );
    }
    return switch (PrayerProfileMapper.map(document)) {
      Err(:final failure) => Result.err(ProfileFailure.invalid(failure.detail)),
      Ok(value: final profile) => switch (_profileProblem(profile)) {
        final String problem => Result.err(
          ProfileFailure.invalid('${profile.profileId}: $problem'),
        ),
        null => Result.ok(profile),
      },
    };
  }

  /// The first rule [document] breaks that the domain model cannot show.
  static String? _documentProblem(PrayerProfileDocument document) {
    if (document.schemaVersion != 1) {
      return 'schemaVersion ${document.schemaVersion} is not 1';
    }
    final approvals = document.approvals;
    if (document.status == ProfileStatusCode.approved &&
        (approvals.religious == null ||
            approvals.accuracy == null ||
            document.evidence.holdoutReport == null)) {
      return 'APPROVED needs approvals.religious, approvals.accuracy and '
          'evidence.holdoutReport';
    }
    final nearestOnEntry = document.rounding.entries.any(
      (entry) =>
          entry.value == RoundingModeCode.nearest && entry.key != 'sunrise',
    );
    final roundingApproved =
        approvals.religious?.scope.contains('rounding') ?? false;
    if (nearestOnEntry && !roundingApproved) {
      return 'nearest rounding of an entry event needs "rounding" in '
          'approvals.religious.scope';
    }
    if (document.scope.adminAreas.isNotEmpty ||
        document.scope.polygonsRef != null) {
      return 'scope.adminAreas and scope.polygonsRef are [DEFERRED V1]';
    }
    if (document.compatibility.minEngineSchema > EngineVersion.profileSchema) {
      return 'needs engine schema ${document.compatibility.minEngineSchema}, '
          'this engine evaluates ${EngineVersion.profileSchema}';
    }
    return null;
  }

  /// The first rule [profile] breaks.
  static String? _profileProblem(PrayerProfile profile) {
    final effectiveTo = profile.effectiveTo;
    if (effectiveTo != null &&
        effectiveTo.epochDay < profile.effectiveFrom.epochDay) {
      return 'effectiveTo $effectiveTo is before effectiveFrom';
    }
    for (final MapEntry(key: event, value: minutes)
        in profile.perEventMinutes.entries) {
      if (minutes.abs() > profile.maxAbsMinutes) {
        return 'perEventMinutes.${event.name} $minutes exceeds maxAbsMinutes';
      }
    }
    for (final event in profile.ramadanRules.keys) {
      if (!_ramadanEvents.contains(event)) {
        return 'a Ramadan rule for ${event.name} (only imsak, fajr, isha)';
      }
    }
    return _scopeProblem(profile) ?? _referenceProblem(profile);
  }

  static String? _scopeProblem(PrayerProfile profile) {
    final isDefault = profile.profileId == 'engine.default';
    final everywhere = profile.countries.contains('*');
    if (isDefault !=
        (everywhere &&
            profile.countries.length == 1 &&
            profile.authorityType == AuthorityType.engineDefault)) {
      return 'scope * and ENGINE_DEFAULT belong to engine.default alone';
    }
    if (!isDefault && profile.authorityType == AuthorityType.engineDefault) {
      return 'ENGINE_DEFAULT belongs to engine.default alone';
    }
    if (profile.countries.isEmpty) return 'scope.countries is empty';
    if (profile.countries.toSet().length != profile.countries.length) {
      return 'scope.countries repeats a country';
    }
    return null;
  }

  static String? _referenceProblem(PrayerProfile profile) {
    final points = profile.referencePoints;
    switch (profile.referenceMode) {
      case ReferenceMode.exactCoordinate:
        return points.isEmpty ? null : 'EXACT_COORDINATE has referencePoints';
      case ReferenceMode.authorityReferencePoint:
        final areas = [for (final point in points) point.area];
        if (areas.isEmpty) return 'AUTHORITY_REFERENCE_POINT has no point';
        if (areas.toSet().length != areas.length) {
          return 'two referencePoints share an area';
        }
        for (final point in points) {
          if (!profile.countries.contains(point.area)) {
            return 'referencePoint area ${point.area} is not in scope';
          }
          if (!(point.lat >= -90 && point.lat <= 90) ||
              !(point.lon >= -180 && point.lon <= 180)) {
            return 'referencePoint ${point.area} is off the globe';
          }
        }
        return null;
    }
  }
}
