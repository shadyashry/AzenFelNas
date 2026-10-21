import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_profiles/src/document/authority_type_code.dart';

part 'authority_document.freezed.dart';
part 'authority_document.g.dart';

/// Authority named by a profile.
@freezed
abstract class AuthorityDocument with _$AuthorityDocument {
  /// Creates a [AuthorityDocument].
  const factory({
    /// Display name.
    required String name,

    /// Authority type.
    required AuthorityTypeCode type,
  }) = _AuthorityDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$AuthorityDocumentFromJson(json);
}
