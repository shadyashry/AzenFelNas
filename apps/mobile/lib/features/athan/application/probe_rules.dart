import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/probe_rule.dart';

/// The probe table of D81 (Android, Kotlin `ProbeName`) and D82 (iOS, Swift
/// `ProbeName.severity(on:)`), mirrored so Dart derives Health itself.
final class ProbeRules {
  /// The table.
  const new();

  /// How probe [name] counts on [path].
  ProbeRule of(DeliveryPath path, String name) => switch (path) {
    DeliveryPath.androidExact || DeliveryPath.androidInexact => _android(name),
    DeliveryPath.iosAlarmKit => _ios(name, alarmKit: true),
    DeliveryPath.iosNotification => _ios(name, alarmKit: false),
    DeliveryPath.unavailable => const UnrecognisedProbe(),
  };

  static ProbeRule _android(String name) => switch (name) {
    'areNotificationsEnabled' => const BlockingProbe(
      AthanHealthReason.needsNotificationPermission,
    ),
    'planPresent' => const BlockingProbe(AthanHealthReason.stalePlan),
    'soundAssetPresence' => const BlockingProbe(AthanHealthReason.noSoundAsset),
    'canScheduleExactAlarms' => const DegradingProbe(
      AthanHealthReason.inexactFallback,
    ),
    'channelImportance' => const DegradingProbe(AthanHealthReason.mutedChannel),
    'backgroundUnrestricted' => const DegradingProbe(
      AthanHealthReason.batteryRestricted,
    ),
    'planHorizon' => const DegradingProbe(AthanHealthReason.horizonEnding),
    'previousForceStop' => const AdvisoryProbe(
      AthanHealthReason.forceStoppedPreviously,
    ),
    'isIgnoringBatteryOptimizations' ||
    'dndAlarmPolicy' => const InformationalProbe(),
    _ => const UnrecognisedProbe(),
  };

  static ProbeRule _ios(String name, {required bool alarmKit}) =>
      switch (name) {
        'alarmKitAuthorization' => const BlockingProbe(
          AthanHealthReason.needsAlarmKitAuthorization,
        ),
        'soundAssetPresence' => const BlockingProbe(
          AthanHealthReason.noSoundAsset,
        ),
        'planPresent' => const BlockingProbe(AthanHealthReason.stalePlan),
        'notificationAuthorization' =>
          alarmKit
              ? const DegradingProbe(
                  AthanHealthReason.needsNotificationPermission,
                )
              : const BlockingProbe(
                  AthanHealthReason.needsNotificationPermission,
                ),
        'notificationSound' => const DegradingProbe(
          AthanHealthReason.mutedChannel,
        ),
        'planHorizon' => const DegradingProbe(AthanHealthReason.horizonEnding),
        'deliveryVerified' => const DegradingProbe(
          AthanHealthReason.unverifiableDelivery,
        ),
        'silentSwitch' || 'focusStatus' =>
          alarmKit ? const InformationalProbe() : const DegradingProbe(null),
        'backgroundRefreshStatus' ||
        'criticalAlerts' => const InformationalProbe(),
        _ => const UnrecognisedProbe(),
      };
}
