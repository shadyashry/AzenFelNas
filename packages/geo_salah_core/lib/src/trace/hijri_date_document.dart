import 'package:freezed_annotation/freezed_annotation.dart';

part 'hijri_date_document.freezed.dart';
part 'hijri_date_document.g.dart';

/// A Hijri date `{year, month, day}`.
@freezed
abstract class HijriDateDocument with _$HijriDateDocument {
  /// Creates a [HijriDateDocument].
  const factory({
    /// Hijri year.
    required int year,

    /// Hijri month, 1–12.
    required int month,

    /// Day of month, 1–30.
    required int day,
  }) = _HijriDateDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$HijriDateDocumentFromJson(json);
}
