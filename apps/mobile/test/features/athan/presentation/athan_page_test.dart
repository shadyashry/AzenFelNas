import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/presentation/athan_page.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/fake_athan_grant.dart';
import '../../../support/state_harness.dart';
import '../support/athan_overrides.dart';
import '../support/fake_athan_platform.dart';
import '../support/health_reports.dart';

final class _Writes implements WriteSetting {
  final writes = <String, Object?>{};

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async =>
      writes[key.wire] = value;
}

Widget _page({
  required FakeAthanPlatform platform,
  required List<String> sounds,
  String? soundId,
  _Writes? writes,
  FakeAthanGrant? grant,
  Map<String, bool> enabled = const {},
  Locale locale = const Locale('en'),
}) => localizedApp(
  const AthanPage(),
  locale: locale,
  overrides: [
    ...athanOverrides(
      platform,
      <EventLogEntry>[],
      sounds: sounds,
      grant: grant,
    ),
    athanEnabledSettingProvider.overrideWith((ref) => Stream.value(enabled)),
    writeSettingProvider.overrideWithValue(writes ?? _Writes()),
    athanSoundSettingProvider.overrideWith((ref) => Stream.value(soundId)),
    fajrSoundSettingProvider.overrideWith((ref) => Stream.value(null)),
    preReminderSettingProvider.overrideWith((ref) => Stream.value(0)),
  ],
);

/// A phone screen: the Athan page opens with its readiness medallion, so
/// the sound settings sit below an 800 × 600 test window (§15 D89).
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('REQ-ALM-003 not ready shows the state and every reason, and '
      'the Test needs a sound', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
        platform: FakeAthanPlatform(
          report: androidReport({
            'areNotificationsEnabled': false,
            'channelImportance': false,
          }),
        ),
        sounds: const [],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Not ready: the Athan will not sound'), findsOneWidget);
    expect(find.text('Allow notifications for Azen Fel Nas'), findsOneWidget);
    expect(
      find.text('The Athan sound is muted in system settings'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Fajr Athan voice'), 200);
    // With nothing on the phone the device tone plays (§15 D79, D111), and
    // the Test can ring it (§15 D115).
    expect(find.text('Phone alarm tone'), findsOneWidget);
    expect(find.text('Play a test Athan in 10 seconds'), findsOneWidget);
    expect(find.text('Choose an Athan sound first'), findsNothing);
  });

  testWidgets('REQ-ALM-003 no native layer reads as unknown, never ready', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(platform: FakeAthanPlatform(), sounds: const []),
    );
    await tester.pumpAndSettle();
    expect(find.text('Not available · the phone cannot tell'), findsOneWidget);
    expect(find.textContaining('Ready'), findsNothing);
  });

  testWidgets('REQ-ALM-040 tapping the Test arms it and shows the countdown', (
    tester,
  ) async {
    _phone(tester);
    final platform = FakeAthanPlatform(report: androidReport());
    await tester.pumpWidget(
      _page(platform: platform, sounds: const ['makkah'], soundId: 'makkah'),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ready: the Athan will sound'), findsOneWidget);
    await tester.tap(find.text('Play a test Athan in 10 seconds'));
    await tester.pumpAndSettle();
    expect(find.text('Test Athan in 10 s'), findsOneWidget);
    expect(platform.armedTests, hasLength(1));
  });

  testWidgets('REQ-ALM-042 the pre-reminder offers only the allowed offsets '
      'and stores minutes', (tester) async {
    _phone(tester);
    final writes = _Writes();
    await tester.pumpWidget(
      _page(platform: FakeAthanPlatform(), sounds: const [], writes: writes),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Off'));
    await tester.pumpAndSettle();
    for (final m in [5, 10, 15, 30]) {
      expect(find.text('$m min before'), findsOneWidget);
    }
    await tester.tap(find.text('15 min before'));
    await tester.pumpAndSettle();
    expect(writes.writes, {'preReminderMinutes': 15});
  });

  testWidgets('REQ-UX-030 the page lays out in Arabic (RTL) without overflow', (
    tester,
  ) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
        platform: FakeAthanPlatform(report: androidReport()),
        sounds: const ['makkah'],
        soundId: 'makkah',
        locale: const Locale('ar'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('جاهز: سيُرفع الأذان'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REQ-ALM-026 a missing permission offers its fix: Allow asks '
      'the system, a muted channel opens settings', (tester) async {
    _phone(tester);
    final grant = FakeAthanGrant();
    await tester.pumpWidget(
      _page(
        platform: FakeAthanPlatform(
          report: androidReport({
            'areNotificationsEnabled': false,
            'channelImportance': false,
          }),
        ),
        sounds: const [],
        grant: grant,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Allow'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(grant.asked, [AthanGrant.notifications, AthanGrant.appSettings]);
  });

  testWidgets('the five prayers alert until the user chooses; a switch '
      'stores the whole choice', (tester) async {
    _phone(tester);
    final writes = _Writes();
    await tester.pumpWidget(
      _page(platform: FakeAthanPlatform(), sounds: const [], writes: writes),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Isha'), 200);
    final switches = find.byType(SwitchListTile);
    expect(switches, findsNWidgets(5));
    expect(
      tester.widgetList<SwitchListTile>(switches).map((s) => s.value),
      everyElement(isTrue),
    );
    await tester.tap(find.text('Fajr'));
    await tester.pumpAndSettle();
    expect(writes.writes['athanEnabled'], {
      'imsak': false,
      'fajr': false,
      'sunrise': false,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    });
  });

  testWidgets('a bundled test sound is named as one', (tester) async {
    _phone(tester);
    await tester.pumpWidget(
      _page(
        platform: FakeAthanPlatform(report: androidReport()),
        sounds: const ['test_cc0_adhan'],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Test Athan (not for release)'), findsOneWidget);
    expect(find.text('test_cc0_adhan'), findsNothing);
  });
}
