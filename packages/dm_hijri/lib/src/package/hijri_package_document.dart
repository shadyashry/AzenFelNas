import 'package:dm_hijri/src/package/hijri_month_document.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hijri_package_document.freezed.dart';
part 'hijri_package_document.g.dart';

/// Wire form of the `hijri` package payload (`hijri_package.v1`, §9.5).
@freezed
abstract class HijriPackageDocument with _$HijriPackageDocument {
  /// Creates a [HijriPackageDocument].
  const factory({
    /// ISO 3166-1 alpha-2 source country.
    required String country,

    /// Month starts.
    required List<HijriMonthDocument> months,
  }) = _HijriPackageDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$HijriPackageDocumentFromJson(json);
}
