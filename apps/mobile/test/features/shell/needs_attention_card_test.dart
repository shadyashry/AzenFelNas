import 'package:daily_muslim/features/onboarding/presentation/language_choice.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_system_settings.dart';
import '../../support/state_harness.dart';

final class _Writes implements WriteSetting {
  final writes = <String, Object?>{};

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async =>
      writes[key.wire] = value;
}

Future<void> _resume(WidgetTester tester) async {
  [
    AppLifecycleState.inactive,
    AppLifecycleState.hidden,
    AppLifecycleState.paused,
    AppLifecycleState.hidden,
    AppLifecycleState.inactive,
    AppLifecycleState.resumed,
  ].forEach(tester.binding.handleAppLifecycleStateChanged);
  await tester.pump();
}

void main() {
  group('Needs attention actions (§10.2, §15 D97)', () {
    testWidgets('REQ-ERR-002 location services off offers "Turn on location", '
        'which opens the location settings and retries on return', (
      tester,
    ) async {
      final settings = FakeSystemSettings();
      var retries = 0;
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: NeedsAttentionCard(
              const NeedsAttention(
                code: FailureCode.locServicesOff,
                remediation: Remediation.turnOnLocationServices,
              ),
              onReturn: () => retries++,
            ),
          ),
          overrides: [openSystemSettingsProvider.overrideWithValue(settings)],
        ),
      );
      await _resume(tester);
      expect(retries, 0, reason: 'no retry before the user went to settings');
      await tester.tap(find.text('Turn on location'));
      await tester.pump();
      expect(settings.opened, ['location']);
      await _resume(tester);
      expect(retries, 1);
      await _resume(tester);
      expect(retries, 1, reason: 'one retry per visit to settings');
    });

    testWidgets('a blocked permission opens the app settings; other '
        'remediations have no button', (tester) async {
      final settings = FakeSystemSettings();
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(
            body: Column(
              children: [
                NeedsAttentionCard(
                  NeedsAttention(
                    code: FailureCode.locPermissionDenied,
                    remediation: Remediation.grantLocationPermission,
                  ),
                ),
                NeedsAttentionCard(
                  NeedsAttention(
                    code: FailureCode.locUnavailable,
                    remediation: Remediation.chooseManualPlace,
                  ),
                ),
              ],
            ),
          ),
          overrides: [openSystemSettingsProvider.overrideWithValue(settings)],
        ),
      );
      expect(find.byType(FilledButton), findsOneWidget);
      await tester.tap(find.text('Open settings'));
      await tester.pump();
      expect(settings.opened, ['app']);
    });
  });

  testWidgets('the first screen offers Arabic and English and stores the '
      'choice (§15 D97)', (tester) async {
    final writes = _Writes();
    await tester.pumpWidget(
      localizedApp(
        const Scaffold(body: LanguageChoice()),
        overrides: [writeSettingProvider.overrideWithValue(writes)],
      ),
    );
    expect(find.text('English'), findsOneWidget);
    await tester.tap(find.text('العربية'));
    await tester.pump();
    expect(writes.writes, {'locale': LocaleSetting.ar});
  });
}
