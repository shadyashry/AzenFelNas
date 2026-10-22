import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/contexts/domain/location_fix.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// A device whose answers the test sets.
final class FakeDeviceLocator implements LocateDevice {
  /// What [currentFix] answers.
  Result<LocationFix, LocationFailure> current = const Err(
    LocationFailure.unavailable('no fix'),
  );

  /// What [lastKnownFix] answers.
  Result<LocationFix?, LocationFailure> lastKnown = const Ok(null);

  @override
  Future<Result<LocationFix, LocationFailure>> currentFix() async => current;

  @override
  Future<Result<LocationFix?, LocationFailure>> lastKnownFix() async =>
      lastKnown;
}
