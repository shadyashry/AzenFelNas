import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/quran_page_geometry.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/features/quran/presentation/reader_controller.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';

/// 114 surahs, surah n starting on page 5n.
final List<SuraEntry> _suras = [
  for (var n = 1; n <= 114; n++)
    SuraEntry(
      number: n,
      header: 'سُورَةُ $n',
      startPage: 5 * n,
      verseCount: 10,
    ),
];

/// 30 juz, juz j starting with surah 3j - 2: page 300 (surah 60) is in juz
/// 20, which holds surahs 58 to 60.
final List<JuzEntry> _juz = [
  for (var j = 1; j <= 30; j++)
    JuzEntry(number: j, sura: 3 * j - 2, aya: 1, page: 5 * (3 * j - 2)),
];

const _installed = InstalledQuran(
  directory: '/q',
  manifest: QuranManifest(
    packageId: 'hafs-madinah-1441',
    version: '1441.1',
    layoutId: 'madinah-1441',
    printEdition: '1441',
    pageCount: 604,
    pageImage: QuranPageGeometry(
      width: 1400,
      height: 2002,
      pathPattern: 'pages/{page}.webp',
    ),
    files: [],
  ),
  manifestSha256: 'sha',
  installedBytes: 1,
);

Future<void> _pump(WidgetTester tester, Locale locale) async {
  final db = QuranNotesDatabase(NativeDatabase.memory());
  addTearDown(db.close);
  final notes = DriftQuranNotes(db);
  await tester.pumpWidget(
    localizedApp(
      const Scaffold(body: SafeArea(child: ReaderTopBar(page: 300))),
      locale: locale,
      overrides: [
        surasProvider.overrideWith((ref) async => _suras),
        juzProvider.overrideWith((ref) async => _juz),
        quranFontProvider.overrideWith((ref) async => false),
        bookmarksProvider.overrideWith(
          (ref) => Stream.value(const <Bookmark>[]),
        ),
        quranStatusProvider.overrideWithValue(const QuranReady(_installed)),
        surahPagesProvider.overrideWith(
          (ref, sura) async => (first: 300, last: 304),
        ),
        readingPositionStoreProvider.overrideWithValue(notes),
        readerPreferencesStoreProvider.overrideWithValue(notes),
      ],
    ),
  );
  await tester.pump();
  await tester.pump();
}

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    final ar = locale.languageCode == 'ar';
    group('The reader title, ${locale.languageCode} (§15 D111)', () {
      testWidgets('REQ-QRN-023: tapping the surah name opens the surah index '
          'scrolled to that surah, marked as the one being read', (
        tester,
      ) async {
        await _pump(tester, locale);

        await tester.tap(find.text('سُورَةُ 60'));
        await tester.pumpAndSettle();

        final current = find.widgetWithText(ListTile, 'سُورَةُ 60');
        expect(current.hitTestable(), findsOneWidget);
        expect(tester.widget<ListTile>(current).selected, isTrue);
        expect(find.widgetWithText(ListTile, 'سُورَةُ 1'), findsNothing);
      });

      testWidgets('REQ-QRN-023: tapping the juz opens the juz index at that '
          'juz, marked, with the surahs inside it under it', (tester) async {
        await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        final juz20 = l.quranJuz(ar ? '٢٠' : '20');

        await tester.tap(find.text(juz20));
        await tester.pumpAndSettle();

        final current = find.widgetWithText(ListTile, juz20);
        expect(current.hitTestable(), findsOneWidget);
        expect(tester.widget<ListTile>(current).selected, isTrue);
        final under = [
          for (final n in [58, 59, 60])
            tester.getTopLeft(find.widgetWithText(ListTile, 'سُورَةُ $n')).dy,
        ];
        expect(under, orderedEquals([...under]..sort()));
        expect(under.first, greaterThan(tester.getTopLeft(current).dy));
      });

      testWidgets('REQ-QRN-022: tapping the page number shows the pages of '
          'the surah, the current one marked, and a tap opens a page', (
        tester,
      ) async {
        await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);
        String page(int n) => l.quranPage(
          ar
              ? n
                    .toString()
                    .split('')
                    .map((d) => '٠١٢٣٤٥٦٧٨٩'[int.parse(d)])
                    .join()
              : '$n',
        );

        Finder strip(String label) => find.descendant(
          of: find.byType(ListView),
          matching: find.bySemanticsLabel(label),
        );

        await tester.tap(find.text(page(300)));
        await tester.pumpAndSettle();

        for (var n = 300; n <= 304; n++) {
          expect(strip(page(n)), findsOneWidget);
        }
        expect(strip(page(299)), findsNothing);
        expect(find.byType(Slider), findsOneWidget);

        await tester.tap(strip(page(302)));
        await tester.pumpAndSettle();

        final container = ProviderScope.containerOf(
          tester.element(find.byType(ReaderTopBar)),
        );
        expect(container.read(readerProvider).page, 302);
        expect(find.byType(Slider), findsNothing);
      });

      testWidgets('REQ-QRN-022: Go to page stays one tap away from the page '
          'strip', (tester) async {
        await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);

        await tester.tap(find.textContaining(RegExp('300|٣٠٠')));
        await tester.pumpAndSettle();
        await tester.tap(find.text(l.quranGoToPage));
        await tester.pumpAndSettle();

        expect(find.byType(TextField), findsOneWidget);
        expect(find.byType(Slider), findsNothing);
      });
    });
  }
}
