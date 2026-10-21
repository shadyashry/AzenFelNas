import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:meta/meta.dart';

/// An expired role: the client keeps calculating and shows
/// `FRESHNESS_UNVERIFIED`; it never blocks (REQ-PKG-002).
@immutable
final class FreshnessWarning {
  /// [role] expired at [expiresUtcMs].
  const new({required this.role, required this.expiresUtcMs});

  /// The Appendix J code the warning is logged with.
  static const FailureCode code = FailureCode.pkgExpiredWarning;

  /// The expired role.
  final MetadataRole role;

  /// Its expiry, UTC epoch milliseconds.
  final int expiresUtcMs;

  @override
  bool operator ==(Object other) =>
      other is FreshnessWarning &&
      other.role == role &&
      other.expiresUtcMs == expiresUtcMs;

  @override
  int get hashCode => Object.hash(FreshnessWarning, role, expiresUtcMs);

  @override
  String toString() => 'FreshnessWarning(${role.name}, $expiresUtcMs)';
}
