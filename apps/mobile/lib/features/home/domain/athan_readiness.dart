import 'package:meta/meta.dart';

/// Athan readiness as Home summarises it (§18.4 `ready(…, health, …)`).
/// Athan Health (S19–S22) adds `ready`, `limited` and `notReady`; until it
/// exists the honest summary is `unknown` (§0.2 rule 10).
@immutable
sealed class AthanReadiness {
  const new();
}

/// Not evaluated: no Athan path exists in this build yet.
final class AthanReadinessUnknown extends AthanReadiness {
  /// The summary.
  const new();

  @override
  bool operator ==(Object other) => other is AthanReadinessUnknown;

  @override
  int get hashCode => (AthanReadinessUnknown).hashCode;
}
