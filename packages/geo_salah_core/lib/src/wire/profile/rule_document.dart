import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/wire/profile/interval_base_code.dart';

part 'rule_document.freezed.dart';
part 'rule_document.g.dart';

/// Wire form of an `EventRule` (§6.2, Appendix A `$defs/rule`),
/// discriminated by `type`. Optional parameters are absent when the profile
/// leaves them unset: this type defines no rule values (§0.2 rule 1).
@Freezed(unionKey: 'type')
sealed class RuleDocument with _$RuleDocument {
  /// `solarAltitude`: geometric solar altitude of −[degrees].
  const factory solarAltitude({required double degrees}) =
      SolarAltitudeRuleDocument;

  /// `transit`: solar transit plus [offsetMinutes].
  const factory transit({
    @JsonKey(includeIfNull: false) int? offsetMinutes,
  }) = TransitRuleDocument;

  /// `shadowFactor`: Asr with shadow factor [k].
  const factory shadowFactor({required int k}) = ShadowFactorRuleDocument;

  /// `horizon`: sunrise/sunset with optional refraction and semidiameter.
  const factory horizon({
    @JsonKey(includeIfNull: false) double? refractionArcmin,
    @JsonKey(includeIfNull: false) double? semidiameterArcmin,
  }) = HorizonRuleDocument;

  /// `intervalAfter`: [minutes] after [base].
  const factory intervalAfter({
    required IntervalBaseCode base,
    required int minutes,
  }) = IntervalAfterRuleDocument;

  /// `intervalBefore`: [minutes] before [base].
  const factory intervalBefore({
    required IntervalBaseCode base,
    required int minutes,
  }) = IntervalBeforeRuleDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$RuleDocumentFromJson(json);
}
