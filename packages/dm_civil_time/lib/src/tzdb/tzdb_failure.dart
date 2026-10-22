import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why a `tzdata` payload could not become a [Failure]-free database
/// (DESIGN.md §9.5, §15 D66).
///
/// Appendix J has no "malformed package" code, so a payload that passed its
/// hash and signature checks but does not parse is `PKG_SIG_INVALID`, as
/// §15 D59 decided for malformed metadata. The caller keeps the
/// last-known-good database (REQ-PKG-001).
@immutable
sealed class TzdbFailure implements Failure {
  const new();

  /// The payload or its version is not a valid `.tzf` database.
  const factory payloadInvalid(String reason) = TzdbPayloadInvalid;

  /// Human-readable cause, for the event log and diagnostics; it never
  /// contains a coordinate.
  String get detail;
}

/// [TzdbFailure.payloadInvalid]: `PKG_SIG_INVALID`.
final class TzdbPayloadInvalid extends TzdbFailure {
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
      other is TzdbPayloadInvalid && other.reason == reason;

  @override
  int get hashCode => Object.hash(TzdbPayloadInvalid, reason);

  @override
  String toString() => 'TzdbPayloadInvalid($reason)';
}
