import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:flutter/services.dart';

/// [ArmAthanTest] over pigeon `AthanSchedulerApi.startTest` (§7.8); a
/// missing host is a refusal.
final class PigeonArmAthanTest implements ArmAthanTest {
  /// The adapter over [_api].
  const new(this._api);

  final AthanSchedulerApi _api;

  @override
  Future<bool> call({
    required String testId,
    required int fireInSeconds,
    required String soundId,
  }) async {
    try {
      return await _api.startTest(testId, fireInSeconds, soundId);
    } on PlatformException {
      return false;
    }
  }
}
