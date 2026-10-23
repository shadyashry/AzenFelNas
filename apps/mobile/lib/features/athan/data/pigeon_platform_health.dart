import 'package:daily_muslim/features/athan/application/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/health_probe.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/services.dart';

/// [ReadPlatformHealth] over pigeon `AthanSchedulerApi.health` (§7.8). A
/// missing host (`PlatformException`) is "nothing known", never an error
/// that could read as ready.
final class PigeonPlatformHealth implements ReadPlatformHealth {
  /// The adapter over [_api]; fallbacks are stamped by [_clock].
  const new(this._api, this._clock);

  final AthanSchedulerApi _api;
  final Clock _clock;

  @override
  Future<PlatformHealth> call() async {
    try {
      final report = await _api.health();
      return PlatformHealth(
        path: DeliveryPath.ofWire(report.platformPath),
        probes: [
          for (final p in report.probes)
            HealthProbe(p.name, positive: p.positive),
        ],
        evaluatedAtUtcMs: report.evaluatedAtUtcMs,
      );
    } on PlatformException {
      return PlatformHealth.unavailable(_clock.nowUtcMs());
    }
  }
}
