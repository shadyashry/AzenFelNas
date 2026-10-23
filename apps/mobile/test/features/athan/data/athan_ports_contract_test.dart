import 'dart:convert';

import 'package:daily_muslim/features/athan/data/pigeon_arm_athan_test.dart';
import 'package:daily_muslim/features/athan/data/pigeon_drain_native_events.dart';
import 'package:daily_muslim/features/athan/data/pigeon_platform_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/health_probe.dart';
import 'package:daily_muslim/features/athan/domain/native_event.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_athan_platform.dart';

const _prefix = 'dev.flutter.pigeon.dm_contracts.AthanSchedulerApi';

/// Answers [method] on the pigeon channel with [reply] (a success envelope).
void _host(String method, Object? reply) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('$_prefix.$method', (message) async {
        return AthanSchedulerApi.pigeonChannelCodec.encodeMessage(<Object?>[
          reply,
        ]);
      });
}

String _line(int utcMs, String code, Map<String, Object> attrs) => jsonEncode({
  'utcMs': utcMs,
  'level': 'INFO',
  'code': code,
  'attrs': attrs,
});

final class _Ports {
  const new(this.health, this.arm, this.drain);

  final ReadPlatformHealth health;
  final ArmAthanTest arm;
  final DrainNativeEvents drain;
}

/// The port contracts (§17.1 L): no implementation throws, and "no host"
/// is unknown/refused/empty.
void _contract(String name, _Ports Function() ports) {
  group('$name honours the Athan port contracts', () {
    test('REQ-ALM-003 health never throws and returns a report', () async {
      expect(await ports().health(), isA<PlatformHealth>());
    });

    test('REQ-ALM-040 arm never throws and returns a bool', () async {
      expect(
        await ports().arm(
          testId: 'a1a1a1a1a1a1a1a1',
          fireInSeconds: 60,
          soundId: 's',
        ),
        isA<bool>(),
      );
    });

    test('REQ-ALM-041 drain never throws and returns a list', () async {
      expect(await ports().drain(), isA<List<NativeEvent>>());
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final appended = <EventLogEntry>[];

  _Ports pigeon() {
    final api = AthanSchedulerApi();
    return _Ports(
      PigeonPlatformHealth(api, FixedClock(42)),
      PigeonArmAthanTest(api),
      PigeonDrainNativeEvents(api, (e) async => appended.add(e)),
    );
  }

  _contract('the fake', () {
    final fake = FakeAthanPlatform();
    return _Ports(fake, fake.arm, fake.drain);
  });
  _contract('the pigeon adapters without a host', pigeon);

  group('pigeon adapters', () {
    tearDown(() {
      appended.clear();
      for (final m in ['health', 'startTest', 'drainEvents']) {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('$_prefix.$m', null);
      }
    });

    test(
      'REQ-ALM-003 no host is an unavailable report with no probes',
      () async {
        final report = await pigeon().health();
        expect(report.path, DeliveryPath.unavailable);
        expect(report.probes, isEmpty);
        expect(report.evaluatedAtUtcMs, 42);
      },
    );

    test('REQ-ALM-003 a host report keeps path and null probes', () async {
      _host(
        'health',
        AthanHealthReport(
          state: HealthState.ready,
          reasons: const [],
          probes: [
            ProbeResult(name: 'planPresent', positive: true),
            ProbeResult(name: 'silentSwitch'),
          ],
          evaluatedAtUtcMs: 7,
          platformPath: 'iosNotification',
        ),
      );
      final report = await pigeon().health();
      expect(report.path, DeliveryPath.iosNotification);
      expect(report.probes, const [
        HealthProbe('planPresent', positive: true),
        HealthProbe('silentSwitch', positive: null),
      ]);
    });

    test(
      'REQ-ALM-040 no host refuses the Test; a host answer is passed on',
      () async {
        expect(
          await pigeon().arm(
            testId: 'a1a1a1a1a1a1a1a1',
            fireInSeconds: 60,
            soundId: 's',
          ),
          isFalse,
        );
        _host('startTest', true);
        expect(
          await pigeon().arm(
            testId: 'a1a1a1a1a1a1a1a1',
            fireInSeconds: 60,
            soundId: 's',
          ),
          isTrue,
        );
      },
    );

    test('REQ-ALM-041 drained lines are appended to the event log; invalid '
        'lines (and any coordinate key) are dropped', () async {
      _host('drainEvents', <String>[
        _line(1, 'TEST_STARTED', {'entryId': 'a1a1a1a1a1a1a1a1'}),
        'not json',
        _line(2, 'ALARM_PRESENTED', {'lat': 30.1}),
        _line(3, 'ALARM_PRESENTED', {
          'entryId': 'a1a1a1a1a1a1a1a1',
          'reason': 'user_open',
        }),
      ]);
      final events = await pigeon().drain();
      expect(events, const [
        NativeEvent(EventCode.testStarted, entryId: 'a1a1a1a1a1a1a1a1'),
        NativeEvent(EventCode.alarmPresented, entryId: 'a1a1a1a1a1a1a1a1'),
      ]);
      expect([for (final e in appended) e.utcMs], [1, 3]);
    });
  });
}
