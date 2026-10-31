import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:daily_muslim/features/radio/presentation/radio_page.dart';
import 'package:daily_muslim/features/radio/presentation/radio_player_card.dart';
import 'package:daily_muslim/features/radio/presentation/radio_station_list.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'radio_fakes.dart';

const _husary = RadioStationId(RadioStationId.mp3quran, 74);

final List<RadioStation> _stations = [
  station(108, en: 'General recitations', ar: 'تلاوات متنوعة', featured: true),
  station(74, en: 'Mahmoud Khalil Al-Hussary', ar: 'محمود خليل الحصري'),
  station(69, en: 'Mohammed Siddiq Al-Minshawi', ar: 'محمد صديق المنشاوي'),
  station(
    32,
    en: 'Abdulbasit Abdulsamad, a long name that wraps onto two lines',
    ar: 'عبدالباسط عبدالصمد',
  ),
];

void main() {
  late MemorySettings settings;

  setUp(() => settings = MemorySettings());

  Future<FakeRadioAudio> pump(
    WidgetTester tester, {
    String start = '/radio',
    Locale locale = const Locale('en'),
    Brightness brightness = Brightness.light,
    Size size = const Size(390, 844),
    double textScale = 1,
    RadioPlayback initial = RadioPlayback.idle,
  }) async {
    tester.view
      ..physicalSize = size * 3
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final audio = FakeRadioAudio(initial: initial);
    final router = GoRouter(
      initialLocation: start,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: Center(child: Text('home page')),
            bottomNavigationBar: AppTabBar(current: RawdahTab.home),
          ),
        ),
        GoRoute(path: '/radio', builder: (context, state) => const RadioPage()),
      ],
    );
    addTearDown(router.dispose);
    final status = locale.languageCode == 'ar'
        ? StatusLocale.ar
        : StatusLocale.en;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          ...radioOverrides(
            audio: audio,
            store: MemoryCatalogStore(catalogOf(_stations, at: 1000)),
            origin: FakeOrigin(Result.ok(answer({74: 'x'}))),
            settings: settings,
            nowUtcMs: 2000,
          ),
          reducedMotionSettingProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
        ],
        child: MediaQuery(
          data: MediaQueryData(
            size: size,
            textScaler: TextScaler.linear(textScale),
          ),
          child: MaterialApp.router(
            routerConfig: router,
            locale: locale,
            theme: DmTheme.of(brightness, status),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return audio;
  }

  testWidgets('REQ-RADIO-013 the English screen: header, the chosen station '
      'with no invented programme, the list and the source credit', (
    tester,
  ) async {
    await pump(tester);

    expect(find.text('LISTEN & REFLECT'), findsOneWidget);
    expect(find.text('Quran radio'), findsOneWidget);
    expect(find.text('A quieter moment, wherever you are.'), findsOneWidget);
    expect(find.text('Ready'), findsOneWidget);
    expect(find.text('MP3Quran'), findsOneWidget);
    expect(find.text('Your stations'), findsOneWidget);
    expect(find.text('General recitations'), findsNWidgets(2));
    expect(find.text('Sleep timer · Off'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Audio by MP3Quran'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Audio by MP3Quran'), findsOneWidget);
    expect(find.textContaining('Now playing'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REQ-RADIO-014 Arabic is right to left, with its own type and '
      'words; the source name stays isolated', (tester) async {
    await pump(tester, locale: const Locale('ar'));

    expect(find.text('إذاعة القرآن'), findsOneWidget);
    expect(find.text('استمع وتدبّر'), findsOneWidget);
    expect(find.text('إذاعاتك'), findsOneWidget);
    expect(find.text('تلاوات متنوعة'), findsNWidgets(2));
    // Headings start on the right in Arabic.
    expect(tester.getTopRight(find.text('إذاعة القرآن')).dx, greaterThan(340));
    expect(tester.getTopRight(find.text('إذاعاتك')).dx, greaterThan(340));
    expect(
      Directionality.of(tester.element(find.byType(RadioPlayerCard))),
      TextDirection.rtl,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('REQ-RADIO-014 the dark appearance uses its own tokens, not an '
      'inversion', (tester) async {
    await pump(tester, brightness: Brightness.dark);

    final scaffold = tester.widget<Scaffold>(
      find.descendant(
        of: find.byType(RadioPage),
        matching: find.byType(Scaffold),
      ),
    );
    expect(scaffold.backgroundColor, RadioTokens.dark.background);
  });

  testWidgets('search ignores Arabic marks and spelling variants, in either '
      'language', (tester) async {
    await pump(tester);

    await tester.enterText(find.byType(TextField), 'الحُصري');
    await tester.pumpAndSettle();
    expect(find.byType(RadioStationRow), findsOneWidget);
    expect(find.text('Mahmoud Khalil Al-Hussary'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'zzz');
    await tester.pumpAndSettle();
    expect(find.byType(RadioStationRow), findsNothing);
    expect(find.textContaining('No station matches'), findsOneWidget);
  });

  testWidgets('REQ-RADIO-002 the Favorites tab shows the hearted stations by '
      'id', (tester) async {
    await settings.write(AppSettings.radioFavorites, {_husary.wire});
    await pump(tester);

    await tester.tap(find.text('Favorites'));
    await tester.pumpAndSettle();

    expect(find.byType(RadioStationRow), findsOneWidget);
    expect(find.text('Mahmoud Khalil Al-Hussary'), findsOneWidget);
  });

  testWidgets('REQ-RADIO-006 tapping a station plays that station', (
    tester,
  ) async {
    final audio = await pump(tester);

    await _reveal(tester, 'Mohammed Siddiq Al-Minshawi');
    await tester.tap(find.text('Mohammed Siddiq Al-Minshawi'));
    await tester.pumpAndSettle();

    expect(audio.calls, [
      'play mp3quran:69 https://backup.qurango.net/radio/s69',
    ]);
  });

  testWidgets('REQ-RADIO-010 the player says Live only once the native '
      'player plays; Pause and Stop then act', (tester) async {
    final audio = await pump(tester);
    await _reveal(tester, 'Mahmoud Khalil Al-Hussary');
    await tester.tap(find.text('Mahmoud Khalil Al-Hussary'));
    audio.emit(
      const RadioPlayback(phase: RadioPhase.connecting, stationId: _husary),
    );
    await tester.pumpAndSettle();
    expect(find.text('Connecting…'), findsWidgets);
    expect(find.text('Live'), findsNothing);

    audio.emit(
      const RadioPlayback(phase: RadioPhase.playing, stationId: _husary),
    );
    await tester.pumpAndSettle();
    expect(find.text('Live'), findsOneWidget);
    expect(find.text('Now playing'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.byTooltip('Stop'),
      -200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.byTooltip('Pause'));
    await tester.tap(find.byTooltip('Stop'));
    expect(audio.calls.skip(1), ['pause', 'stop']);
  });

  testWidgets('REQ-RADIO-014 a landscape window puts the player beside the '
      'list, the header compact', (tester) async {
    await pump(tester, size: const Size(844, 390));

    final card = tester.getRect(find.byType(RadioPlayerCard));
    final heading = tester.getRect(find.text('Your stations'));
    expect(heading.left, greaterThan(card.right));
    expect(find.text('LISTEN & REFLECT'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('REQ-RADIO-014 large text and a small phone still lay out', (
    tester,
  ) async {
    await pump(tester, size: const Size(320, 640), textScale: 2);
    expect(tester.takeException(), isNull);
    await pump(
      tester,
      size: const Size(1024, 768),
      locale: const Locale('ar'),
      textScale: 1.6,
    );
    expect(tester.takeException(), isNull);
  });

  group('mini player', () {
    testWidgets('REQ-RADIO-012 hidden with nothing playing', (tester) async {
      await pump(tester, start: '/');
      expect(find.byTooltip('Stop and close the player'), findsNothing);
    });

    testWidgets('REQ-RADIO-012 on another tab it shows the station; Pause '
        'and Close are their own buttons; Close stops', (tester) async {
      final audio = await pump(
        tester,
        start: '/',
        initial: const RadioPlayback(
          phase: RadioPhase.playing,
          stationId: _husary,
        ),
      );

      expect(find.text('Mahmoud Khalil Al-Hussary'), findsOneWidget);
      expect(find.text('Live · MP3Quran'), findsOneWidget);
      await tester.tap(find.byTooltip('Pause'));
      await tester.tap(find.byTooltip('Stop and close the player'));
      await tester.pumpAndSettle();

      expect(audio.calls, ['pause', 'stop']);
      expect(find.text('home page'), findsOneWidget);
    });

    testWidgets('REQ-RADIO-012 a paused station stays; its title opens Radio, '
        'where the mini player is not repeated', (tester) async {
      await pump(
        tester,
        start: '/',
        locale: const Locale('ar'),
        initial: const RadioPlayback(
          phase: RadioPhase.paused,
          stationId: _husary,
        ),
      );
      expect(find.text('محمود خليل الحصري'), findsOneWidget);

      await tester.tap(find.text('محمود خليل الحصري'));
      await tester.pumpAndSettle();

      expect(find.byType(RadioPage), findsOneWidget);
      expect(find.byTooltip('إيقاف وإغلاق المشغّل'), findsNothing);
    });
  });

  test('REQ-RADIO-014 text roles meet 4.5:1 and acting gold 3:1 on every '
      'radio surface, in both appearances', () {
    for (final t in [RadioTokens.light, RadioTokens.dark]) {
      for (final ground in [t.background, t.surface, t.selected]) {
        expect(WcagContrast.ratio(t.text, ground), greaterThanOrEqualTo(4.5));
        expect(
          WcagContrast.ratio(t.textMuted, ground),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          WcagContrast.ratio(t.goldIcon, ground),
          greaterThanOrEqualTo(3),
        );
      }
      expect(WcagContrast.ratio(t.onGreen, t.green), greaterThanOrEqualTo(4.5));
    }
    expect(
      WcagContrast.ratio(RadioMiniTokens.textMuted, RadioMiniTokens.surface),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      WcagContrast.ratio(RadioMiniTokens.onControl, RadioMiniTokens.control),
      greaterThanOrEqualTo(4.5),
    );
  });
}

/// Scrolls [text] into view and clear of the tab bar.
Future<void> _reveal(WidgetTester tester, String text) async {
  final list = find.byType(Scrollable).first;
  await tester.scrollUntilVisible(find.text(text), 200, scrollable: list);
  await tester.drag(list, const Offset(0, -250));
  await tester.pumpAndSettle();
}
