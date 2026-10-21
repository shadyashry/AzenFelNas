import 'package:freezed_annotation/freezed_annotation.dart';

part 'gazetteer_alt_names.freezed.dart';
part 'gazetteer_alt_names.g.dart';

/// Alternate names per locale.
@freezed
abstract class GazetteerAltNames with _$GazetteerAltNames {
  /// Creates a [GazetteerAltNames].
  const factory({
    /// Arabic names.
    required List<String> ar,

    /// English names.
    required List<String> en,
  }) = _GazetteerAltNames;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$GazetteerAltNamesFromJson(json);
}
