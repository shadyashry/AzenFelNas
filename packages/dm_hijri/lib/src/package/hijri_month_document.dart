import 'package:dm_hijri/src/package/hijri_month_status_code.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'hijri_month_document.freezed.dart';
part 'hijri_month_document.g.dart';

/// One Hijri month start. [sourceUrl] is present exactly for confirmed months.
@freezed
abstract class HijriMonthDocument with _$HijriMonthDocument {
  /// Creates a [HijriMonthDocument].
  const factory({
    /// Hijri year.
    required int hijriYear,

    /// Hijri month, 1–12.
    required int hijriMonth,

    /// Gregorian date of day 1, `YYYY-MM-DD`.
    required String gregorianStart,

    /// Confirmation status.
    required HijriMonthStatusCode status,

    /// Official announcement URL.
    String? sourceUrl,
  }) = _HijriMonthDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$HijriMonthDocumentFromJson(json);
}
