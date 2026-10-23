import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/health_probe.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';

/// An Android exact-path report with every blocking and degrading probe
/// positive, except [overrides].
PlatformHealth androidReport([Map<String, bool?> overrides = const {}]) =>
    PlatformHealth(
      path: DeliveryPath.androidExact,
      probes: [
        for (final n in const [
          'areNotificationsEnabled',
          'planPresent',
          'soundAssetPresence',
          'canScheduleExactAlarms',
          'channelImportance',
          'backgroundUnrestricted',
          'planHorizon',
        ])
          HealthProbe(
            n,
            positive: overrides.containsKey(n) ? overrides[n] : true,
          ),
      ],
      evaluatedAtUtcMs: 0,
    );
