import 'package:meta/meta.dart';

/// One platform probe (§7.8 `ProbeResult`): [positive] is null when the
/// platform cannot tell, and null never implies readiness (REQ-ALM-003).
@immutable
final class HealthProbe {
  /// Probe [name] (the Kotlin or Swift label) with its [positive] result.
  const new(this.name, {required this.positive});

  /// The native probe label, e.g. `canScheduleExactAlarms`.
  final String name;

  /// True, false, or null for "cannot tell".
  final bool? positive;

  @override
  bool operator ==(Object other) =>
      other is HealthProbe && other.name == name && other.positive == positive;

  @override
  int get hashCode => Object.hash(name, positive);

  @override
  String toString() => 'HealthProbe($name, $positive)';
}
