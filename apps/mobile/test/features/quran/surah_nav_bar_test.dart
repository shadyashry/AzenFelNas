import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_reader.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
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

Future<ProviderContainer> _pump(
  WidgetTester tester,
  Locale locale, {
  ReaderDensity density = ReaderDensity.full,
}) async {
  final db = QuranNotesDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final notes = DriftQuranNotes(db);
  final viewport = MushafViewportController();
  addTearDown(viewport.dispose);
  await tester.pumpWidget(
    localizedApp(
      Scaffold(
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer(
                builder: (context, ref, _) =>
                    ReaderTopBar(page: ref.watch(readerProvider).page),
              ),
              ReaderControls(viewport: viewport, density: density),
            ],
          ),
        ),
      ),
      locale: locale,
      overrides: [
        surasProvider.overrideWith((ref) async => _suras),
        juzProvider.overrideWith((ref) async => const <JuzEntry>[]),
        quranFontProvider.overrideWith((ref) async => false),
        bookmarksProvider.overrideWith(
          (ref) => Stream.value(const <Bookmark>[]),
        ),
        surahPagesProvider.overrideWith((ref, sura) async => _pages[sura]),
        versePlacesProvider.overrideWithValue(null),
        readingPositionStoreProvider.overrideWithValue(notes),
        readerPreferencesStoreProvider.overrideWithValue(notes),
      ],
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(ReaderControls)),
  );
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
  test('REQ-QRN-033: the controls give way as the window gets shorter', () {
    expect(ReaderDensity.forHeight(915), ReaderDensity.full);
    expect(ReaderDensity.forHeight(720), ReaderDensity.compact);
    expect(ReaderDensity.forHeight(640), ReaderDensity.minimal);
  });

  test('REQ-QRN-033: the controls go beside the page only where a whole '
      'page fitted to the height still leaves room for them', () {
    bool side(double w, double h) =>
        MushafReader.sideBySide(Size(w, h), EdgeInsets.zero, 0.7);

    expect(side(411, 780), isFalse, reason: 'phone, portrait');
    expect(side(320, 488), isFalse, reason: 'small phone, portrait');
    expect(side(914, 331), isTrue, reason: 'phone on its side');
    expect(side(640, 280), isTrue, reason: '640 × 360 window');
    expect(side(800, 1200), isFalse, reason: 'tablet, portrait');
    expect(side(1280, 720), isTrue, reason: 'tablet on its side');
    expect(side(560, 500), isFalse, reason: 'nearly square split window');
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    final ar = locale.languageCode == 'ar';
    String n(int v) => ar
        ? String.fromCharCodes(
            v.toString().codeUnits.map((c) => c - 0x30 + 0x0660),
          )
        : '$v';

    group('The surah navigator, ${locale.languageCode} (§15 D120, D121)', () {
      testWidgets('REQ-QRN-024: shows the page, its place among the chosen '
          'surah’s pages, All pages, the slider and labelled page '
          'buttons', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);
        container.read(readerProvider.notifier).goTo(5);
        await tester.pump();

        expect(
          find.descendant(
            of: find.byType(SurahNavBar),
            matching: find.text(l.quranPage(n(5))),
          ),
          findsOneWidget,
        );
        expect(find.text(l.quranSurahPageOf(n(4), n(13))), findsOneWidget);
        expect(find.text(l.quranAllPages), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.text(l.quranNextPage), findsOneWidget);
        expect(find.text(l.quranPreviousPage), findsOneWidget);
      });

      testWidgets('REQ-QRN-024: the slider previews while dragging and opens '
          'the page only on release', (tester) async {
        final container = await _pump(tester, locale);
        await _open(tester, container, 2);

        final drag = await tester.startGesture(
          tester.getCenter(find.byType(Slider)),
        );
        await drag.moveBy(const Offset(-60, 0));
        await tester.pump();

        expect(container.read(readerProvider).page, 2);

        await drag.up();
        await tester.pump();

        final page = container.read(readerProvider).page;
        expect(page, isNot(2));
        expect(page, inInclusiveRange(2, 14));
      });

      testWidgets('REQ-QRN-024: on a page shared with the next surah the '
          'navigator keeps the chosen surah, and Next becomes Continue to the '
          'next surah, which begins on this page', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);
        container.read(readerProvider.notifier).goTo(14);
        await tester.pump();

        expect(find.text(l.quranSurahPageOf(n(13), n(13))), findsOneWidget);
        expect(find.text(l.quranNextPage), findsNothing);
        final next = find.textContaining(
          ar ? 'بتبدأ في الصفحة دي' : 'which begins on this page',
        );
        expect(next, findsOneWidget);

        await tester.tap(next);
        await tester.pump();
        await tester.pump();

        expect(container.read(readerProvider).page, 14);
        expect(container.read(readerScopeProvider)?.sura.number, 3);
        expect(find.text(l.quranSurahPageOf(n(1), n(7))), findsOneWidget);
      });

      testWidgets('REQ-QRN-024: a one-page surah among several on a page has '
          'no slider or All pages; the last surah of the Mushaf offers no '
          'next surah', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 112);

        expect(find.text(l.quranSurahWholePage), findsOneWidget);
        expect(find.text(l.quranAllPages), findsNothing);
        expect(find.byType(Slider), findsNothing);
        expect(find.text(l.quranNextPage), findsNothing);

        await _open(tester, container, 114);

        expect(find.text(l.quranNextPage), findsOneWidget);
      });

      testWidgets('REQ-QRN-025: Go to ayah, from the reader menu, refuses a '
          'verse the surah does not have and opens one it has', (tester) async {
        final container = await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 3);

        await tester.tap(find.byTooltip(l.quranMore));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l.quranGoToAyah));
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

      testWidgets('REQ-QRN-033: in a short window only the place and the page '
          'buttons stay; the slider and zoom buttons give way to the page', (
        tester,
      ) async {
        final container = await _pump(
          tester,
          locale,
          density: ReaderDensity.minimal,
        );
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);

        expect(
          find.text(l.quranSurahPosition(n(2), n(1), n(13))),
          findsOneWidget,
        );
        expect(find.byType(Slider), findsNothing);
        expect(find.byTooltip(l.quranZoomIn), findsNothing);
        expect(find.byTooltip(l.quranAllPages), findsOneWidget);
        expect(find.text(l.quranNextShort), findsOneWidget);
        expect(find.bySemanticsLabel(l.quranNextPage), findsOneWidget);
      });
    });
  }
}
