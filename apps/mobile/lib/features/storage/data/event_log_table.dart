import 'package:drift/drift.dart';

/// §7.3 `event_log`: the Appendix J ring buffer (at most
/// `DriftEventLog.capacity` rows). `attrs_json` holds an `EventLogAttrs`,
/// whose key allow-list makes a coordinate impossible (REQ-PRIV-001).
@DataClassName('EventLogRow')
class EventLog extends Table {
  /// Insertion order.
  IntColumn get seq => integer().autoIncrement()();

  /// When it happened (UTC epoch ms).
  IntColumn get utc => integer()();

  /// `EventLogLevel` wire value.
  TextColumn get level => text()();

  /// `EventCode.wire`.
  TextColumn get code => text()();

  /// The encoded `EventLogAttrs`.
  TextColumn get attrsJson => text()();
}
