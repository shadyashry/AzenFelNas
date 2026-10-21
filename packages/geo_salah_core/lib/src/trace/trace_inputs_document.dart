import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/trace_hijri_inputs_document.dart';

part 'trace_inputs_document.freezed.dart';
part 'trace_inputs_document.g.dart';

/// Inputs hashed into `inputsHash` and carried by Calculation ID links (§6.4
/// ¶11).
@freezed
abstract class TraceInputsDocument with _$TraceInputsDocument {
  /// Creates a [TraceInputsDocument].
  const factory({
    /// Latitude, rounded to 6 decimals.
    required double lat,

    /// Longitude, rounded to 6 decimals.
    required double lon,

    /// IANA zone id of the observer.
    required String zoneId,

    /// Prayer day, `YYYY-MM-DD`.
    required String day,

    /// Prayer profile id.
    required String profileId,

    /// Prayer profile version.
    required String profileVersion,

    /// Hijri state of the day.
    required TraceHijriInputsDocument hijri,
  }) = _TraceInputsDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TraceInputsDocumentFromJson(json);
}
