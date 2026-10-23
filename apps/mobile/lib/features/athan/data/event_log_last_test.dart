import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/read_last_test_heard.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// [ReadLastTestHeard] over the event log: the newest `TEST_RESULT` wins.
final class EventLogLastTest implements ReadLastTestHeard {
  /// The adapter over [_entries] (oldest first).
  const new(this._entries);

  final Future<List<EventLogEntry>> Function() _entries;

  @override
  Future<bool?> call() async {
    final entries = await _entries();
    for (final e in entries.reversed) {
      if (e.code != EventCode.testResult) continue;
      return switch (e.attrs.state) {
        AthanTestResult.heardState => true,
        AthanTestResult.notHeardState => false,
        _ => null,
      };
    }
    return null;
  }
}
