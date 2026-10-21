import 'package:freezed_annotation/freezed_annotation.dart';

part 'localized_text.freezed.dart';
part 'localized_text.g.dart';

/// Text in both shipped locales.
@freezed
abstract class LocalizedText with _$LocalizedText {
  /// Creates a [LocalizedText].
  const factory({
    /// Arabic.
    required String ar,

    /// English.
    required String en,
  }) = _LocalizedText;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) => _$LocalizedTextFromJson(json);
}
