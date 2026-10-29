import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// [RequestAthanGrant] on the `permission_handler` plugin (§15 D95). A
/// permission the system no longer prompts for opens the app's settings
/// instead. The composition root passes `PermissionHandlerPlatform.instance`.
final class PermissionHandlerAthanGrant implements RequestAthanGrant {
  /// The adapter over [_platform].
  const new(this._platform);

  final PermissionHandlerPlatform _platform;

  @override
  Future<void> call(AthanGrant grant) async {
    try {
      switch (grant) {
        case AthanGrant.notifications:
          await _request(Permission.notification);
        case AthanGrant.exactAlarms:
          // Opens "Alarms & reminders" for the app on Android 12+.
          await _request(Permission.scheduleExactAlarm);
        case AthanGrant.appSettings:
          await _platform.openAppSettings();
      }
    } on PlatformException {
      // No plugin host (tests) or no settings screen: nothing to show.
    } on MissingPluginException {
      // Same, on a platform without the plugin.
    }
  }

  Future<void> _request(Permission permission) async {
    final statuses = await _platform.requestPermissions([permission]);
    switch (statuses[permission] ?? PermissionStatus.denied) {
      case PermissionStatus.permanentlyDenied || PermissionStatus.restricted:
        await _platform.openAppSettings();
      case PermissionStatus.granted ||
          PermissionStatus.limited ||
          PermissionStatus.provisional ||
          PermissionStatus.denied:
        break;
    }
  }
}
