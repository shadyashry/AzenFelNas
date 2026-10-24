import 'package:daily_muslim/features/settings/data/clipboard_diagnostic_text.dart';
import 'package:daily_muslim/features/settings/domain/deliver_diagnostic_text.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/diagnostic_fixtures.dart';

/// The [DeliverDiagnosticText] contract, run against the fake and the
/// clipboard adapter (§17.7).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final clipboard = <String>[];
  var refuse = false;

  setUp(() {
    clipboard.clear();
    refuse = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method != 'Clipboard.setData') return null;
          if (refuse) throw PlatformException(code: 'denied');
          final args = call.arguments as Map<Object?, Object?>;
          clipboard.add('${args['text']}');
          return null;
        });
  });

  tearDown(
    () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null),
  );

  final fake = FakeDeliverDiagnosticText();
  final implementations = <String, (DeliverDiagnosticText, List<String>)>{
    'fake': (fake, fake.delivered),
    'clipboard': (const ClipboardDiagnosticText(), clipboard),
  };

  for (final MapEntry(key: name, value: (port, sink))
      in implementations.entries) {
    test('REQ-PRIV-005 $name hands over the exact text and says so', () async {
      sink.clear();
      const text = '{\n  "schemaVersion": 1\n}';

      expect(await port(text), isTrue);
      expect(sink, [text]);
    });
  }

  test('REQ-ERR-002 clipboard reports a platform refusal as false', () async {
    refuse = true;

    expect(await const ClipboardDiagnosticText()('{}'), isFalse);
    expect(clipboard, isEmpty);
  });
}
