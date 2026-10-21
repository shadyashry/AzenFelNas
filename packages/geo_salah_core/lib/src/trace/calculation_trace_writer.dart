import 'package:geo_salah_core/src/model/adjustment_kind.dart';
import 'package:geo_salah_core/src/model/adjustment_step.dart';
import 'package:geo_salah_core/src/model/confidence_label.dart';
import 'package:geo_salah_core/src/model/day_result.dart';
import 'package:geo_salah_core/src/model/event_origin.dart';
import 'package:geo_salah_core/src/model/high_latitude_method.dart';
import 'package:geo_salah_core/src/model/hijri_confidence.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/prayer_time.dart';
import 'package:geo_salah_core/src/model/result_flag.dart';
import 'package:geo_salah_core/src/trace/adjustment_kind_code.dart';
import 'package:geo_salah_core/src/trace/adjustment_step_document.dart';
import 'package:geo_salah_core/src/trace/calculation_inputs.dart';
import 'package:geo_salah_core/src/trace/calculation_trace_document.dart';
import 'package:geo_salah_core/src/trace/confidence_label_document.dart';
import 'package:geo_salah_core/src/trace/event_origin_document.dart';
import 'package:geo_salah_core/src/trace/hijri_confidence_code.dart';
import 'package:geo_salah_core/src/trace/no_event_reason_code.dart';
import 'package:geo_salah_core/src/trace/result_flag_code.dart';
import 'package:geo_salah_core/src/trace/trace_inputs_document.dart';
import 'package:geo_salah_core/src/trace/trace_provenance_document.dart';
import 'package:geo_salah_core/src/trace/trace_time_document.dart';
import 'package:geo_salah_core/src/wire/high_latitude_method_document.dart';
import 'package:geo_salah_core/src/wire/prayer_event_code.dart';

/// Writes a [DayResult] as `calculation_trace.v1` (Appendix M): the day,
/// its provenance, each time with its own adjustment steps (§15 D21) and
/// the [CalculationInputs] its ID covers.
///
/// A `NO_EVENT` time is written without instants (§15 D29). Pure and
/// deterministic.
final class CalculationTraceWriter {
  /// The writer.
  const new();

  /// The trace of [result], calculated from [inputs].
  ///
  /// Throws [ArgumentError] when [result] has no times (a skipped calendar
  /// day, §15 D36): the schema requires at least one, so such a day has no
  /// trace.
  CalculationTraceDocument write(DayResult result, CalculationInputs inputs) {
    if (result.times.isEmpty) {
      throw ArgumentError.value(result.day, 'result', 'has no times');
    }
    final provenance = result.provenance;
    return CalculationTraceDocument(
      schemaVersion: 1,
      calculationId: result.calculationId,
      day: result.day.toJson(),
      inputs: TraceInputsDocument.fromJson(inputs.toJson()),
      provenance: TraceProvenanceDocument(
        engineVersion: provenance.engineVersion,
        deltaTModel: provenance.deltaTModel,
        profileId: provenance.profileId,
        profileVersion: provenance.profileVersion,
        tzdbVersion: provenance.tzdbVersion,
        inputsHash: provenance.inputsHash,
        hijriConfidence: _hijriConfidence(provenance.hijriConfidence),
      ),
      times: [
        for (final time in result.times)
          _time(time, [
            for (final step in provenance.adjustmentTrace)
              if (step.event == time.event) _step(step),
          ]),
      ],
    );
  }

  static TraceTimeDocument _time(
    PrayerTime time,
    List<AdjustmentStepDocument> steps,
  ) => TraceTimeDocument(
    event: _event(time.event),
    origin: _origin(time.origin),
    confidence: _confidence(time.confidence),
    flags: [
      for (final flag in ResultFlag.values)
        if (time.flags.contains(flag)) _flag(flag),
    ],
    adjustmentTrace: steps,
    rawUtcMs: time.rawUtcMs,
    displayedUtcMs: time.displayedUtcMs,
    dayOffset: time.dayOffset,
  );

  static AdjustmentStepDocument _step(AdjustmentStep step) =>
      AdjustmentStepDocument(
        event: _event(step.event),
        kind: switch (step.kind) {
          AdjustmentKind.perEventOffset => AdjustmentKindCode.perEventOffset,
          AdjustmentKind.ramadanRuleReplacement =>
            AdjustmentKindCode.ramadanRuleReplacement,
          AdjustmentKind.highLatitudeFallback =>
            AdjustmentKindCode.highLatitudeFallback,
          AdjustmentKind.rounding => AdjustmentKindCode.rounding,
        },
        deltaMs: step.deltaMs,
        reason: step.reason,
        evidenceId: step.evidenceId,
      );

  static PrayerEventCode _event(PrayerEvent event) => switch (event) {
    PrayerEvent.imsak => PrayerEventCode.imsak,
    PrayerEvent.fajr => PrayerEventCode.fajr,
    PrayerEvent.sunrise => PrayerEventCode.sunrise,
    PrayerEvent.dhuhr => PrayerEventCode.dhuhr,
    PrayerEvent.asr => PrayerEventCode.asr,
    PrayerEvent.maghrib => PrayerEventCode.maghrib,
    PrayerEvent.isha => PrayerEventCode.isha,
  };

  static EventOriginDocument _origin(EventOrigin origin) => switch (origin) {
    Primary() => const EventOriginDocument.primary(),
    Fallback(:final method) => EventOriginDocument.fallback(
      method: _method(method),
    ),
    NoEvent(:final reason) => EventOriginDocument.noEvent(
      reason: _reason(reason),
    ),
  };

  static HighLatitudeMethodDocument _method(HighLatitudeMethod method) =>
      switch (method) {
        AnglePortion() => const HighLatitudeMethodDocument.anglePortion(),
        MiddleOfNight() => const HighLatitudeMethodDocument.middleOfNight(),
        SeventhOfNight() => const HighLatitudeMethodDocument.seventhOfNight(),
        NearestLatitude(:final latDeg) =>
          HighLatitudeMethodDocument.nearestLatitude(latDeg: latDeg),
        NearestValidDay(:final maxDays) =>
          HighLatitudeMethodDocument.nearestValidDay(maxDays: maxDays),
      };

  static NoEventReasonCode _reason(NoEventReason reason) => switch (reason) {
    NoEventReason.polarDay => NoEventReasonCode.polarDay,
    NoEventReason.polarNight => NoEventReasonCode.polarNight,
    NoEventReason.twilightAbsent => NoEventReasonCode.twilightAbsent,
    NoEventReason.asrUndefined => NoEventReasonCode.asrUndefined,
    NoEventReason.chainExhausted => NoEventReasonCode.chainExhausted,
  };

  static ConfidenceLabelDocument _confidence(ConfidenceLabel label) =>
      switch (label) {
        Calculated() => const ConfidenceLabelDocument.calculated(),
        AuthorityAligned(:final benchmarkReportId) =>
          ConfidenceLabelDocument.authorityAligned(
            benchmarkReportId: benchmarkReportId,
          ),
        Verified(:final sourceRef, :final freshUntilUtcMs) =>
          ConfidenceLabelDocument.verified(
            sourceRef: sourceRef,
            freshUntilUtcMs: freshUntilUtcMs,
          ),
        Estimated(:final rangeMinutes) => ConfidenceLabelDocument.estimated(
          rangeMinutes: rangeMinutes,
        ),
        Observed(:final count, :final lastSeenUtcMs) =>
          ConfidenceLabelDocument.observed(
            count: count,
            lastSeenUtcMs: lastSeenUtcMs,
          ),
        Unknown(:final reasonCode) => ConfidenceLabelDocument.unknown(
          reasonCode: reasonCode,
        ),
      };

  static ResultFlagCode _flag(ResultFlag flag) => switch (flag) {
    ResultFlag.nearRoundingBoundary => ResultFlagCode.nearRoundingBoundary,
    ResultFlag.highLatitudeFallback => ResultFlagCode.highLatitudeFallback,
    ResultFlag.lowLocationAccuracy => ResultFlagCode.lowLocationAccuracy,
    ResultFlag.dstTransitionDay => ResultFlagCode.dstTransitionDay,
    ResultFlag.staleTzdb => ResultFlagCode.staleTzdb,
    ResultFlag.hijriExpected => ResultFlagCode.hijriExpected,
    ResultFlag.referenceModeAuthorityPoint =>
      ResultFlagCode.referenceModeAuthorityPoint,
    ResultFlag.manualCoordinateResolution =>
      ResultFlagCode.manualCoordinateResolution,
    ResultFlag.zoneBoundaryProximity => ResultFlagCode.zoneBoundaryProximity,
    ResultFlag.noLocalProfile => ResultFlagCode.noLocalProfile,
  };

  static HijriConfidenceCode _hijriConfidence(HijriConfidence confidence) =>
      switch (confidence) {
        HijriConfidence.confirmed => HijriConfidenceCode.confirmed,
        HijriConfidence.expected => HijriConfidenceCode.expected,
        HijriConfidence.userOverride => HijriConfidenceCode.userOverride,
      };
}
