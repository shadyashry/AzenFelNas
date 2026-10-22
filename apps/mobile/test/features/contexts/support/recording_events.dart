import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';

/// Keeps every recorded event, in order.
final class RecordingEvents implements RecordContextEvent {
  /// The events so far.
  final List<ContextChanged> entries = [];

  @override
  Future<void> record(ContextChanged event) async => entries.add(event);
}
