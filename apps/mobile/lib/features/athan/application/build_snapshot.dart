import 'package:daily_muslim/features/athan/application/plan_event_code.dart';
import 'package:daily_muslim/features/athan/domain/snapshot_request.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Builds the widget `Snapshot` (§7.7, Appendix I): the displayed times of
/// the next 48 h with their confidence and the sky-phase timeline, so
/// widgets never recalculate. Pure.
///
/// Items are the timed events with `now ≤ displayedUtcMs < now + 48 h`.
/// The sky timeline samples `ComputeSolarState` every 5 min from now and
/// opens a segment at each phase change (§15 D80); it is presentation only.
final class BuildSnapshot {
  /// Builds with [_tzdb].
  const new(this._tzdb);

  final PinnedTzDatabase _tzdb;

  /// The window a snapshot covers.
  static const int windowMs = 48 * 3600000;

  /// The sky timeline's sampling step.
  static const int skyStepMs = 5 * 60000;

  static const ComputeSolarState _solar = ComputeSolarState();

  /// The snapshot of [request].
  Snapshot call(SnapshotRequest request) {
    final zoneId = request.observer.zoneId;
    final end = request.nowUtcMs + windowMs;
    return Snapshot(
      schemaVersion: 1,
      contextId: request.contextId,
      zoneId: zoneId,
      tzdbVersion: _tzdb.version,
      generatedAtUtcMs: request.nowUtcMs,
      locale: request.locale,
      items: List.unmodifiable([
        for (final day in request.days)
          for (final time in day.times)
            if (time.displayedUtcMs case final displayed?
                when displayed >= request.nowUtcMs && displayed < end)
              SnapshotItem(
                day: day.day.toJson(),
                event: PlanEventCode.of(time.event),
                displayedUtcMs: displayed,
                displayLocal: _local(zoneId, displayed),
                confidence: confidenceOf(time.confidence),
                dayOffset: time.dayOffset ?? 0,
              ),
      ]),
      skyTimeline: List.unmodifiable(_sky(request.observer, request.nowUtcMs)),
      health: request.health,
    );
  }

  /// The wire confidence of [label]; every label but `Calculated` carries
  /// its source, range, count or reason (REQ-UX-001).
  static SnapshotConfidence confidenceOf(ConfidenceLabel label) =>
      switch (label) {
        Calculated() => const SnapshotConfidence(
          kind: ConfidenceKindCode.calculated,
        ),
        AuthorityAligned(:final benchmarkReportId) => SnapshotConfidence(
          kind: ConfidenceKindCode.authorityAligned,
          detail: benchmarkReportId,
        ),
        Verified(:final sourceRef) => SnapshotConfidence(
          kind: ConfidenceKindCode.verified,
          detail: sourceRef,
        ),
        Estimated(:final rangeMinutes) => SnapshotConfidence(
          kind: ConfidenceKindCode.estimated,
          detail: '±$rangeMinutes min',
        ),
        Observed(:final count) => SnapshotConfidence(
          kind: ConfidenceKindCode.observed,
          detail: 'n=$count',
        ),
        Unknown(:final reasonCode) => SnapshotConfidence(
          kind: ConfidenceKindCode.unknown,
          detail: reasonCode,
        ),
      };

  static List<SkySegment> _sky(Observer observer, int fromUtcMs) {
    final segments = <SkySegment>[];
    SkyPhase? previous;
    for (var t = fromUtcMs; t < fromUtcMs + windowMs; t += skyStepMs) {
      final phase = _solar(observer: observer, utcMs: t).phase;
      if (phase != previous) {
        segments.add(SkySegment(fromUtcMs: t, phase: _phaseCode(phase)));
        previous = phase;
      }
    }
    return segments;
  }

  static SkyPhaseCode _phaseCode(SkyPhase phase) => switch (phase) {
    SkyPhase.night => SkyPhaseCode.night,
    SkyPhase.astronomicalDawn => SkyPhaseCode.astronomicalDawn,
    SkyPhase.nauticalDawn => SkyPhaseCode.nauticalDawn,
    SkyPhase.civilDawn => SkyPhaseCode.civilDawn,
    SkyPhase.goldenMorning => SkyPhaseCode.goldenMorning,
    SkyPhase.day => SkyPhaseCode.day,
    SkyPhase.goldenEvening => SkyPhaseCode.goldenEvening,
    SkyPhase.civilDusk => SkyPhaseCode.civilDusk,
    SkyPhase.nauticalDusk => SkyPhaseCode.nauticalDusk,
    SkyPhase.astronomicalDusk => SkyPhaseCode.astronomicalDusk,
  };

  String _local(String zoneId, int utcMs) {
    final minutes =
        _tzdb.localDateTimeOf(zoneId, utcMs).millisecondOfDay ~/ 60000;
    return '${_two(minutes ~/ 60)}:${_two(minutes % 60)}';
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
