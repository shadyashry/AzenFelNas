import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';

/// Localised copy of every [AthanHealthReason] (exhaustive, §17.1 O).
extension AthanReasonCopy on AppLocalizations {
  /// The user-facing sentence for [reason].
  String athanReason(AthanHealthReason reason) => switch (reason) {
    AthanHealthReason.needsNotificationPermission =>
      athanReasonNeedsNotificationPermission,
    AthanHealthReason.needsExactAlarmPermission =>
      athanReasonNeedsExactAlarmPermission,
    AthanHealthReason.needsAlarmKitAuthorization =>
      athanReasonNeedsAlarmKitAuthorization,
    AthanHealthReason.mutedChannel => athanReasonMutedChannel,
    AthanHealthReason.batteryRestricted => athanReasonBatteryRestricted,
    AthanHealthReason.stalePlan => athanReasonStalePlan,
    AthanHealthReason.horizonEnding => athanReasonHorizonEnding,
    AthanHealthReason.failedTest => athanReasonFailedTest,
    AthanHealthReason.clockSkew => athanReasonClockSkew,
    AthanHealthReason.noSoundAsset => athanReasonNoSoundAsset,
    AthanHealthReason.inexactFallback => athanReasonInexactFallback,
    AthanHealthReason.unverifiableDelivery => athanReasonUnverifiableDelivery,
    AthanHealthReason.forceStoppedPreviously =>
      athanReasonForceStoppedPreviously,
  };
}
