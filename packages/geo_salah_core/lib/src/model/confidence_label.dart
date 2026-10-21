import 'package:freezed_annotation/freezed_annotation.dart';

part 'confidence_label.freezed.dart';

/// The confidence shown with a time (§6.2, REQ-DOM-010): a sealed type,
/// never a string or a display flag. The engine derives it from the
/// event's origin and the profile (REQ-DOM-050); `verified` and `observed`
/// come only from V1.5 data types, never from the engine.
@freezed
sealed class ConfidenceLabel with _$ConfidenceLabel {
  /// Calculated by the engine.
  const factory calculated() = Calculated;

  /// Matches an authority's published times, per [benchmarkReportId].
  const factory authorityAligned({required String benchmarkReportId}) =
      AuthorityAligned;

  /// Verified by [sourceRef] until [freshUntilUtcMs].
  const factory verified({
    required String sourceRef,
    required int freshUntilUtcMs,
  }) = Verified;

  /// Estimated within ±[rangeMinutes] (REQ-UX-001).
  const factory estimated({required int rangeMinutes}) = Estimated;

  /// Observed [count] times, last at [lastSeenUtcMs] (REQ-UX-001).
  const factory observed({required int count, required int lastSeenUtcMs}) =
      Observed;

  /// Not known, for [reasonCode].
  const factory unknown({required String reasonCode}) = Unknown;
}
