import 'package:daily_muslim/features/settings/domain/apply_app_language.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:flutter/services.dart';

/// [ApplyAppLanguage] over the `dm/app_language` method channel
/// (`MainActivity.kt`: the per-app language on Android 13 and later; older
/// Android and iOS keep the phone's language for native text).
final class ChannelAppLanguage implements ApplyAppLanguage {
  /// The adapter over [channel].
  const new({this.channel = const MethodChannel(channelName)});

  /// The channel's name, shared with the platform code.
  static const channelName = 'dm/app_language';

  /// The channel.
  final MethodChannel channel;

  /// The BCP 47 tag sent for [setting]; empty follows the phone.
  static String tagOf(LocaleSetting setting) => switch (setting) {
    LocaleSetting.ar => 'ar',
    LocaleSetting.en => 'en',
    LocaleSetting.system => '',
  };

  @override
  Future<void> call(LocaleSetting setting) async {
    try {
      await channel.invokeMethod<void>('setLocales', tagOf(setting));
    } on PlatformException {
      return;
    } on MissingPluginException {
      return;
    }
  }
}
