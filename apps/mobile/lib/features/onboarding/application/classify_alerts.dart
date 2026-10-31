import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/onboarding/domain/alert_status.dart';

/// Reads [AlertStatus] from Athan Health (§8.3, §15 D127).
///
/// - **Enabled** only when no grantable reason is left and the probes are
///   known: Ready, or held back only by the plan, which Home writes once
///   onboarding ends (`stalePlan`, `horizonEnding`), or by an advisory
///   reason, which never changes the state (`forceStoppedPreviously`).
/// - **Pending** before the user asked, while notifications or exact alarms
///   are missing or the phone cannot tell.
/// - **Needs attention** otherwise. After an ask, a missing notification
///   permission is fixed in the app's settings, since the prompt may not
///   show again.
final class ClassifyAlerts {
  /// The use case.
  const new();

  /// Reasons that do not stand in the way of alerts here: the plan Home
  /// writes, and advisory reasons.
  static const Set<AthanHealthReason> _passing = {
    AthanHealthReason.stalePlan,
    AthanHealthReason.horizonEnding,
    AthanHealthReason.forceStoppedPreviously,
  };

  static const List<AthanGrant> _prompted = [
    AthanGrant.notifications,
    AthanGrant.exactAlarms,
  ];

  /// The status for [health] (`null` while it is read); [asked] once the
  /// user went through *Set up prayer alerts* in this session.
  AlertStatus call(AthanHealth? health, {required bool asked}) {
    if (health == null) return const AlertsChecking();
    final grants = [
      for (final grant in AthanGrant.values)
        if (health.reasons.any((r) => AthanGrant.of(r) == grant)) grant,
    ];
    final unknown = health is AthanHealthUnknown;
    if (grants.isEmpty &&
        !unknown &&
        (health is AthanHealthReady ||
            health.reasons.every(_passing.contains))) {
      return const AlertsEnabled();
    }
    final prompts = [
      for (final grant in grants)
        if (_prompted.contains(grant)) grant,
    ];
    if (!asked && (prompts.isNotEmpty || unknown)) {
      return AlertsPending(prompts.isEmpty ? _prompted : prompts);
    }
    final first = grants.firstOrNull;
    return AlertsNeedAttention(
      reason: health.reasons.where((r) => !_passing.contains(r)).firstOrNull,
      grant: first == AthanGrant.notifications && asked
          ? AthanGrant.appSettings
          : first,
    );
  }
}
