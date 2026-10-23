import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Stores an Athan Test answer as a `TEST_RESULT` event (REQ-ALM-040):
/// `state` is `heard`/`notHeard` and `reason` is `presented`/`noReceipt`, so
/// the user's answer and the OS evidence stay separate.
final class RecordAthanTestResult {
  /// The use case appending to [_append].
  const new(this._append);

  final Future<void> Function(EventLogEntry entry) _append;

  /// Appends [result].
  Future<void> call(AthanTestResult result) => _append(
    EventLogEntry(
      utcMs: result.answeredAtUtcMs,
      level: result.heardByUser ? EventLogLevel.info : EventLogLevel.warn,
      code: EventCode.testResult,
      attrs: EventLogAttrs(
        entryId: result.testId,
        state: result.heardByUser
            ? AthanTestResult.heardState
            : AthanTestResult.notHeardState,
        reason: result.presentedByOs == true ? 'presented' : 'noReceipt',
      ),
    ),
  );
}
