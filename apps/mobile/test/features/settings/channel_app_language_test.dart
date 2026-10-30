import 'package:daily_muslim/features/settings/data/channel_app_language.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel(ChannelAppLanguage.channelName);
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('the app language goes to the platform so native Athan text follows '
      'it, and System follows the phone again (§15 D116)', () async {
    final sent = <Object?>[];
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'setLocales');
      sent.add(call.arguments);
      return null;
    });

    for (final setting in LocaleSetting.values) {
      await const ChannelAppLanguage()(setting);
    }

    expect(sent, ['ar', 'en', '']);
  });

  test('a platform without the channel is not an error', () async {
    await expectLater(
      const ChannelAppLanguage()(LocaleSetting.ar),
      completes,
    );
  });
}
