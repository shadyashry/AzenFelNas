import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';

/// What the user can grant from Athan Health so the Athan reaches them
/// (§8.3, §15 D95): each is one system prompt or settings screen.
enum AthanGrant {
  /// The notification permission (Android 13+, iOS).
  notifications,

  /// Android "Alarms & reminders" (exact alarms, Android 12+).
  exactAlarms,

  /// The app's system settings: battery, muted channels.
  appSettings;

  /// The grant that clears [reason], or null when the user has nothing to
  /// grant for it.
  static AthanGrant? of(AthanHealthReason reason) => switch (reason) {
    AthanHealthReason.needsNotificationPermission ||
    AthanHealthReason.needsAlarmKitAuthorization => AthanGrant.notifications,
    AthanHealthReason.needsExactAlarmPermission ||
    AthanHealthReason.inexactFallback => AthanGrant.exactAlarms,
    AthanHealthReason.mutedChannel ||
    AthanHealthReason.batteryRestricted => AthanGrant.appSettings,
    AthanHealthReason.stalePlan ||
    AthanHealthReason.horizonEnding ||
    AthanHealthReason.failedTest ||
    AthanHealthReason.clockSkew ||
    AthanHealthReason.noSoundAsset ||
    AthanHealthReason.unverifiableDelivery ||
    AthanHealthReason.forceStoppedPreviously => null,
  };
}

/// Shows the system prompt or settings screen for an [AthanGrant]. Returns
/// once the user is back in the app; never throws.
abstract interface class RequestAthanGrant {
  /// Asks for [grant].
  Future<void> call(AthanGrant grant);
}
