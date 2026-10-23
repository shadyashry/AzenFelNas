import 'package:daily_muslim/features/athan/application/athan_platform_ports.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// Moves native receipts and system events into the event log
/// (REQ-ALM-041); run on every start and before a Test answer is stored.
final class DrainAthanEvents {
  /// The use case draining [_drain] into [_append].
  const new(this._drain, this._append);

  final DrainNativeEvents _drain;
  final Future<void> Function(EventLogEntry entry) _append;

  /// The drained entries, already appended, oldest first.
  Future<List<EventLogEntry>> call() async {
    final entries = await _drain();
    for (final entry in entries) {
      await _append(entry);
    }
    return entries;
  }
}
