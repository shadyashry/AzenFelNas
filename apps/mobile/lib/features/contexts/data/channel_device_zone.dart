import 'package:daily_muslim/features/contexts/domain/device_zone.dart';
import 'package:flutter/services.dart';

/// [ReadDeviceZone] over the `dm/device_zone` method channel
/// (`MainActivity.kt`, `AppDelegate.swift`).
final class ChannelDeviceZone implements ReadDeviceZone {
  /// The adapter over [channel].
  const new({this.channel = const MethodChannel(channelName)});

  /// The channel's name, shared with the platform code.
  static const channelName = 'dm/device_zone';

  /// The channel.
  final MethodChannel channel;

  @override
  Future<String?> zoneId() async {
    try {
      final id = await channel.invokeMethod<String>('zoneId');
      return id == null || id.isEmpty ? null : id;
    } on PlatformException {
      return null;
    } on MissingPluginException {
      return null;
    }
  }
}
