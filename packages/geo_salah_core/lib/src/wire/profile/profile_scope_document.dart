import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile_scope_document.freezed.dart';
part 'profile_scope_document.g.dart';

/// Geographic scope of a profile (ADR-007).
@freezed
abstract class ProfileScopeDocument with _$ProfileScopeDocument {
  /// Creates a [ProfileScopeDocument].
  const factory({
    /// ISO 3166-1 alpha-2 codes, or `*` for all.
    required List<String> countries,

    /// Polygon set reference (deferred to V1); always written, `null` when
    /// unset.
    @JsonKey(includeIfNull: true) required String? polygonsRef,

    /// ISO 3166-2 codes (deferred to V1).
    @Default(<String>[]) List<String> adminAreas,
  }) = _ProfileScopeDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$ProfileScopeDocumentFromJson(json);
}
