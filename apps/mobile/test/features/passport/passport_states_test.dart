import 'package:daily_muslim/features/passport/application/resolve_calculation_id.dart';
import 'package:daily_muslim/features/passport/domain/import_mismatch.dart';
import 'package:daily_muslim/features/passport/presentation/passport_page.dart';
import 'package:daily_muslim/features/passport/presentation/passport_providers.dart';
import 'package:daily_muslim/features/passport/presentation/passport_state.dart';
import 'package:daily_muslim/features/passport/presentation/passport_view.dart';
import 'package:daily_muslim/features/shell/domain/app_route.dart';
import 'package:daily_muslim/l10n/app_localizations_en.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/runtime_fixtures.dart';
import '../../support/state_harness.dart';
import 'passport_support.dart';

const _route = CalculationRoute('GS-ABCDEFGHIJKLMNOP');

Future<void> _pump(
  WidgetTester tester,
  PassportState state, {
  Locale locale = const Locale('en'),
}) async {
  await tester.pumpWidget(
    localizedApp(
      const PassportPage(_route),
      locale: locale,
      overrides: [passportStateProvider.overrideWith((ref, route) => state)],
    ),
  );
  await tester.pump();
}

ImportMismatch _mismatch(MismatchReason reason) => ImportMismatch(
  linkId: 'GS-ABCDEFGHIJKLMNOP',
  reason: reason,
  profileId: 'eg.egas.standard',
  profileVersion: '1999.1.1',
  engineVersion: '0.4.0',
  tzdbVersion: '2026e',
);

void main() {
  final data = bundledRuntimeData();
  final schedule = cairoSchedule();
  final entry = ResolveCalculationId(data.tzdb)(
    schedule,
    schedule.days.first.calculationId,
    event: PrayerEvent.maghrib,
  )!;
  final view = PassportView.of(entry, data.tzdb);

  group('Passport UiState (§18.4) — every variant renders', () {
    testWidgets('loading shows progress', (tester) async {
      await _pump(tester, const PassportLoading());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('REQ-UX-001 ready shows the focused event first with its '
        'confidence label', (tester) async {
      await _pump(tester, PassportReady(view));
      expect(view.events.first.time.event, PrayerEvent.maghrib);
      expect(find.text('Maghrib'), findsOneWidget);
      expect(find.byType(ConfidenceChip), findsWidgets);
      expect(find.byTooltip('Copy link'), findsOneWidget);
    });

    testWidgets('REQ-UX-030 ready renders right-to-left in Arabic', (
      tester,
    ) async {
      await _pump(tester, PassportReady(view), locale: const Locale('ar'));
      expect(
        Directionality.of(tester.element(find.byType(ListView))),
        TextDirection.rtl,
      );
      expect(find.text('انسخ اللينك'), findsNothing); // tooltip, not text
      expect(find.byTooltip('انسخ اللينك'), findsOneWidget);
    });

    for (final reason in MismatchReason.values) {
      testWidgets('importMismatch(${reason.name}) explains the difference', (
        tester,
      ) async {
        await _pump(tester, PassportImportMismatch(_mismatch(reason)));
        final l = AppLocalizationsEn();
        expect(find.text(l.passportMismatchTitle), findsOneWidget);
        expect(
          find.text(switch (reason) {
            MismatchReason.differentVersions => l.passportMismatchVersions,
            MismatchReason.profileUnavailable => l.passportMismatchProfile(
              'eg.egas.standard',
              '1999.1.1',
            ),
            MismatchReason.zoneUnavailable => l.passportMismatchZone,
          }),
          findsOneWidget,
        );
        expect(
          find.text('This device: engine 0.4.0, time-zone data 2026e'),
          findsOneWidget,
        );
      });
    }

    testWidgets('notFound names the ID', (tester) async {
      await _pump(tester, const PassportNotFound());
      expect(find.text('In the link: GS-ABCDEFGHIJKLMNOP'), findsOneWidget);
    });
  });

  test('every result flag has plain-language copy (US-08)', () {
    final l = AppLocalizationsEn();
    final texts = {for (final f in ResultFlag.values) flagText(l, f)};
    expect(texts, hasLength(ResultFlag.values.length));
    for (final text in texts) {
      expect(text.toLowerCase(), isNot(contains('verified')));
      expect(text.toLowerCase(), isNot(contains('official')));
    }
  });
}
