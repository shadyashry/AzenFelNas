import 'package:daily_muslim/features/qibla/domain/vibrate_once.dart';
import 'package:flutter/services.dart';

/// [VibrateOnce] over the `dm/vibrate` channel (§15 D118); Android's
/// `VibrationEffect.createOneShot`. Without a native side nothing vibrates.
final class ChannelVibrateOnce implements VibrateOnce {
  /// The adapter on [_channel].
  const new([this._channel = const MethodChannel(channelName)]);

  /// The channel name shared with `MainActivity`.
  static const String channelName = 'dm/vibrate';

  final MethodChannel _channel;

  @override
  Future<void> call(Duration length) async {
    try {
      await _channel.invokeMethod<void>('once', length.inMilliseconds);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
