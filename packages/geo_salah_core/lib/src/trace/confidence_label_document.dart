import 'package:freezed_annotation/freezed_annotation.dart';

part 'confidence_label_document.freezed.dart';
part 'confidence_label_document.g.dart';

/// Wire form of `ConfidenceLabel` (§6.2, REQ-DOM-010), discriminated by
/// `kind`. `estimated` always carries its range and `observed` its count
/// (REQ-UX-001).
@Freezed(unionKey: 'kind', unionValueCase: FreezedUnionCase.screamingSnake)
sealed class ConfidenceLabelDocument with _$ConfidenceLabelDocument {
  /// `CALCULATED`.
  const factory calculated() = CalculatedLabelDocument;

  /// `AUTHORITY_ALIGNED` with its [benchmarkReportId].
  const factory authorityAligned({required String benchmarkReportId}) =
      AuthorityAlignedLabelDocument;

  /// `VERIFIED` by [sourceRef] until [freshUntilUtcMs].
  const factory verified({
    required String sourceRef,
    required int freshUntilUtcMs,
  }) = VerifiedLabelDocument;

  /// `ESTIMATED` within ±[rangeMinutes].
  const factory estimated({required int rangeMinutes}) = EstimatedLabelDocument;

  /// `OBSERVED` [count] times, last at [lastSeenUtcMs].
  const factory observed({required int count, required int lastSeenUtcMs}) =
      ObservedLabelDocument;

  /// `UNKNOWN` for [reasonCode].
  const factory unknown({required String reasonCode}) = UnknownLabelDocument;

  /// Decodes [json]; throws `CheckedFromJsonException` when it does not
  /// have the schema's shape.
  factory fromJson(Map<String, Object?> json) =>
      _$ConfidenceLabelDocumentFromJson(json);
}
