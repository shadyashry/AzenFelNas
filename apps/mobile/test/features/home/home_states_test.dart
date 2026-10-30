import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/place_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/home_page.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/prayer_strip.dart';
import 'package:daily_muslim/features/home/presentation/time_rows.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:daily_muslim/l10n/app_localizations_en.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

import '../../support/app_harness.dart';
import '../../support/state_harness.dart';

const _minute = 60000;

TimeRowView _row(PrayerEvent event, String? time, {int dayOffset = 0}) =>
    TimeRowView(
      event: event,
      localTime: time,
      dayOffset: dayOffset,
      confidence: time == null
          ? const ConfidenceLabel.unknown(reasonCode: 'polarNight')
          : const ConfidenceLabel.calculated(),
      displayedUtcMs: time == null ? null : harnessNowUtcMs,
    );

final _day = DayView(
  date: CivilDate(2026, 10, 22),
  calculationId: 'GS-ABCDEFGHIJKLMNOP',
  rows: [
    _row(PrayerEvent.fajr, '05:42'),
    _row(PrayerEvent.sunrise, '07:01'),
    _row(PrayerEvent.dhuhr, '12:40'),
    _row(PrayerEvent.asr, '15:52'),
    _row(PrayerEvent.maghrib, '18:19'),
    _row(PrayerEvent.isha, '00:12', dayOffset: 1),
    _row(PrayerEvent.imsak, null),
  ],
);

HomeContent _content({SkyPhase phase = SkyPhase.day}) => HomeContent(
  day: _day,
  nextPrayer: const TimeRowView(
    event: PrayerEvent.asr,
    localTime: '15:52',
    dayOffset: 0,
    confidence: ConfidenceLabel.calculated(),
    displayedUtcMs: harnessNowUtcMs + 65 * _minute,
  ),
  health: const AthanReadinessUnknown(),
  sky: SkyTheme.forPhase(phase),
  place: const PlaceView(kind: ContextKind.manual, label: 'Alexandria'),
);

Future<void> _pump(
  WidgetTester tester,
  HomeState state, {
  Locale locale = const Locale('en'),
  DigitsSetting digits = DigitsSetting.locale,
}) async {
  tester.view.physicalSize = const Size(1080, 4000);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    localizedApp(
      const HomePage(),
      locale: locale,
      digits: digits,
      overrides: [homeStateProvider.overrideWithValue(state)],
    ),
  );
  await tester.pump();
}

void main() {
  group('Home UiState (§18.4) — every variant renders', () {
    testWidgets('loading shows progress', (tester) async {
      await _pump(tester, const HomeLoading());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('REQ-UX-001 ready shows the next prayer, the countdown, '
        'every row with its label and the place', (tester) async {
      await _pump(tester, HomeReady(_content()));
      // The next prayer reads as one node over the mihrab (§15 D89).
      expect(find.bySemanticsLabel(RegExp('^Next: Asr')), findsOneWidget);
      expect(find.text('in 1 h 5 min'), findsOneWidget);
      expect(find.byType(TimeRow), findsNWidgets(7));
      expect(find.text('Calculated'), findsNWidgets(6));
      expect(find.text('Not available'), findsOneWidget);
      expect(find.text('Alexandria'), findsOneWidget);
      expect(find.text('Athan: not set up yet'), findsOneWidget);
    });

    testWidgets('REQ-TIME-002 Isha after midnight shows +1', (tester) async {
      await _pump(tester, HomeReady(_content()));
      // In the row (the AM marker under it) and in the full list.
      expect(find.text('12:12 +1'), findsOneWidget);
      expect(find.text('12:12 AM +1'), findsOneWidget);
    });

    testWidgets('REQ-UX-001 the strip shows the five prayers with their '
        'confidence to screen readers, without Sunrise or Imsak', (
      tester,
    ) async {
      await _pump(tester, HomeReady(_content()));
      final strip = find.byType(PrayerStrip);
      expect(
        find.descendant(
          of: strip,
          matching: find.bySemanticsLabel('Asr, 3:52 PM, Calculated'),
        ),
        findsOneWidget,
      );
      expect(
        find.descendant(of: strip, matching: find.text('Sunrise')),
        findsNothing,
      );
      expect(
        find.descendant(of: strip, matching: find.byType(Text)),
        findsNWidgets(15),
      );
    });

    testWidgets('a phone set to a 24-hour clock keeps 24-hour times, with '
        'no AM/PM', (tester) async {
      tester.platformDispatcher.alwaysUse24HourFormatTestValue = true;
      addTearDown(tester.platformDispatcher.clearAlwaysUse24HourTestValue);
      await _pump(tester, HomeReady(_content()));
      expect(find.text('15:52'), findsNWidgets(3));
      expect(find.text('PM'), findsNothing);
    });

    testWidgets('the header keeps Settings one tap away', (tester) async {
      await _pump(tester, HomeReady(_content()));
      expect(find.byTooltip('Settings'), findsOneWidget);
    });

    testWidgets('noProfile says the engine default is used (US-06)', (
      tester,
    ) async {
      await _pump(tester, HomeNoProfile(_content()));
      expect(
        find.text(
          'No local timetable for this area yet; times use the standard '
          'method.',
        ),
        findsOneWidget,
      );
      expect(find.byType(TimeRow), findsNWidgets(7));
    });

    testWidgets('needsLocation offers a manual place', (tester) async {
      await _pump(tester, const HomeNeedsLocation());
      expect(find.text('Choose where to show prayer times for.'), findsOne);
      expect(find.text('Choose a place'), findsOneWidget);
    });

    testWidgets('REQ-ERR-002 needsAttention shows each reason with its code', (
      tester,
    ) async {
      await _pump(
        tester,
        HomeNeedsAttention([
          const DescribeFailure()(const PackageFailure.storage('missing')),
        ]),
      );
      expect(find.byType(NeedsAttentionCard), findsOneWidget);
      expect(find.byTooltip('Code PKG_STORAGE'), findsOneWidget);
    });

    testWidgets('REQ-ERR-002 error names the failure code', (tester) async {
      await _pump(
        tester,
        const HomeError(EngineFailure.orderingViolation('{}')),
      );
      expect(find.byTooltip('Code ENGINE_ORDERING'), findsOneWidget);
    });

    testWidgets('REQ-DOM-040 Arabic shows Arabic-Indic digits by default', (
      tester,
    ) async {
      await _pump(tester, HomeReady(_content()), locale: const Locale('ar'));
      // The row's digits; the hero and the full list with «م» after them.
      expect(find.text('٣:٥٢'), findsOneWidget);
      expect(find.text('٣:٥٢ م'), findsNWidgets(2));
    });

    testWidgets('REQ-DOM-040 the digits setting can keep Western digits in '
        'Arabic', (tester) async {
      await _pump(
        tester,
        HomeReady(_content()),
        locale: const Locale('ar'),
        digits: DigitsSetting.western,
      );
      // The row's digits; the hero and the full list with «م» after them.
      expect(find.text('3:52'), findsOneWidget);
      expect(find.text('3:52 م'), findsNWidgets(2));
    });

    testWidgets('REQ-DOM-040 the Arabic countdown counts in the plural its '
        'number takes', (tester) async {
      await _pump(tester, HomeReady(_content()), locale: const Locale('ar'));
      // One hour and five minutes: «ساعة», and «دقائق» for three to ten.
      expect(find.text('بعد ساعة و٥ دقائق'), findsOneWidget);
    });

    test('REQ-DOM-040 Arabic counts take the dual and the plural', () {
      final l = lookupAppLocalizations(const Locale('ar'));
      expect(l.homeCountdown(2, 2), 'بعد ساعتين ودقيقتين');
      expect(l.homeCountdown(3, 11), 'بعد 3 ساعات و11 دقيقة');
      expect(l.homeCountdownMinutes(10), 'بعد 10 دقائق');
      expect(l.athanPreReminderMinutes(15), 'قبل 15 دقيقة');
      expect(l.planPreReminderTitle('العصر', 5), 'العصر بعد 5 دقائق');
    });
  });

  group('HomeState.ofFailure (§15 D77)', () {
    test('REQ-ERR-001 a location failure asks for a place', () {
      expect(
        HomeState.ofFailure(const LocationFailure.permissionDenied()),
        isA<HomeNeedsLocation>(),
      );
    });

    test('REQ-ERR-001 an engine failure is an error', () {
      expect(
        HomeState.ofFailure(const EngineFailure.unsupportedPolicy('x')),
        isA<HomeError>(),
      );
    });

    test('REQ-ERR-002 a data failure needs attention with its code', () {
      final state = HomeState.ofFailure(const PackageFailure.storage('x'));
      expect(
        state,
        isA<HomeNeedsAttention>().having(
          (s) => s.reasons.single.code,
          'code',
          FailureCode.pkgStorage,
        ),
      );
    });
  });

  test('TimeRows.timeText writes a dash when there is no time', () {
    expect(
      TimeRows.timeText(AppLocalizationsEn(), _row(PrayerEvent.imsak, null)),
      '—',
    );
  });

  // The S27 accessibility audit of the loaded Home (§18.6 beta exit); the
  // routed first-run screens are test/app/accessibility_audit_test.dart.
  group('REQ-UX-020 loaded Home meets the tap-target, label and contrast '
      'guidelines', () {
    for (final phase in SkyPhase.values) {
      for (final locale in const [Locale('en'), Locale('ar')]) {
        for (final scale in const [1.0, 2.0]) {
          testWidgets('${phase.name}, ${locale.languageCode}, ${scale}x text', (
            tester,
          ) async {
            final semantics = tester.ensureSemantics();
            tester.platformDispatcher.textScaleFactorTestValue = scale;
            addTearDown(tester.platformDispatcher.clearAllTestValues);
            await _pump(
              tester,
              HomeReady(_content(phase: phase)),
              locale: locale,
            );

            await expectLater(
              tester,
              meetsGuideline(androidTapTargetGuideline),
            );
            await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
            await expectLater(
              tester,
              meetsGuideline(labeledTapTargetGuideline),
            );
            await expectLater(tester, meetsGuideline(textContrastGuideline));
            semantics.dispose();
          });
        }
      }
    }
  });
}
