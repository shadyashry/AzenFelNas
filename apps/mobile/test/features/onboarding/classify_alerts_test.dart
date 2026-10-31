import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/onboarding/application/classify_alerts.dart';
import 'package:daily_muslim/features/onboarding/domain/alert_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const classify = ClassifyAlerts();

  group('REQ-UX-055 alerts on the setup-completion screen come from the '
      "phone's probes", () {
    test('while Athan Health is read, the status is checking', () {
      expect(classify(null, asked: false), isA<AlertsChecking>());
    });

    test('missing notifications and exact alarms are pending, and set up '
        'asks for both, in order', () {
      final status = classify(
        const AthanHealthNotReady([
          AthanHealthReason.needsNotificationPermission,
          AthanHealthReason.needsExactAlarmPermission,
        ]),
        asked: false,
      );
      expect(status, isA<AlertsPending>());
      expect((status as AlertsPending).grants, [
        AthanGrant.notifications,
        AthanGrant.exactAlarms,
      ]);
    });

    test('a phone that cannot tell is pending, never enabled', () {
      final status = classify(const AthanHealthUnknown(), asked: false);
      expect(status, isA<AlertsPending>());
    });

    test('every grant held is enabled, even before Home writes the plan', () {
      expect(
        classify(const AthanHealthReady(), asked: false),
        isA<AlertsEnabled>(),
      );
      expect(
        classify(
          const AthanHealthNotReady([AthanHealthReason.stalePlan]),
          asked: false,
        ),
        isA<AlertsEnabled>(),
      );
    });

    test('an advisory reason (an earlier force stop) does not hold back '
        'enabled', () {
      expect(
        classify(
          const AthanHealthNotReady([
            AthanHealthReason.stalePlan,
            AthanHealthReason.forceStoppedPreviously,
          ]),
          asked: true,
        ),
        isA<AlertsEnabled>(),
      );
    });

    test('only exact alarms left after setup is partial: needs attention '
        'with the alarms screen', () {
      final status = classify(
        const AthanHealthLimited([AthanHealthReason.needsExactAlarmPermission]),
        asked: true,
      );
      expect(status, isA<AlertsNeedAttention>());
      expect((status as AlertsNeedAttention).grant, AthanGrant.exactAlarms);
    });

    test('notifications still refused after setup open the app settings, '
        'since the prompt may not show again', () {
      final status = classify(
        const AthanHealthNotReady([
          AthanHealthReason.needsNotificationPermission,
        ]),
        asked: true,
      );
      expect((status as AlertsNeedAttention).grant, AthanGrant.appSettings);
    });

    test('a battery restriction needs attention without a prompt', () {
      final status = classify(
        const AthanHealthLimited([AthanHealthReason.batteryRestricted]),
        asked: false,
      );
      expect((status as AlertsNeedAttention).grant, AthanGrant.appSettings);
    });

    test('a weakness no setting fixes is not reported as enabled', () {
      final status = classify(
        const AthanHealthLimited([AthanHealthReason.unverifiableDelivery]),
        asked: false,
      );
      expect(status, isA<AlertsNeedAttention>());
      expect((status as AlertsNeedAttention).grant, isNull);
    });
  });
}
