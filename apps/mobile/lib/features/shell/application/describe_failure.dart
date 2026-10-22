import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Maps any typed failure to its `Needs attention` state (§10.2,
/// REQ-ERR-002). Exhaustive over Appendix J: a new code does not compile
/// until it has a remediation.
final class DescribeFailure {
  /// The use case.
  const new();

  /// The notice for [failure].
  NeedsAttention call(Failure failure) =>
      NeedsAttention(code: failure.code, remediation: of(failure.code));

  /// The remediation of [code].
  static Remediation of(FailureCode code) => switch (code) {
    FailureCode.locPermissionDenied => Remediation.grantLocationPermission,
    FailureCode.locServicesOff => Remediation.turnOnLocationServices,
    FailureCode.locUnavailable ||
    FailureCode.locStale ||
    FailureCode.tzUnresolved ||
    FailureCode.countryUnresolved => Remediation.chooseManualPlace,
    FailureCode.profileNotFound ||
    FailureCode.profileOverlap ||
    FailureCode.profileInvalid ||
    FailureCode.engineOrdering ||
    FailureCode.engineUnsupportedPolicy ||
    FailureCode.hijriUnknownMonth ||
    FailureCode.pkgSigInvalid ||
    FailureCode.pkgHashMismatch ||
    FailureCode.pkgIncompatible ||
    FailureCode.pkgSequenceRegression ||
    FailureCode.audioAssetMissing => Remediation.waitForDataUpdate,
    FailureCode.pkgExpiredWarning ||
    FailureCode.pkgNetwork => Remediation.retryWhenOnline,
    FailureCode.pkgStorage => Remediation.freeUpStorage,
    FailureCode.planWriteFailed ||
    FailureCode.diagExportFailed => Remediation.tryAgain,
    FailureCode.planSchemaUnsupported ||
    FailureCode.dbMigrationFailed => Remediation.updateApp,
    FailureCode.alarmPermissionMissing => Remediation.grantAlarmPermission,
    FailureCode.alarmScheduleFailed => Remediation.openAthanHealth,
    FailureCode.clockSkew => Remediation.checkDeviceClock,
  };
}
