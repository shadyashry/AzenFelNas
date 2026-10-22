import 'dart:convert';

import 'package:daily_muslim/features/contexts/data/event_log_context_events.dart';
import 'package:daily_muslim/features/contexts/domain/context_changed.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('REQ-PRIV-001 a mock-location event becomes a coordinate-free '
      'CONTEXT_CHANGED WARN entry that round-trips the wire model', () async {
    final appended = <EventLogEntry>[];
    await EventLogContextEvents((e) async => appended.add(e)).record(
      const ContextChanged(
        utcMs: 1792670400000,
        reason: ContextChangeReason.mockLocation,
        zoneId: 'Etc/GMT+1',
        country: null,
      ),
    );
    final json = appended.single.toJson();
    expect(jsonDecode(jsonEncode(json)), {
      'utcMs': 1792670400000,
      'level': 'WARN',
      'code': 'CONTEXT_CHANGED',
      'attrs': {'reason': 'mock_location', 'zoneId': 'Etc/GMT+1'},
    });
    expect(EventLogEntry.fromJson(json), appended.single);
  });

  test('a resolver zone change is logged at INFO', () {
    final entry = EventLogContextEvents.entryOf(
      const ContextChanged(
        utcMs: 1,
        reason: ContextChangeReason.resolver,
        zoneId: 'Africa/Cairo',
        country: 'EG',
      ),
    );
    expect(entry.level, EventLogLevel.info);
    expect(entry.code, EventCode.contextChanged);
    expect(entry.attrs.countryCode, 'EG');
  });
}
