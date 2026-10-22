import 'dart:async';

import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:geolocator/geolocator.dart';

/// [LocateDevice] on the `geolocator` plugin, at approximate accuracy
/// (ADR-014). The composition root passes `GeolocatorPlatform.instance`.
final class GeolocatorDeviceLocator implements LocateDevice {
  /// The locator over [_platform].
  const new(this._platform);

  final GeolocatorPlatform _platform;

  /// How long a new fix may take before `LOC_UNAVAILABLE` (§15 D73).
  static const fixTimeLimit = Duration(seconds: 30);

  @override
  Future<Result<LocationFix, LocationFailure>> currentFix() => _guard(() async {
    final position = await _platform.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.low,
        timeLimit: fixTimeLimit,
      ),
    );
    return _fix(position);
  });

  @override
  Future<Result<LocationFix?, LocationFailure>> lastKnownFix() =>
      _guard(() async {
        final position = await _platform.getLastKnownPosition();
        return position == null ? null : _fix(position);
      });

  /// Services and permission first, so no call here ever shows a prompt.
  Future<Result<T, LocationFailure>> _guard<T>(
    Future<T> Function() read,
  ) async {
    try {
      if (!await _platform.isLocationServiceEnabled()) {
        return const Err(LocationFailure.servicesOff());
      }
      switch (await _platform.checkPermission()) {
        case LocationPermission.denied ||
            LocationPermission.deniedForever ||
            LocationPermission.unableToDetermine:
          return const Err(LocationFailure.permissionDenied());
        case LocationPermission.whileInUse || LocationPermission.always:
          return Ok(await read());
      }
    } on PermissionDeniedException {
      return const Err(LocationFailure.permissionDenied());
    } on LocationServiceDisabledException {
      return const Err(LocationFailure.servicesOff());
    } on TimeoutException {
      return const Err(LocationFailure.unavailable('fix timed out'));
    } on Exception catch (error) {
      return Err(LocationFailure.unavailable('${error.runtimeType}'));
    }
  }

  static LocationFix _fix(Position position) => LocationFix(
    point: GeoPointE6.fromDegrees(position.latitude, position.longitude),
    horizontalAccuracyM: position.accuracy,
    fixUtcMs: position.timestamp.millisecondsSinceEpoch,
    isMock: position.isMocked,
  );
}
