import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// `presentedByOs` of an Athan Test (§8.3) from drained native events: true
/// when an `ALARM_PRESENTED` receipt names the alarm a `TEST_STARTED` line
/// armed, else null — no receipt is not proof of silence (the iOS
/// notification path has none while the app is not running).
final class TestPresentation {
  /// The rule.
  const new();

  /// The evidence in [entries].
  bool? call(List<EventLogEntry> entries) {
    final tests = {
      for (final e in entries)
        if (e.code == EventCode.testStarted) e.attrs.entryId,
    }..remove(null);
    final presented = entries.any(
      (e) =>
          e.code == EventCode.alarmPresented && tests.contains(e.attrs.entryId),
    );
    return presented ? true : null;
  }
}
