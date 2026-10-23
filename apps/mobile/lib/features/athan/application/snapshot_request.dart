import 'package:dm_contracts/dm_contracts.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Everything `BuildSnapshot` reads (§7.7, Appendix I): the days of one
/// context, its observer for the sky timeline and the current Athan health.
@immutable
final class SnapshotRequest {
  /// A snapshot request for [days] of [contextId].
  const new({
    required this.contextId,
    required this.observer,
    required this.days,
    required this.nowUtcMs,
    required this.locale,
    required this.health,
  });

  /// Location context id.
  final String contextId;

  /// The observer the days were calculated for; its zone is the
  /// snapshot's.
  final Observer observer;

  /// Consecutive prayer days from the local today.
  final List<DayResult> days;

  /// The build instant; the snapshot covers the next 48 h from it.
  final int nowUtcMs;

  /// Locale widgets render in.
  final PlanLocale locale;

  /// Athan health summary; `UNKNOWN` until health probes exist (S21/S22).
  final SnapshotHealth health;
}
