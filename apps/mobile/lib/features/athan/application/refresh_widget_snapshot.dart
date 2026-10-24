import 'dart:convert';

import 'package:daily_muslim/features/athan/application/build_snapshot.dart';
import 'package:daily_muslim/features/athan/application/plan_context_id.dart';
import 'package:daily_muslim/features/athan/application/snapshot_request.dart';
import 'package:daily_muslim/features/athan/domain/write_widget_snapshot.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Rewrites the widget `Snapshot` from the schedule the app now shows
/// (§7.7): on every schedule change — a profile or package update, a context
/// switch, a new local day — so widgets follow without recalculating
/// (REQ-WID-003).
final class RefreshWidgetSnapshot {
  /// Refreshes with [_build] into [_write] at [_clock]'s instant.
  const new(this._build, this._write, this._clock);

  final BuildSnapshot _build;
  final WriteWidgetSnapshot _write;
  final Clock _clock;

  /// Builds the snapshot of [schedule] in [locale] with [health] and writes
  /// it; the host's answer (false: the previous snapshot stays).
  Future<bool> call(
    Schedule schedule, {
    required PlanLocale locale,
    required SnapshotHealth health,
  }) => _write(
    EncodedSnapshot(
      jsonEncode(
        _build(
          SnapshotRequest(
            contextId: PlanContextId.of(schedule.context.context.id),
            observer: ObserverOf.context(schedule.context),
            days: schedule.days,
            nowUtcMs: _clock.nowUtcMs(),
            locale: locale,
            health: health,
          ),
        ).toJson(),
      ),
    ),
  );
}
