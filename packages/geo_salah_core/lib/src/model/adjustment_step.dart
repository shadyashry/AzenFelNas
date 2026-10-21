import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:geo_salah_core/src/model/adjustment_kind.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';

part 'adjustment_step.freezed.dart';

/// One step of a day's adjustment trace (§6.2 `AdjustmentStep`).
@freezed
abstract class AdjustmentStep with _$AdjustmentStep {
  /// Creates an [AdjustmentStep].
  const factory({
    /// The event adjusted.
    required PrayerEvent event,

    /// What kind of adjustment it was.
    required AdjustmentKind kind,

    /// Change of the instant, milliseconds.
    required int deltaMs,

    /// Why the step was taken.
    required String reason,

    /// Profile evidence id, when the step comes from profile evidence.
    String? evidenceId,
  }) = _AdjustmentStep;
}
