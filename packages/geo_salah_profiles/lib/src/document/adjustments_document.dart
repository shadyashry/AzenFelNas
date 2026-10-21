import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_profiles/src/document/rule_document.dart';

part 'adjustments_document.freezed.dart';
part 'adjustments_document.g.dart';

/// Additive adjustments and Ramadan rule replacements (§6.4 ¶6, ¶8).
@freezed
abstract class AdjustmentsDocument with _$AdjustmentsDocument {
  /// Creates a [AdjustmentsDocument].
  const factory({
    /// Largest allowed absolute offset.
    required int maxAbsMinutes,

    /// Minute offset per event name.
    @Default(<String, int>{}) Map<String, int> perEventMinutes,

    /// Replacement rule per event name during Ramadan.
    @Default(<String, RuleDocument>{}) Map<String, RuleDocument> ramadan,
  }) = _AdjustmentsDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$AdjustmentsDocumentFromJson(json);
}
