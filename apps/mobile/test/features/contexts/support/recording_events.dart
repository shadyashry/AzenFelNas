import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_contracts/dm_contracts.dart';

/// Keeps every recorded event, in order.
final class RecordingEvents implements RecordEvent {
  /// The events so far.
  final List<EventLogEntry> entries = [];

  @override
  Future<void> record(EventLogEntry entry) async => entries.add(entry);
}
