import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:meta/meta.dart';

/// How one probe moves Athan Health on one path (D81, D82): variation is a
/// sealed type (§17.1 O).
@immutable
sealed class ProbeRule {
  const new();
}

/// `false` ⇒ `notReady` with [reason].
final class BlockingProbe extends ProbeRule {
  /// A blocking probe.
  const new(this.reason);

  /// The reason a `false` result adds.
  final AthanHealthReason reason;
}

/// `false` ⇒ at most `limited`; [reason] is null for probes with no reason
/// of their own (iOS silent switch and Focus).
final class DegradingProbe extends ProbeRule {
  /// A degrading probe.
  const new(this.reason);

  /// The reason a `false` result adds, if any.
  final AthanHealthReason? reason;
}

/// `false` adds [reason] without changing the state (REQ-ALM-025).
final class AdvisoryProbe extends ProbeRule {
  /// An advisory probe.
  const new(this.reason);

  /// The reason a `false` result adds.
  final AthanHealthReason reason;
}

/// Shown in diagnostics only.
final class InformationalProbe extends ProbeRule {
  /// An informational probe.
  const new();
}

/// A probe this build does not know: anything but `true` is `unknown`, since
/// an unknown signal never implies readiness (§0.2 rule 10).
final class UnrecognisedProbe extends ProbeRule {
  /// An unrecognised probe.
  const new();
}
