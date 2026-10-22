import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// [RequestLocationAccess] on the `permission_handler` plugin: when-in-use
/// location only, never background (ADR-014, §7.5). The composition root
/// passes `PermissionHandlerPlatform.instance`.
final class PermissionHandlerLocationAccess implements RequestLocationAccess {
  /// The adapter over [_platform].
  const new(this._platform);

  final PermissionHandlerPlatform _platform;

  static const PermissionWithService _permission = Permission.locationWhenInUse;

  @override
  Future<LocationAccess> request() async {
    final statuses = await _platform.requestPermissions([_permission]);
    return switch (statuses[_permission] ?? PermissionStatus.denied) {
      PermissionStatus.granted ||
      PermissionStatus.limited ||
      PermissionStatus.provisional => LocationAccess.granted,
      PermissionStatus.denied => LocationAccess.denied,
      PermissionStatus.permanentlyDenied => LocationAccess.permanentlyDenied,
      PermissionStatus.restricted => LocationAccess.restricted,
    };
  }
}
