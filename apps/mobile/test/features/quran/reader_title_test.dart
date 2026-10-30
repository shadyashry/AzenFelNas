import 'package:daily_muslim/features/quran/data/drift_quran_notes.dart';
import 'package:daily_muslim/features/quran/data/quran_notes_database.dart';
import 'package:daily_muslim/features/quran/domain/highlight.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/quran/presentation/reader_bars.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
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
        juzProvider.overrideWith((ref) async => const <JuzEntry>[]),
        quranFontProvider.overrideWith((ref) async => false),
        bookmarksProvider.overrideWith(
          (ref) => Stream.value(const <Bookmark>[]),
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

      testWidgets('REQ-QRN-023: tapping the juz and page line opens Go to '
          'page', (tester) async {
        await _pump(tester, locale);
        final l = await AppLocalizations.delegate.load(locale);

        await tester.tap(find.textContaining(RegExp('300|٣٠٠')));
        await tester.pumpAndSettle();

        expect(find.text(l.quranGoToPage), findsOneWidget);
        expect(find.byType(ListTile), findsNothing);
      });
    });
  }
}
