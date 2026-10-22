import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:meta/meta.dart';

/// Why signed package metadata or a package was refused (REQ-ERR-001). Each
/// variant carries its Appendix J [code] (REQ-ERR-002). Metadata that cannot
/// be decoded is `signatureInvalid`: what cannot be read cannot be verified
/// (§15 D59).
@immutable
sealed class PackageFailure implements Failure {
  const new();

  /// Too few valid signatures, or metadata that is malformed or breaks
  /// Appendix C, for [reason]: `PKG_SIG_INVALID`.
  const factory signatureInvalid(String reason) = PackageSignatureInvalid;

  /// A file or package that does not match the length or SHA-256 its parent
  /// pins, for [reason]: `PKG_HASH_MISMATCH`.
  const factory hashMismatch(String reason) = PackageHashMismatch;

  /// [role] carries [sequence], not strictly after the [trusted] one
  /// (REQ-PKG-005): `PKG_SEQUENCE_REGRESSION`.
  const factory sequenceRegression({
    required MetadataRole role,
    required int sequence,
    required int trusted,
  }) = PackageSequenceRegression;

  /// A target the running app cannot use: its `compat` or `schemaVersion`
  /// is beyond this build (REQ-PKG-006), for [reason]: `PKG_INCOMPATIBLE`.
  const factory incompatible(String reason) = PackageIncompatible;

  /// The CDN could not be reached or answered with an error, for [reason]:
  /// `PKG_NETWORK`.
  const factory network(String reason) = PackageNetworkFailure;

  /// A package file or the package catalog could not be read or written,
  /// for [reason]: `PKG_STORAGE`.
  const factory storage(String reason) = PackageStorageFailure;

  /// A one-line description for logs.
  String get detail;
}

/// [PackageFailure.signatureInvalid]: `PKG_SIG_INVALID`.
final class PackageSignatureInvalid extends PackageFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What failed.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgSigInvalid;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is PackageSignatureInvalid && other.reason == reason;

  @override
  int get hashCode => Object.hash(PackageSignatureInvalid, reason);

  @override
  String toString() => 'PackageSignatureInvalid($reason)';
}

/// [PackageFailure.hashMismatch]: `PKG_HASH_MISMATCH`.
final class PackageHashMismatch extends PackageFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What did not match.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgHashMismatch;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is PackageHashMismatch && other.reason == reason;

  @override
  int get hashCode => Object.hash(PackageHashMismatch, reason);

  @override
  String toString() => 'PackageHashMismatch($reason)';
}

/// [PackageFailure.sequenceRegression]: `PKG_SEQUENCE_REGRESSION`.
final class PackageSequenceRegression extends PackageFailure {
  /// [role] at [sequence] is not after [trusted].
  const new({
    required this.role,
    required this.sequence,
    required this.trusted,
  });

  /// The role whose sequence regressed.
  final MetadataRole role;

  /// The sequence received.
  final int sequence;

  /// The sequence already trusted.
  final int trusted;

  @override
  FailureCode get code => FailureCode.pkgSequenceRegression;

  @override
  String get detail =>
      '${role.name} sequence $sequence is not after the trusted $trusted';

  @override
  bool operator ==(Object other) =>
      other is PackageSequenceRegression &&
      other.role == role &&
      other.sequence == sequence &&
      other.trusted == trusted;

  @override
  int get hashCode =>
      Object.hash(PackageSequenceRegression, role, sequence, trusted);

  @override
  String toString() => 'PackageSequenceRegression($detail)';
}

/// [PackageFailure.incompatible]: `PKG_INCOMPATIBLE`.
final class PackageIncompatible extends PackageFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What happened.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgIncompatible;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is PackageIncompatible && other.reason == reason;

  @override
  int get hashCode => Object.hash(PackageIncompatible, reason);

  @override
  String toString() => 'PackageIncompatible($reason)';
}

/// [PackageFailure.network]: `PKG_NETWORK`.
final class PackageNetworkFailure extends PackageFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What happened.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgNetwork;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is PackageNetworkFailure && other.reason == reason;

  @override
  int get hashCode => Object.hash(PackageNetworkFailure, reason);

  @override
  String toString() => 'PackageNetworkFailure($reason)';
}

/// [PackageFailure.storage]: `PKG_STORAGE`.
final class PackageStorageFailure extends PackageFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What happened.
  final String reason;

  @override
  FailureCode get code => FailureCode.pkgStorage;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is PackageStorageFailure && other.reason == reason;

  @override
  int get hashCode => Object.hash(PackageStorageFailure, reason);

  @override
  String toString() => 'PackageStorageFailure($reason)';
}
