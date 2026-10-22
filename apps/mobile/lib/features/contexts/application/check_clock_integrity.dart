import 'package:daily_muslim/features/contexts/domain/clock_integrity.dart';
import 'package:daily_muslim/features/contexts/domain/time_reference.dart';

/// Compares the device clock with trusted time samples (§7.6,
/// REQ-TIME-010). Pure: callers gather the samples (GNSS fix time, CDN
/// `Date` header) and show `Needs attention` for [ClockSkewed]; nothing is
/// ever rejected because of the clock.
final class CheckClockIntegrity {
  /// The check.
  const new();

  /// Largest skew that is still consistent (§7.6).
  static const maxSkew = Duration(seconds: 60);

  /// [ClockSkewed] with the worst sample when any skew exceeds [maxSkew],
  /// [ClockConsistent] otherwise, [ClockUnverified] with no samples.
  ClockIntegrity call(Iterable<TimeReference> references) {
    TimeReference? worst;
    for (final reference in references) {
      if (worst == null || reference.skewMs.abs() > worst.skewMs.abs()) {
        worst = reference;
      }
    }
    return switch (worst) {
      null => const ClockUnverified(),
      final w when w.skewMs.abs() > maxSkew.inMilliseconds => ClockSkewed(w),
      final w => ClockConsistent(w.skewMs.abs()),
    };
  }
}
