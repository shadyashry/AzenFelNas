import 'package:daily_muslim/features/athan/application/record_athan_test_result.dart';
import 'package:daily_muslim/features/athan/application/test_presentation.dart';
import 'package:daily_muslim/features/athan/data/event_log_last_test.dart';
import 'package:daily_muslim/features/athan/domain/athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/native_event.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TestPresentation', () {
    const presentation = TestPresentation();

    test(
      'REQ-ALM-040 presentedByOs is true when a receipt names the Test alarm',
      () {
        expect(
          presentation(const [
            NativeEvent(EventCode.testStarted, entryId: 'a1a1a1a1a1a1a1a1'),
            NativeEvent(EventCode.alarmPresented, entryId: 'b2b2b2b2b2b2b2b2'),
            NativeEvent(EventCode.alarmPresented, entryId: 'a1a1a1a1a1a1a1a1'),
          ]),
          isTrue,
        );
      },
    );

    test('REQ-ALM-040 no matching receipt is null, never false', () {
      expect(
        presentation(const [
          NativeEvent(EventCode.testStarted, entryId: 'a1a1a1a1a1a1a1a1'),
          NativeEvent(EventCode.alarmPresented, entryId: 'b2b2b2b2b2b2b2b2'),
        ]),
        isNull,
      );
      expect(presentation(const []), isNull);
    });
  });

  group('RecordAthanTestResult + EventLogLastTest', () {
    test('REQ-ALM-040 the answer and the OS evidence are stored apart, and '
        'the newest TEST_RESULT is read back', () async {
      final log = <EventLogEntry>[];
      final record = RecordAthanTestResult((e) async => log.add(e));
      await record(
        const AthanTestResult(
          testId: '0000019a1196c600',
          heardByUser: true,
          presentedByOs: true,
          answeredAtUtcMs: 5,
        ),
      );
      await record(
        const AthanTestResult(
          testId: '0000019a1196c601',
          heardByUser: false,
          presentedByOs: null,
          answeredAtUtcMs: 6,
        ),
      );
      expect(log.last.code, EventCode.testResult);
      expect(log.last.attrs.state, AthanTestResult.notHeardState);
      expect(log.last.attrs.reason, 'noReceipt');
      expect(log.first.attrs.reason, 'presented');
      expect(log.last.toJson()['attrs'], isNot(contains('lat')));
      expect(await EventLogLastTest(() async => log)(), isFalse);
      expect(await EventLogLastTest(() async => const [])(), isNull);
    });
  });
}
