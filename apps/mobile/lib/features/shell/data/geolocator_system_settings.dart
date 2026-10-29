import 'package:daily_muslim/features/shell/domain/open_system_settings.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

/// [OpenSystemSettings] on the `geolocator` plugin. The composition root
/// passes `GeolocatorPlatform.instance`.
final class GeolocatorSystemSettings implements OpenSystemSettings {
  /// The adapter over [_platform].
  const new(this._platform);

  final GeolocatorPlatform _platform;

  @override
  Future<void> location() => _open(_platform.openLocationSettings);

  @override
  Future<void> app() => _open(_platform.openAppSettings);

  static Future<void> _open(Future<bool> Function() open) async {
    try {
      await open();
    } on PlatformException {
      // No settings screen to show.
    } on MissingPluginException {
      // No plugin host (tests).
    }
  }
}
