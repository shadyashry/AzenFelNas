import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why a `tz_polygons` or `country_polygons` payload could not be read
/// (§9.5, §15 D70).
///
/// As for `TzdbFailure`, a payload that passed its hash and signature checks
/// but does not parse is `PKG_SIG_INVALID` (§15 D59); the caller keeps the
/// last-known-good index (REQ-PKG-001).
@immutable
sealed class PolygonIndexFailure implements Failure {
  const new();

  /// The payload is not a valid polygon index of the expected dataset.
  const factory payloadInvalid(String reason) = PolygonPayloadInvalid;

  /// Human-readable cause, for the event log and diagnostics; it never
  /// contains a coordinate of the user.
  String get detail;
}

/// [PolygonIndexFailure.payloadInvalid]: `PKG_SIG_INVALID`.
final class PolygonPayloadInvalid extends PolygonIndexFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What is wrong with the payload.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgSigInvalid;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is PolygonPayloadInvalid && other.reason == reason;

  @override
  int get hashCode => Object.hash(PolygonPayloadInvalid, reason);

  @override
  String toString() => 'PolygonPayloadInvalid($reason)';
}
