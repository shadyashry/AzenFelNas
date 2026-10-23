import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// One drained native event, reduced to what Dart logic reads; the full
/// `event_log.v1` entry goes to the event log in the adapter.
@immutable
final class NativeEvent {
  /// Event [code] about alarm [entryId] (null when the line has none).
  const new(this.code, {this.entryId});

  /// The Appendix J event code.
  final EventCode code;

  /// The alarm or plan entry id, if any.
  final String? entryId;

  @override
  bool operator ==(Object other) =>
      other is NativeEvent && other.code == code && other.entryId == entryId;

  @override
  int get hashCode => Object.hash(code, entryId);
}
