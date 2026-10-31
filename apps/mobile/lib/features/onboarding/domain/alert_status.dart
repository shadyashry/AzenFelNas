import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';

/// Where prayer alerts stand on the setup-completion screen (§15 D127),
/// read from Athan Health's probes, never from a stored preference: a saved
/// place says nothing about notifications, alarms or background audio.
sealed class AlertStatus {
  const new();
}

/// The probes are being read.
final class AlertsChecking extends AlertStatus {
  /// The state.
  const new();
}

/// Alerts are optional and not set up yet: *Set up prayer alerts* asks for
/// [grants], each one system prompt or settings screen.
final class AlertsPending extends AlertStatus {
  /// Pending; [grants] is never empty.
  const new(this.grants);

  /// What *Set up prayer alerts* asks for, in order.
  final List<AthanGrant> grants;
}

/// Every capability the Athan needs that the user can grant is granted.
final class AlertsEnabled extends AlertStatus {
  /// The state.
  const new();
}

/// Setup was tried, or something the user cannot fix from a prompt stands in
/// the way: [reason] is the first thing missing, [grant] what opens its
/// fix, or `null` when no setting fixes it.
final class AlertsNeedAttention extends AlertStatus {
  /// The state.
  const new({this.reason, this.grant});

  /// The first missing capability, or `null` when the phone cannot tell.
  final AthanHealthReason? reason;

  /// What *Review alert settings* opens, or `null` for nothing.
  final AthanGrant? grant;
}
