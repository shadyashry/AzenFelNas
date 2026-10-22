import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// [RecordContextEvent] as `event_log.v1` entries (Appendix J):
/// `CONTEXT_CHANGED` with `reason`, `zoneId` and `countryCode` only — the
/// schema has no key a coordinate could go in (REQ-PRIV-001).
final class EventLogContextEvents implements RecordContextEvent {
  /// Appends every entry with [_append] (the S16 event-log ring buffer).
  const new(this._append);

  final Future<void> Function(EventLogEntry entry) _append;

  @override
  Future<void> record(ContextChanged event) => _append(entryOf(event));

  /// The Appendix J entry of [event]: WARN for a mock fix, INFO otherwise.
  static EventLogEntry entryOf(ContextChanged event) => EventLogEntry(
    utcMs: event.utcMs,
    level: switch (event.reason) {
      ContextChangeReason.mockLocation => EventLogLevel.warn,
      ContextChangeReason.resolver => EventLogLevel.info,
    },
    code: EventCode.contextChanged,
    attrs: EventLogAttrs(
      reason: event.reason.wire,
      zoneId: event.zoneId,
      countryCode: event.country,
    ),
  );
}
