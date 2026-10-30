import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/surah_nav_bar.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';

SuraEntry _sura(int number, int startPage) => SuraEntry(
  number: number,
  header: 'سُورَةُ $number',
  startPage: startPage,
  verseCount: 10,
);

/// Al-Baqarah on 2–14; Ali 'Imran from 14, the page Al-Baqarah ends on;
/// Al-Ikhlas, Al-Falaq and An-Nas share page 604.
final List<SuraEntry> _suras = [
  _sura(1, 1),
  _sura(2, 2),
  _sura(3, 14),
  _sura(112, 604),
  _sura(113, 604),
  _sura(114, 604),
];

const Map<int, ({int first, int last})> _pages = {
  1: (first: 1, last: 1),
  2: (first: 2, last: 14),
  3: (first: 14, last: 20),
  112: (first: 604, last: 604),
  113: (first: 604, last: 604),
  114: (first: 604, last: 604),
};

Future<ProviderContainer> _pump(WidgetTester tester, Locale locale) async {
  final db = QuranNotesDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final notes = DriftQuranNotes(db);
  await tester.pumpWidget(
    localizedApp(
      const Scaffold(
        body: Align(alignment: Alignment.bottomCenter, child: SurahNavBar()),
      ),
      locale: locale,
      overrides: [
        surasProvider.overrideWith((ref) async => _suras),
        surahPagesProvider.overrideWith((ref, sura) async => _pages[sura]),
        versePlacesProvider.overrideWithValue(null),
        readingPositionStoreProvider.overrideWithValue(notes),
        readerPreferencesStoreProvider.overrideWithValue(notes),
      ],
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(tester.element(find.byType(SurahNavBar)));
}

Future<void> _open(
  WidgetTester tester,
  ProviderContainer container,
  int sura,
) async {
  await container
      .read(readerProvider.notifier)
      .showVerseAt(sura, 1, fallbackPage: _pages[sura]!.first);
  await tester.pump();
  await tester.pump();
}

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    final ar = locale.languageCode == 'ar';
    String n(int v) => ar
        ? String.fromCharCodes(
            v.toString().codeUnits.map((c) => c - 0x30 + 0x0660),
          )
        : '$v';

    group('The surah bar, ${locale.languageCode} (§15 D120)', () {
      testWidgets('REQ-QRN-024: shows the chosen surah, the page and its '
          'place among the pages of the surah', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);
        container.read(readerProvider.notifier).goTo(5);
        await tester.pump();

        expect(
          find.text(l.quranSurahPosition(n(5), n(4), n(13))),
          findsOneWidget,
        );
        expect(find.byTooltip(l.quranSurahPagesOpen), findsOneWidget);
        expect(find.byTooltip(l.quranSurahStart), findsOneWidget);
        expect(find.byTooltip(l.quranGoToAyah), findsOneWidget);
        expect(find.byType(FilledButton), findsNothing);
      });

      testWidgets('REQ-QRN-024: on a page shared with the next surah the bar '
          'keeps the chosen surah and offers to continue to the next, which '
          'begins on this page', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);
        container.read(readerProvider.notifier).goTo(14);
        await tester.pump();

        expect(
          find.text(l.quranSurahPosition(n(14), n(13), n(13))),
          findsOneWidget,
        );
        final next = find.textContaining(
          ar ? 'بتبدأ في الصفحة دي' : 'which begins on this page',
        );
        expect(next, findsOneWidget);

        await tester.tap(next);
        await tester.pump();
        await tester.pump();

        expect(container.read(readerProvider).page, 14);
        expect(container.read(readerScopeProvider)?.sura.number, 3);
        expect(
          find.text(l.quranSurahPosition(n(14), n(1), n(7))),
          findsOneWidget,
        );
      });

      testWidgets('REQ-QRN-024: a one-page surah among several on a page has '
          'no pages control, and continues to the next on the same page', (
        tester,
      ) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 112);

        expect(find.text(l.quranSurahOnePage(n(604))), findsOneWidget);
        expect(find.byTooltip(l.quranSurahPagesOpen), findsNothing);
        expect(find.byType(FilledButton), findsOneWidget);

        await _open(tester, container, 114);

        expect(find.byType(FilledButton), findsNothing);
      });

      testWidgets('REQ-QRN-030: in a short window (a phone on its side) the '
          'bar, its next-surah action included, keeps to one row', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(2400, 1080);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.reset);
        final container = await _pump(tester, locale);
        await _open(tester, container, 112);

        expect(find.byType(FilledButton), findsOneWidget);
        expect(tester.getSize(find.byType(SurahNavBar)).height, lessThan(60));
      });

      testWidgets('REQ-QRN-025: Go to ayah refuses a verse the surah does not '
          'have and opens one it has', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 3);

        await tester.tap(find.byTooltip(l.quranGoToAyah));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '11');
        await tester.tap(find.text(l.quranGo));
        await tester.pump();

        expect(find.text(l.quranGoToAyahInvalid(n(10))), findsOneWidget);

        await tester.enterText(find.byType(TextField), ar ? '٧' : '7');
        await tester.tap(find.text(l.quranGo));
        await tester.pumpAndSettle();

        expect(find.byType(AlertDialog), findsNothing);
        expect(container.read(readerScopeProvider)?.sura.number, 3);
      });
    });
  }
}
