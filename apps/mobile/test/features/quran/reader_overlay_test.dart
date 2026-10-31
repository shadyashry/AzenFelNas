import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/ayah_highlight.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/hizb_quarter.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/quran_page_geometry.dart';
import 'package:daily_muslim/features/quran/domain/reader_preferences.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_reader.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport.dart';
import 'package:daily_muslim/features/quran/presentation/mushaf_viewport_controller.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/features/quran/presentation/reader_overlay.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
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

/// The third quarter of hizb 1 starts on page 5.
const _quarters = [
  HizbQuarter(number: 1, sura: 1, aya: 1, page: 1),
  HizbQuarter(number: 2, sura: 2, aya: 26, page: 5),
  HizbQuarter(number: 3, sura: 2, aya: 44, page: 7),
];

const _installed = InstalledQuran(
  directory: '/nowhere',
  manifest: QuranManifest(
    packageId: 'hafs-madinah-1441',
    version: '1441.2',
    layoutId: 'kfgqpc-hafs-1441-604',
    printEdition: '1441',
    pageCount: 604,
    pageImage: QuranPageGeometry(
      width: 1600,
      height: 2600,
      pathPattern: 'pages/{page:03}.webp',
    ),
    files: [],
  ),
  manifestSha256: 'sha',
  installedBytes: 1,
);

List<Override> _overrides(DriftQuranNotes notes) => [
  surasProvider.overrideWith((ref) async => _suras),
  juzProvider.overrideWith((ref) async => const <JuzEntry>[]),
  quartersProvider.overrideWith((ref) async => _quarters),
  surahPagesProvider.overrideWith((ref, sura) async => _pages[sura]),
  quranFontProvider.overrideWith((ref) async => false),
  bookmarksProvider.overrideWith((ref) => Stream.value(const <Bookmark>[])),
  highlightsProvider.overrideWith((ref) => Stream.value(const <Highlight>[])),
  ayahHighlightsProvider.overrideWith(
    (ref) => Stream.value(const <AyahHighlight>[]),
  ),
  pageBoxesProvider.overrideWith((ref) async => null),
  quranStatusProvider.overrideWithValue(const QuranReady(_installed)),
  quranPackageProvider.overrideWithBuild(
    (ref, _) => const QuranReady(_installed),
  ),
  versePlacesProvider.overrideWithValue(null),
  readingPositionStoreProvider.overrideWithValue(notes),
  readerPreferencesStoreProvider.overrideWithValue(notes),
];

DriftQuranNotes _notes() {
  final db = QuranNotesDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  return DriftQuranNotes(db);
}

/// The toolbar and the navigator alone, in a window [width] wide.
Future<ProviderContainer> _pumpBars(
  WidgetTester tester,
  Locale locale, {
  double width = 900,
}) async {
  tester.view.physicalSize = Size(width, 700);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final viewport = MushafViewportController();
  addTearDown(viewport.dispose);
  await tester.pumpWidget(
    localizedApp(
      Scaffold(
        body: Column(
          children: [
            ReaderToolbar(page: 2, viewport: viewport, landscape: true),
            const Spacer(),
            Consumer(
              builder: (context, ref, _) => ReaderNavPanel(
                page: ref.watch(readerProvider.select((s) => s.page)),
                viewport: viewport,
              ),
            ),
          ],
        ),
      ),
      locale: locale,
      overrides: _overrides(_notes()),
    ),
  );
  await tester.pump();
  return ProviderScope.containerOf(
    tester.element(find.byType(ReaderNavPanel)),
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

/// A short tap on the page, then the double-tap window, after which the
/// tap counts.
Future<void> _tapPage(WidgetTester tester) async {
  await tester.tap(find.byType(MushafViewport));
  await tester.pump(kDoubleTapTimeout + const Duration(milliseconds: 50));
  await tester.pumpAndSettle();
}

Finder _tooltipContaining(String text) => find.byWidgetPredicate(
  (w) => w is Tooltip && (w.message ?? '').contains(text),
);

/// The whole reader in a window of [size].
Future<ProviderContainer> _pumpReader(
  WidgetTester tester,
  Size size, {
  ReaderPreferences? preferences,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final notes = _notes();
  if (preferences != null) await notes.writePreferences(preferences);
  await tester.pumpWidget(
    localizedApp(
      const Scaffold(body: MushafReader(installed: _installed)),
      overrides: _overrides(notes),
    ),
  );
  for (var i = 0; i < 4; i++) {
    await tester.pump();
  }
  return ProviderScope.containerOf(tester.element(find.byType(MushafReader)));
}

void main() {
  group('ReaderLayout (§15 D123)', () {
    const insets = EdgeInsets.fromLTRB(32, 24, 0, 16);

    test('REQ-QRN-033: a landscape window gives the page everything inside '
        'the system insets but a thin lower margin for the handle; the '
        'controls float over it', () {
      const layout = ReaderLayout(size: Size(915, 412), insets: insets);
      expect(layout.landscape, isTrue);
      expect(
        layout.surface,
        insets.copyWith(bottom: insets.bottom + ReaderLayout.handleRoom),
      );
    });

    test('REQ-QRN-033: the navigator takes two rows below 560 dp', () {
      expect(ReaderNavPanel.twoRows(388), isTrue);
      expect(ReaderNavPanel.twoRows(891), isFalse);
      expect(ReaderNavPanel.heightAt(388), ReaderNavPanel.twoRowHeight);
    });

    test('REQ-QRN-033: a portrait window keeps the room of the toolbar and '
        'the navigator, so a whole page is never covered', () {
      const layout = ReaderLayout(size: Size(412, 915), insets: insets);
      expect(layout.landscape, isFalse);
      expect(layout.surface.top, insets.top + ReaderToolbar.height);
      expect(
        layout.surface.bottom,
        insets.bottom + ReaderNavPanel.twoRowHeight + ReaderNavPanel.margin * 2,
      );
    });
  });

  group('Tap to show the controls (§15 D123)', () {
    for (final (name, size) in const [
      ('landscape', Size(915, 412)),
      ('portrait', Size(412, 915)),
    ]) {
      testWidgets('REQ-QRN-033: in $name, showing and hiding the controls '
          'never resizes or moves the page', (tester) async {
        final container = await _pumpReader(tester, size);
        Rect page() => tester.getRect(find.byType(MushafViewport));
        final before = page();

        container.read(readerProvider.notifier).toggleChrome();
        await tester.pumpAndSettle();
        final after = page();
        container.read(readerProvider.notifier).toggleChrome();
        await tester.pumpAndSettle();

        expect(after, before);
        expect(page(), before);
      });
    }

    testWidgets('REQ-QRN-033: landscape opens on the page alone; a short tap '
        'shows the controls and another hides them', (tester) async {
      final container = await _pumpReader(tester, const Size(915, 412));
      final l = await AppLocalizations.delegate.load(const Locale('en'));
      expect(container.read(readerProvider).chromeVisible, isFalse);
      expect(find.bySemanticsLabel(l.quranShowControls), findsOneWidget);

      await _tapPage(tester);
      expect(container.read(readerProvider).chromeVisible, isTrue);

      await _tapPage(tester);
      expect(container.read(readerProvider).chromeVisible, isFalse);

      await tester.tap(find.bySemanticsLabel(l.quranShowControls));
      await tester.pumpAndSettle();
      expect(container.read(readerProvider).chromeVisible, isTrue);
    });

    testWidgets('REQ-QRN-033: a drag scrolls or turns, it never toggles the '
        'controls', (tester) async {
      final container = await _pumpReader(tester, const Size(915, 412));

      await tester.drag(find.byType(MushafViewport), const Offset(0, -120));
      await tester.pumpAndSettle();

      expect(container.read(readerProvider).chromeVisible, isFalse);
    });

    testWidgets('REQ-QRN-033: with Keep controls visible a tap no longer '
        'hides them, and a landscape window opens with them', (tester) async {
      final container = await _pumpReader(
        tester,
        const Size(915, 412),
        preferences: const ReaderPreferences(keepControls: true),
      );
      expect(container.read(readerProvider).chromeVisible, isTrue);

      await _tapPage(tester);

      expect(container.read(readerProvider).chromeVisible, isTrue);
    });

    test('REQ-QRN-030: landscape fits the width and portrait the whole page '
        'until the reader chooses; each is kept apart', () {
      const prefs = ReaderPreferences();
      expect(prefs.fitFor(landscape: true), PageFit.width);
      expect(prefs.fitFor(landscape: false), PageFit.page);
      final changed = prefs.withFit(landscape: true, value: PageFit.page);
      expect(changed.fitFor(landscape: true), PageFit.page);
      expect(changed.fitFor(landscape: false), PageFit.page);
      expect(
        changed
            .withFit(landscape: false, value: PageFit.width)
            .fitFor(landscape: true),
        PageFit.page,
      );
    });
  });

  for (final locale in const [Locale('en'), Locale('ar')]) {
    final ar = locale.languageCode == 'ar';
    String n(int v) => ar
        ? String.fromCharCodes(
            v.toString().codeUnits.map((c) => c - 0x30 + 0x0660),
          )
        : '$v';

    group('The page navigator, ${locale.languageCode} (§15 D120, D123)', () {
      testWidgets('REQ-QRN-024: shows the Mushaf page, its place in the '
          'chosen surah, the hizb quarter that starts on it, Pages, the '
          'slider and the page buttons', (tester) async {
        final container = await _pumpBars(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);
        container.read(readerProvider.notifier).goTo(5);
        await tester.pump();

        expect(find.text(l.quranPage(n(5))), findsOneWidget);
        expect(
          find.text(
            '${l.quranPlaceInSurah(n(4), n(13))} · ${l.quranHizbQuarter(n(1))}',
          ),
          findsOneWidget,
        );
        expect(find.text(l.quranPagesButton), findsOneWidget);
        expect(find.byType(Slider), findsOneWidget);
        expect(find.byTooltip(l.quranNextPage), findsOneWidget);
        expect(find.byTooltip(l.quranPreviousPage), findsOneWidget);
      });

      testWidgets('REQ-QRN-020: Next sits on the left and Previous on the '
          'right in both languages', (tester) async {
        final container = await _pumpBars(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);

        expect(
          tester.getCenter(find.byTooltip(l.quranNextPage)).dx,
          lessThan(tester.getCenter(find.byTooltip(l.quranPreviousPage)).dx),
        );
      });

      testWidgets('REQ-QRN-024: the slider previews while dragging and opens '
          'the page only on release', (tester) async {
        final container = await _pumpBars(tester, locale);
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

      testWidgets('REQ-QRN-024: on a page shared with the next surah Next '
          'becomes Continue to the next surah, which begins on this page', (
        tester,
      ) async {
        final container = await _pumpBars(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);
        container.read(readerProvider.notifier).goTo(14);
        await tester.pump();

        expect(find.text(l.quranPlaceInSurah(n(13), n(13))), findsOneWidget);
        expect(find.byTooltip(l.quranNextPage), findsNothing);
        final next = _tooltipContaining(
          ar ? 'بتبدأ في الصفحة دي' : 'which begins on this page',
        );
        expect(next, findsOneWidget);

        await tester.tap(next);
        await tester.pump();
        await tester.pump();

        expect(container.read(readerProvider).page, 14);
        expect(container.read(readerScopeProvider)?.sura.number, 3);
        expect(find.text(l.quranPlaceInSurah(n(1), n(7))), findsOneWidget);
      });

      testWidgets('REQ-QRN-024: a one-page surah has no slider; the last '
          'surah of the Mushaf offers no next surah', (tester) async {
        final container = await _pumpBars(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 112);

        expect(find.text(l.quranWholeSurahHere), findsOneWidget);
        expect(find.byType(Slider), findsNothing);
        expect(find.byTooltip(l.quranNextPage), findsNothing);

        await _open(tester, container, 114);

        expect(find.byTooltip(l.quranNextPage), findsOneWidget);
      });

      testWidgets('REQ-QRN-025: Go to ayah, from the reader menu, refuses a '
          'verse the surah does not have and opens one it has', (tester) async {
        final container = await _pumpBars(tester, locale);
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

      testWidgets('REQ-QRN-033: a phone-wide window puts the navigator on '
          'two rows so the slider keeps its room, and the extra toolbar '
          'actions move into the menu', (tester) async {
        final container = await _pumpBars(tester, locale, width: 400);
        final l = await AppLocalizations.delegate.load(locale);
        await _open(tester, container, 2);

        final slider = tester.getRect(find.byType(Slider));
        final next = tester.getRect(find.byTooltip(l.quranNextPage));
        final pages = tester.getRect(find.text(l.quranPagesButton));
        expect(slider.width, greaterThan(150));
        expect(next.center.dy, closeTo(slider.center.dy, 4));
        expect(pages.center.dy, lessThan(slider.top));
        expect(find.byTooltip(l.quranMore), findsOneWidget);
        expect(find.text(l.quranTajweed), findsNothing);
        expect(tester.takeException(), isNull);
      });
    });
  }
}
