import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/no_event_reason_code.dart';
import 'package:geo_salah_core/src/wire/high_latitude_method_document.dart';

part 'event_origin_document.freezed.dart';
part 'event_origin_document.g.dart';

/// Wire form of `EventOrigin` (§6.2, REQ-DOM-002), discriminated by `kind`:
/// `PRIMARY`, `FALLBACK` (with the method used) or `NO_EVENT` (with the
/// reason).
@Freezed(unionKey: 'kind', unionValueCase: FreezedUnionCase.screamingSnake)
sealed class EventOriginDocument with _$EventOriginDocument {
  /// The primary rule produced the time.
  const factory primary() = PrimaryOriginDocument;

  /// A high-latitude [method] produced the time.
  const factory fallback({
    @HighLatitudeMethodDocumentConverter()
    required HighLatitudeMethodDocument method,
  }) = FallbackOriginDocument;

  /// No time exists, for [reason].
  const factory noEvent({required NoEventReasonCode reason}) =
      NoEventOriginDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$EventOriginDocumentFromJson(json);
}
