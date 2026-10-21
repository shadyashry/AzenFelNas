import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/wire/profile/rule_document.dart';

part 'rules_document.freezed.dart';
part 'rules_document.g.dart';

/// Rule per event. [imsak] is always written and `null` when the profile has
/// none.
@freezed
abstract class RulesDocument with _$RulesDocument {
  /// Creates a [RulesDocument].
  const factory({
    /// Imsak rule, or `null`.
    @JsonKey(includeIfNull: true) required RuleDocument? imsak,

    /// Fajr rule.
    required RuleDocument fajr,

    /// Sunrise rule.
    required RuleDocument sunrise,

    /// Dhuhr rule.
    required RuleDocument dhuhr,

    /// Asr rule.
    required RuleDocument asr,

    /// Maghrib rule.
    required RuleDocument maghrib,

    /// Isha rule.
    required RuleDocument isha,
  }) = _RulesDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$RulesDocumentFromJson(json);
}
