import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// Why the engine could not calculate a day (§6.2, REQ-ERR-001). Each
/// variant carries its Appendix J [code] (REQ-ERR-002).
@immutable
sealed class EngineFailure implements Failure {
  const new();

  /// Displayed instants violate REQ-DOM-001; [traceJson] is the offending
  /// trace.
  const factory orderingViolation(String traceJson) = OrderingViolation;

  /// The profile cannot be evaluated, for [reason].
  const factory invalidProfile(String reason) = InvalidProfile;

  /// The profile [field] selects a policy the engine does not implement.
  const factory unsupportedPolicy(String field) = UnsupportedPolicy;

  /// The TZDB does not know [zoneId].
  const factory unsupportedZone(String zoneId) = UnsupportedZone;

  /// A one-line description for logs and bench failures; never coordinates
  /// (REQ-PRIV-001).
  String get detail;
}

/// [EngineFailure.orderingViolation]: `ENGINE_ORDERING`.
final class OrderingViolation extends EngineFailure {
  /// Wraps the offending [traceJson].
  const new(this.traceJson);

  /// The calculation trace that violated the ordering.
  final String traceJson;

  @override
  FailureCode get code => FailureCode.engineOrdering;

  @override
  String get detail => 'prayer ordering violated';

  @override
  bool operator ==(Object other) =>
      other is OrderingViolation && other.traceJson == traceJson;

  @override
  int get hashCode => Object.hash(OrderingViolation, traceJson);
}

/// [EngineFailure.invalidProfile]: `PROFILE_INVALID`.
final class InvalidProfile extends EngineFailure {
  /// Wraps [reason].
  const new(this.reason);

  /// What makes the profile unusable.
  final String reason;

  @override
  FailureCode get code => FailureCode.profileInvalid;

  @override
  String get detail => reason;

  @override
  bool operator ==(Object other) =>
      other is InvalidProfile && other.reason == reason;

  @override
  int get hashCode => Object.hash(InvalidProfile, reason);
}

/// [EngineFailure.unsupportedPolicy]: `ENGINE_UNSUPPORTED_POLICY`.
final class UnsupportedPolicy extends EngineFailure {
  /// Wraps the profile [field].
  const new(this.field);

  /// The profile field whose value is not supported.
  final String field;

  @override
  FailureCode get code => FailureCode.engineUnsupportedPolicy;

  @override
  String get detail => 'unsupported policy: $field';

  @override
  bool operator ==(Object other) =>
      other is UnsupportedPolicy && other.field == field;

  @override
  int get hashCode => Object.hash(UnsupportedPolicy, field);
}

/// [EngineFailure.unsupportedZone]: `TZ_UNRESOLVED`.
final class UnsupportedZone extends EngineFailure {
  /// Wraps [zoneId].
  const new(this.zoneId);

  /// The zone the TZDB does not know.
  final String zoneId;

  @override
  FailureCode get code => FailureCode.tzUnresolved;

  @override
  String get detail => 'unsupported zone: $zoneId';

  @override
  bool operator ==(Object other) =>
      other is UnsupportedZone && other.zoneId == zoneId;

  @override
  int get hashCode => Object.hash(UnsupportedZone, zoneId);
}
