import 'dart:convert';

import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:drift/drift.dart';

/// The `event_log` ring buffer of §7.3 in `dm.sqlite`: at most [capacity]
/// rows, the oldest dropped first (REQ-DATA-001). Entries are typed
/// `EventLogEntry` values, so a coordinate cannot be written (REQ-PRIV-001).
final class DriftEventLog {
  /// The log in [_db].
  const new(this._db);

  /// The ring size of §7.3.
  static const capacity = 5000;

  final DmDatabase _db;

  /// Appends [entry] and trims the ring, in one transaction.
  Future<void> call(EventLogEntry entry) => _db.transaction(() async {
    final json = entry.toJson();
    final seq = await _db
        .into(_db.eventLog)
        .insert(
          EventLogCompanion.insert(
            utc: entry.utcMs,
            level: '${json['level']}',
            code: entry.code.wire,
            attrsJson: jsonEncode(entry.attrs.toJson()),
          ),
        );
    await (_db.delete(
      _db.eventLog,
    )..where((r) => r.seq.isSmallerOrEqualValue(seq - capacity))).go();
  });

  /// Every entry, oldest first (the diagnostics export, S24).
  Future<List<EventLogEntry>> entries() async {
    final rows = await (_db.select(
      _db.eventLog,
    )..orderBy([(r) => OrderingTerm.asc(r.seq)])).get();
    return [
      for (final r in rows)
        EventLogEntry.fromJson({
          'utcMs': r.utc,
          'level': r.level,
          'code': r.code,
          'attrs': jsonDecode(r.attrsJson),
        }),
    ];
  }
}
