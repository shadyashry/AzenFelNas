import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';

/// The ARB text of each [Remediation] (§7.11: copy stays out of code).
abstract final class RemediationCopy {
  /// The localised action for [remediation].
  static String of(
    AppLocalizations l,
    Remediation remediation,
  ) => switch (remediation) {
    Remediation.grantLocationPermission => l.remediationGrantLocationPermission,
    Remediation.turnOnLocationServices => l.remediationTurnOnLocationServices,
    Remediation.chooseManualPlace => l.remediationChooseManualPlace,
    Remediation.waitForDataUpdate => l.remediationWaitForDataUpdate,
    Remediation.retryWhenOnline => l.remediationRetryWhenOnline,
    Remediation.freeUpStorage => l.remediationFreeUpStorage,
    Remediation.tryAgain => l.remediationTryAgain,
    Remediation.updateApp => l.remediationUpdateApp,
    Remediation.grantAlarmPermission => l.remediationGrantAlarmPermission,
    Remediation.openAthanHealth => l.remediationOpenAthanHealth,
    Remediation.checkDeviceClock => l.remediationCheckDeviceClock,
  };
}
