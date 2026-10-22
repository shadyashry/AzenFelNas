import 'package:daily_muslim/features/contexts/data/permission_handler_location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:permission_handler_platform_interface/permission_handler_platform_interface.dart';

/// The plugin's platform channel, answering [status] to every request.
final class _ScriptedPermissions extends PermissionHandlerPlatform {
  new(this.status);

  final PermissionStatus status;

  /// What was requested.
  final List<Permission> requested = [];

  @override
  Future<Map<Permission, PermissionStatus>> requestPermissions(
    List<Permission> permissions,
  ) async {
    requested.addAll(permissions);
    return {for (final p in permissions) p: status};
  }
}

/// A permission state the test sets.
final class _FakeAccess implements RequestLocationAccess {
  const new(this.access);

  final LocationAccess access;

  @override
  Future<LocationAccess> request() async => access;
}

void main() {
  const cases = {
    PermissionStatus.granted: LocationAccess.granted,
    PermissionStatus.limited: LocationAccess.granted,
    PermissionStatus.provisional: LocationAccess.granted,
    PermissionStatus.denied: LocationAccess.denied,
    PermissionStatus.permanentlyDenied: LocationAccess.permanentlyDenied,
    PermissionStatus.restricted: LocationAccess.restricted,
  };
  final implementations =
      <String, RequestLocationAccess Function(PermissionStatus)>{
        'PermissionHandlerLocationAccess': (s) =>
            PermissionHandlerLocationAccess(_ScriptedPermissions(s)),
        '_FakeAccess': (s) => _FakeAccess(cases[s] ?? LocationAccess.denied),
      };

  for (final MapEntry(key: name, value: open) in implementations.entries) {
    group('REQ-TEST-004 RequestLocationAccess port contract: $name', () {
      for (final MapEntry(key: status, value: access) in cases.entries) {
        test('${status.name} maps to ${access.name}', () async {
          expect(await open(status).request(), access);
        });
      }
    });
  }

  test(
    'ADR-014 only when-in-use location is requested, never background',
    () async {
      final platform = _ScriptedPermissions(PermissionStatus.granted);
      await PermissionHandlerLocationAccess(platform).request();
      expect(platform.requested, [Permission.locationWhenInUse]);
    },
  );
}
