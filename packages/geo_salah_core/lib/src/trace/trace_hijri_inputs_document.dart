import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/hijri_confidence_code.dart';
import 'package:geo_salah_core/src/trace/hijri_date_document.dart';

part 'trace_hijri_inputs_document.freezed.dart';
part 'trace_hijri_inputs_document.g.dart';

/// Hijri part of the calculation inputs (§6.4 ¶11).
@freezed
abstract class TraceHijriInputsDocument with _$TraceHijriInputsDocument {
  /// Creates a [TraceHijriInputsDocument].
  const factory({
    /// Hijri date governing Imsak/Fajr of the prayer day.
    required HijriDateDocument dateAtDawn,

    /// Hijri date governing Isha of the prayer day.
    required HijriDateDocument dateAtNight,

    /// How the Hijri dates were obtained.
    required HijriConfidenceCode confidence,
  }) = _TraceHijriInputsDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TraceHijriInputsDocumentFromJson(json);
}
