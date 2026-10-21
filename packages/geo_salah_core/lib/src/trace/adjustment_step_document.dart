import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/adjustment_kind_code.dart';
import 'package:geo_salah_core/src/wire/prayer_event_code.dart';

part 'adjustment_step_document.freezed.dart';
part 'adjustment_step_document.g.dart';

/// One step of an event's adjustment trace (§6.2 `AdjustmentStep`).
@freezed
abstract class AdjustmentStepDocument with _$AdjustmentStepDocument {
  /// Creates a [AdjustmentStepDocument].
  const factory({
    /// Event the step applies to.
    required PrayerEventCode event,

    /// What kind of adjustment it was.
    required AdjustmentKindCode kind,

    /// Change in milliseconds.
    required int deltaMs,

    /// Why the step was taken.
    required String reason,

    /// Evidence id, when the step comes from profile evidence.
    String? evidenceId,
  }) = _AdjustmentStepDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$AdjustmentStepDocumentFromJson(json);
}
