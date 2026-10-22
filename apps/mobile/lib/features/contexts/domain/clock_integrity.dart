import 'package:daily_muslim/features/contexts/domain/time_reference.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// What the device clock looks like against trusted time (§7.6,
/// REQ-TIME-010). No variant blocks a calculation or a package.
@immutable
sealed class ClockIntegrity {
  const new();
}

/// No trusted sample yet (offline, no GNSS fix).
final class ClockUnverified extends ClockIntegrity {
  /// The state.
  const new();

  @override
  bool operator ==(Object other) => other is ClockUnverified;

  @override
  int get hashCode => (ClockUnverified).hashCode;

  @override
  String toString() => 'ClockUnverified()';
}

/// Every sample is within the limit; [worstSkewMs] is the largest gap.
final class ClockConsistent extends ClockIntegrity {
  /// The state.
  const new(this.worstSkewMs);

  /// Largest absolute skew seen (ms).
  final int worstSkewMs;

  @override
  bool operator ==(Object other) =>
      other is ClockConsistent && other.worstSkewMs == worstSkewMs;

  @override
  int get hashCode => Object.hash(ClockConsistent, worstSkewMs);

  @override
  String toString() => 'ClockConsistent($worstSkewMs ms)';
}

/// `Needs attention`: [reference] disagrees by more than the limit.
final class ClockSkewed extends ClockIntegrity {
  /// The state.
  const new(this.reference);

  /// The sample with the largest skew.
  final TimeReference reference;

  /// Device minus reference (ms).
  int get skewMs => reference.skewMs;

  /// `CLOCK_SKEW`.
  FailureCode get code => FailureCode.clockSkew;

  @override
  bool operator ==(Object other) =>
      other is ClockSkewed && other.reference == reference;

  @override
  int get hashCode => Object.hash(ClockSkewed, reference);

  @override
  String toString() => 'ClockSkewed($reference)';
}
