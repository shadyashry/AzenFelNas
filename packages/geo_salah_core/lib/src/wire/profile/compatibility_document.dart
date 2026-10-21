import 'package:freezed_annotation/freezed_annotation.dart';

part 'compatibility_document.freezed.dart';
part 'compatibility_document.g.dart';

/// Minimum engine schema and app version.
@freezed
abstract class CompatibilityDocument with _$CompatibilityDocument {
  /// Creates a [CompatibilityDocument].
  const factory({
    /// Minimum engine schema.
    required int minEngineSchema,

    /// Minimum app version.
    required String minAppVersion,
  }) = _CompatibilityDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$CompatibilityDocumentFromJson(json);
}
