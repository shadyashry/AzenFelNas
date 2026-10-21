import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/wire/profile/adjustments_document.dart';
import 'package:geo_salah_core/src/wire/profile/approvals_document.dart';
import 'package:geo_salah_core/src/wire/profile/authority_document.dart';
import 'package:geo_salah_core/src/wire/profile/compatibility_document.dart';
import 'package:geo_salah_core/src/wire/profile/evidence_document.dart';
import 'package:geo_salah_core/src/wire/profile/high_latitude_document.dart';
import 'package:geo_salah_core/src/wire/profile/horizon_document.dart';
import 'package:geo_salah_core/src/wire/profile/profile_scope_document.dart';
import 'package:geo_salah_core/src/wire/profile/profile_status_code.dart';
import 'package:geo_salah_core/src/wire/profile/reference_mode_code.dart';
import 'package:geo_salah_core/src/wire/profile/reference_point_document.dart';
import 'package:geo_salah_core/src/wire/profile/rounding_mode_code.dart';
import 'package:geo_salah_core/src/wire/profile/rules_document.dart';

part 'prayer_profile_document.freezed.dart';
part 'prayer_profile_document.g.dart';

/// Wire form of `prayer_profile.v1` (Appendix A, ADR-007). Parsing into the
/// engine's `PrayerProfile` and validation arrive in S07. Holds data only: no
/// rule value is defined in code (§0.2 rule 1).
@freezed
abstract class PrayerProfileDocument with _$PrayerProfileDocument {
  /// Creates a [PrayerProfileDocument].
  const factory({
    /// `<iso2>.<authority>.<variant>` or `engine.default`.
    required String profileId,

    /// Schema version; 1.
    required int schemaVersion,

    /// Profile version `YYYY.M.N`.
    required String version,

    /// Lifecycle status.
    required ProfileStatusCode status,

    /// First day the profile applies, `YYYY-MM-DD`.
    required String effectiveFrom,

    /// Last day, or `null`; always written.
    @JsonKey(includeIfNull: true) required String? effectiveTo,

    /// Geographic scope.
    required ProfileScopeDocument scope,

    /// Authority.
    required AuthorityDocument authority,

    /// Reference mode.
    required ReferenceModeCode referenceMode,

    /// Reference points.
    required List<ReferencePointDocument> referencePoints,

    /// Rule per event.
    required RulesDocument rules,

    /// Horizon settings.
    required HorizonDocument horizon,

    /// High-latitude chain.
    required HighLatitudeDocument highLatitude,

    /// `default` plus per-event overrides.
    required Map<String, RoundingModeCode> rounding,

    /// Adjustments.
    required AdjustmentsDocument adjustments,

    /// Evidence.
    required EvidenceDocument evidence,

    /// Approvals.
    required ApprovalsDocument approvals,

    /// Compatibility.
    required CompatibilityDocument compatibility,
  }) = _PrayerProfileDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$PrayerProfileDocumentFromJson(json);
}
