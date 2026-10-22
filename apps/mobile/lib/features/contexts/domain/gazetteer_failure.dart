import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why the gazetteer could not be imported or searched (§7.3, §15 D72).
@immutable
sealed class GazetteerFailure implements Failure {
  const new();

  /// The payload does not follow `gazetteer_package.v1`. As for the other
  /// packages, a payload that passed its hash and signature checks but does
  /// not parse is `PKG_SIG_INVALID` (§15 D59).
  const factory payloadInvalid(String reason) = GazetteerPayloadInvalid;

  /// The database refused a read or write: `PKG_STORAGE`.
  const factory storage(String reason) = GazetteerStorageFailed;

  /// Human-readable cause, for the event log and diagnostics; it never
  /// contains a coordinate of the user.
  String get detail;
}

/// [GazetteerFailure.payloadInvalid].
final class GazetteerPayloadInvalid extends GazetteerFailure {
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
      other is GazetteerPayloadInvalid && other.reason == reason;

  @override
  int get hashCode => Object.hash(GazetteerPayloadInvalid, reason);

  @override
  String toString() => 'GazetteerPayloadInvalid($reason)';
}

/// [GazetteerFailure.storage].
final class GazetteerStorageFailed extends GazetteerFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What the database reported.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgStorage;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is GazetteerStorageFailed && other.reason == reason;

  @override
  int get hashCode => Object.hash(GazetteerStorageFailed, reason);

  @override
  String toString() => 'GazetteerStorageFailed($reason)';
}
