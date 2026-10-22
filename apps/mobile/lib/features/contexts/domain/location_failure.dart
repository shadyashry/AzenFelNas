import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why no location context could be resolved or stored; every variant ends
/// in the manual-place prompt (§7.5).
@immutable
sealed class LocationFailure implements Failure {
  const new();

  /// The user has not granted location access.
  const factory permissionDenied() = LocationPermissionDenied;

  /// Location services are switched off.
  const factory servicesOff() = LocationServicesOff;

  /// No acceptable fix: none, too old, too coarse, timed out, or the
  /// context store failed ([reason] says which; §15 D73).
  const factory unavailable(String reason) = LocationUnavailable;
}

/// `LOC_PERMISSION_DENIED`.
final class LocationPermissionDenied extends LocationFailure {
  /// The failure.
  const new();

  @override
  FailureCode get code => FailureCode.locPermissionDenied;

  @override
  bool operator ==(Object other) => other is LocationPermissionDenied;

  @override
  int get hashCode => (LocationPermissionDenied).hashCode;

  @override
  String toString() => 'LocationPermissionDenied()';
}

/// `LOC_SERVICES_OFF`.
final class LocationServicesOff extends LocationFailure {
  /// The failure.
  const new();

  @override
  FailureCode get code => FailureCode.locServicesOff;

  @override
  bool operator ==(Object other) => other is LocationServicesOff;

  @override
  int get hashCode => (LocationServicesOff).hashCode;

  @override
  String toString() => 'LocationServicesOff()';
}

/// `LOC_UNAVAILABLE`.
final class LocationUnavailable extends LocationFailure {
  /// The failure, with a [reason] for diagnostics (no coordinates).
  const new(this.reason);

  /// Why, for diagnostics.
  final String reason;

  @override
  FailureCode get code => FailureCode.locUnavailable;

  @override
  bool operator ==(Object other) =>
      other is LocationUnavailable && other.reason == reason;

  @override
  int get hashCode => Object.hash(LocationUnavailable, reason);

  @override
  String toString() => 'LocationUnavailable($reason)';
}
