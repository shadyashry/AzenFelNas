import 'package:freezed_annotation/freezed_annotation.dart';

part 'reference_point_document.freezed.dart';
part 'reference_point_document.g.dart';

/// Reference point used in `authorityReferencePoint` mode.
@freezed
abstract class ReferencePointDocument with _$ReferencePointDocument {
  /// Creates a [ReferencePointDocument].
  const factory({
    /// ISO 3166-1 alpha-2 or ISO 3166-2 area code.
    required String area,

    /// Latitude in degrees.
    required double lat,

    /// Longitude in degrees.
    required double lon,
  }) = _ReferencePointDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$ReferencePointDocumentFromJson(json);
}
