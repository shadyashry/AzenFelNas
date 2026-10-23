import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:meta/meta.dart';

/// Athan Health (§8.3, §18.4) as Dart derives it from the platform probes.
@immutable
sealed class AthanHealth {
  const new(this.reasons);

  /// Why the state is not `ready`, advisory reasons included, in order.
  final List<AthanHealthReason> reasons;

  @override
  bool operator ==(Object other) =>
      other is AthanHealth &&
      other.runtimeType == runtimeType &&
      _sameReasons(other.reasons, reasons);

  @override
  int get hashCode => Object.hash(runtimeType, Object.hashAll(reasons));

  static bool _sameReasons(
    List<AthanHealthReason> a,
    List<AthanHealthReason> b,
  ) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// Every probe that counts is positive (REQ-ALM-003); [reasons] holds only
/// advisory reasons.
final class AthanHealthReady extends AthanHealth {
  /// Ready, with advisory [reasons].
  const new([super.reasons = const []]);
}

/// Athans should sound, with a known weakness.
final class AthanHealthLimited extends AthanHealth {
  /// Limited by [reasons].
  const new(super.reasons);
}

/// Athans will not sound until the user acts.
final class AthanHealthNotReady extends AthanHealth {
  /// Not ready because of [reasons].
  const new(super.reasons);
}

/// The platform cannot tell; never implies readiness (§0.2 rule 10).
final class AthanHealthUnknown extends AthanHealth {
  /// Unknown, with whatever [reasons] are known.
  const new([super.reasons = const []]);
}
