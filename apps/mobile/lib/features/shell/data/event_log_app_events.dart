import 'package:daily_muslim/features/shell/domain/record_app_start.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// [RecordAppStart] as an `APP_START` `event_log.v1` entry with no
/// attributes (REQ-PRIV-001).
final class EventLogAppEvents implements RecordAppStart {
  /// Appends every entry with [_append] (the event-log ring buffer).
  const new(this._append);

  final Future<void> Function(EventLogEntry entry) _append;

  @override
  Future<void> call(int utcMs) => _append(
    EventLogEntry(
      utcMs: utcMs,
      level: EventLogLevel.info,
      code: EventCode.appStart,
      attrs: const EventLogAttrs(),
    ),
  );
}
