import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/wire/high_latitude_method_document.dart';

part 'high_latitude_document.freezed.dart';
part 'high_latitude_document.g.dart';

/// Ordered high-latitude method chain (§6.4 ¶7).
@freezed
abstract class HighLatitudeDocument with _$HighLatitudeDocument {
  /// Creates a [HighLatitudeDocument].
  const factory({
    /// Methods, tried in order.
    @HighLatitudeMethodDocumentConverter()
    required List<HighLatitudeMethodDocument> chain,
  }) = _HighLatitudeDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$HighLatitudeDocumentFromJson(json);
}
