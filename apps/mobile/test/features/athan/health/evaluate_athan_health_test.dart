import 'package:daily_muslim/features/athan/application/evaluate_athan_health.dart';
import 'package:daily_muslim/features/athan/application/probe_rules.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/health_probe.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';
import 'package:daily_muslim/features/athan/domain/probe_rule.dart';
import 'package:flutter_test/flutter_test.dart';

const _android = [
  'areNotificationsEnabled',
  'planPresent',
  'soundAssetPresence',
  'canScheduleExactAlarms',
  'channelImportance',
  'backgroundUnrestricted',
  'planHorizon',
  'previousForceStop',
  'isIgnoringBatteryOptimizations',
  'dndAlarmPolicy',
];

const _ios = [
  'alarmKitAuthorization',
  'notificationAuthorization',
  'notificationSound',
  'soundAssetPresence',
  'planPresent',
  'planHorizon',
  'deliveryVerified',
  'silentSwitch',
  'focusStatus',
  'backgroundRefreshStatus',
  'criticalAlerts',
];

PlatformHealth _report(
  DeliveryPath path,
  List<String> names, [
  Map<String, bool?> overrides = const {},
]) => PlatformHealth(
  path: path,
  probes: [
    for (final n in names)
      HealthProbe(n, positive: overrides.containsKey(n) ? overrides[n] : true),
  ],
  evaluatedAtUtcMs: 0,
);

/// Every assignment of {true, false, null} to [n] probes.
Iterable<List<bool?>> _outcomes(int n) sync* {
  const values = <bool?>[true, false, null];
  final digits = List<int>.filled(n, 0);
  while (true) {
    yield [for (final d in digits) values[d]];
    var i = 0;
    while (i < n && digits[i] == 2) {
      digits[i] = 0;
      i++;
    }
    if (i == n) return;
    digits[i]++;
  }
}

void main() {
  const evaluate = EvaluateAthanHealth();

  group('EvaluateAthanHealth (§8.3, D81, D82)', () {
    test(
      'REQ-ALM-003 all Android probes positive on the exact path is ready',
      () {
        expect(
          evaluate(_report(DeliveryPath.androidExact, _android)),
          const AthanHealthReady(),
        );
      },
    );

    test('REQ-ALM-003 a null blocking probe is unknown, never ready', () {
      expect(
        evaluate(
          _report(DeliveryPath.androidExact, _android, {'planPresent': null}),
        ),
        const AthanHealthUnknown(),
      );
    });

    test('REQ-ALM-003 an unrecognised probe that is not true is unknown', () {
      expect(
        evaluate(
          _report(
            DeliveryPath.androidExact,
            [..._android, 'newProbe'],
            {
              'newProbe': false,
            },
          ),
        ),
        const AthanHealthUnknown(),
      );
    });

    test('REQ-ALM-003 no probes, or no native layer, is unknown', () {
      expect(
        evaluate(_report(DeliveryPath.androidExact, const [])),
        const AthanHealthUnknown(),
      );
      expect(
        evaluate(PlatformHealth.unavailable(0)),
        const AthanHealthUnknown(),
      );
    });

    test('REQ-ALM-003 blocking false beats degrading false and null', () {
      expect(
        evaluate(
          _report(DeliveryPath.androidExact, _android, {
            'areNotificationsEnabled': false,
            'channelImportance': false,
            'planHorizon': null,
            'previousForceStop': false,
          }),
        ),
        const AthanHealthNotReady([
          AthanHealthReason.needsNotificationPermission,
          AthanHealthReason.mutedChannel,
          AthanHealthReason.forceStoppedPreviously,
        ]),
      );
    });

    test('REQ-ALM-003 degrading false beats null: limited with its reason', () {
      expect(
        evaluate(
          _report(DeliveryPath.androidExact, _android, {
            'backgroundUnrestricted': false,
            'planPresent': null,
          }),
        ),
        const AthanHealthLimited([AthanHealthReason.batteryRestricted]),
      );
    });

    test(
      'REQ-ALM-025 a previous force-stop is advisory: ready with reason',
      () {
        expect(
          evaluate(
            _report(DeliveryPath.androidExact, _android, {
              'previousForceStop': false,
            }),
          ),
          const AthanHealthReady([AthanHealthReason.forceStoppedPreviously]),
        );
      },
    );

    test('REQ-ALM-027 the inexact path is limited(inexactFallback)', () {
      expect(
        evaluate(
          _report(DeliveryPath.androidInexact, _android, {
            'canScheduleExactAlarms': false,
          }),
        ),
        const AthanHealthLimited([AthanHealthReason.inexactFallback]),
      );
      expect(
        evaluate(_report(DeliveryPath.androidInexact, _android)),
        const AthanHealthLimited([AthanHealthReason.inexactFallback]),
      );
    });

    test('REQ-ALM-033 the iOS notification path with every probe positive is '
        'limited(unverifiableDelivery)', () {
      expect(
        evaluate(_report(DeliveryPath.iosNotification, _ios)),
        const AthanHealthLimited([AthanHealthReason.unverifiableDelivery]),
      );
    });

    test('REQ-ALM-003 silent switch and Focus gate only the iOS notification '
        'path', () {
      final unknownSwitch = {'silentSwitch': null, 'focusStatus': null};
      expect(
        evaluate(_report(DeliveryPath.iosAlarmKit, _ios, unknownSwitch)),
        const AthanHealthReady(),
      );
      expect(
        evaluate(
          _report(DeliveryPath.iosAlarmKit, _ios, {
            ...unknownSwitch,
            'deliveryVerified': false,
          }),
        ),
        const AthanHealthLimited([AthanHealthReason.unverifiableDelivery]),
      );
    });

    test('REQ-ALM-003 notification authorisation blocks on the notification '
        'path and degrades on AlarmKit', () {
      final denied = {'notificationAuthorization': false};
      expect(
        evaluate(_report(DeliveryPath.iosNotification, _ios, denied)),
        isA<AthanHealthNotReady>(),
      );
      expect(
        evaluate(_report(DeliveryPath.iosAlarmKit, _ios, denied)),
        const AthanHealthLimited([
          AthanHealthReason.needsNotificationPermission,
        ]),
      );
    });

    test('REQ-ALM-040 a Test the user did not hear is limited(failedTest)', () {
      final report = _report(DeliveryPath.androidExact, _android);
      expect(
        evaluate(report, lastTestHeard: false),
        const AthanHealthLimited([AthanHealthReason.failedTest]),
      );
      expect(evaluate(report, lastTestHeard: true), const AthanHealthReady());
    });

    test('REQ-ALM-003 property: over every Android outcome (3^10), ready iff '
        'every blocking and degrading probe is true', () {
      const rules = ProbeRules();
      for (final outcome in _outcomes(_android.length)) {
        final report = _report(DeliveryPath.androidExact, _android, {
          for (var i = 0; i < _android.length; i++) _android[i]: outcome[i],
        });
        final mustBeTrue = [
          for (var i = 0; i < _android.length; i++)
            if (rules.of(DeliveryPath.androidExact, _android[i])
                case BlockingProbe() || DegradingProbe())
              outcome[i],
        ];
        expect(
          evaluate(report) is AthanHealthReady,
          mustBeTrue.every((p) => p == true),
          reason: '$outcome',
        );
      }
    });

    test('REQ-ALM-033 property: the iOS notification path is never ready over '
        'every outcome (3^11)', () {
      for (final outcome in _outcomes(_ios.length)) {
        final report = _report(DeliveryPath.iosNotification, _ios, {
          for (var i = 0; i < _ios.length; i++) _ios[i]: outcome[i],
        });
        expect(evaluate(report), isNot(isA<AthanHealthReady>()));
      }
    });
  });
}
