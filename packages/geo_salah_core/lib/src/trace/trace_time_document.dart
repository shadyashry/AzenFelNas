import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/trace/adjustment_step_document.dart';
import 'package:geo_salah_core/src/trace/confidence_label_document.dart';
import 'package:geo_salah_core/src/trace/event_origin_document.dart';
import 'package:geo_salah_core/src/trace/result_flag_code.dart';
import 'package:geo_salah_core/src/wire/prayer_event_code.dart';

part 'trace_time_document.freezed.dart';
part 'trace_time_document.g.dart';

/// One event of a traced day. `rawUtcMs`, `displayedUtcMs` and `dayOffset` are
/// absent exactly when [origin] is `noEvent`.
@freezed
abstract class TraceTimeDocument with _$TraceTimeDocument {
  /// Creates a [TraceTimeDocument].
  const factory({
    /// The event.
    required PrayerEventCode event,

    /// How the time was obtained (REQ-DOM-002).
    required EventOriginDocument origin,

    /// Confidence label (REQ-DOM-010).
    required ConfidenceLabelDocument confidence,

    /// Result flags.
    required List<ResultFlagCode> flags,

    /// Adjustments applied to this event, in order.
    required List<AdjustmentStepDocument> adjustmentTrace,

    /// Raw instant, truncated to 1 ms (REQ-DOM-004).
    int? rawUtcMs,

    /// Displayed instant after rounding (REQ-DOM-003).
    int? displayedUtcMs,

    /// Local-date offset from the prayer day, −1…1.
    int? dayOffset,
  }) = _TraceTimeDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$TraceTimeDocumentFromJson(json);
}
