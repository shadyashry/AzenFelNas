import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/mushaf_index_entries.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/quran_page_geometry.dart';
import 'package:daily_muslim/features/quran/presentation/continue_quran_card.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';

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

const _suras = [
  SuraEntry(
    number: 17,
    header: 'سُورَةُ الإِسۡرَاءِ',
    startPage: 282,
    verseCount: 111,
  ),
  SuraEntry(
    number: 18,
    header: 'سُورَةُ الكَهۡفِ',
    startPage: 293,
    verseCount: 110,
  ),
  SuraEntry(
    number: 19,
    header: 'سُورَةُ مَرۡيَمَ',
    startPage: 305,
    verseCount: 98,
  ),
];

Future<void> _pump(
  WidgetTester tester, {
  required QuranPackageStatus status,
  required int? page,
}) async {
  await tester.pumpWidget(
    localizedApp(
      const Scaffold(body: ContinueQuranCard()),
      overrides: [
        quranStatusProvider.overrideWithValue(status),
        lastQuranPageProvider.overrideWith((ref) async => page),
        surasProvider.overrideWith((ref) async => _suras),
        quranFontProvider.overrideWith((ref) async => false),
      ],
    ),
  );
  // The saved page, then the surahs, each arrive on their own frame.
  await tester.pump();
  await tester.pump();
}

void main() {
  group('Continue Quran on Home (§15 D108)', () {
    testWidgets('it names the surah and page the reader was left on, and '
        'says Available offline only for a checked package', (tester) async {
      await _pump(tester, status: const QuranReady(_installed), page: 300);
      expect(find.text('Continue Quran'), findsOneWidget);
      expect(find.text('Al-Kahf · Page 300'), findsOneWidget);
      expect(find.text('Available offline'), findsOneWidget);
      expect(find.text('Resume'), findsOneWidget);
    });

    testWidgets('a package still readable during an update is not called '
        'available offline', (tester) async {
      await _pump(
        tester,
        status: const QuranInstalling(current: _installed),
        page: 293,
      );
      expect(find.text('Al-Kahf · Page 293'), findsOneWidget);
      expect(find.text('Available offline'), findsNothing);
    });

    testWidgets('in Arabic the surah is its Mushaf header without «سورة», '
        'marks kept, and the page in Arabic-Indic digits', (tester) async {
      await tester.pumpWidget(
        localizedApp(
          const Scaffold(body: ContinueQuranCard()),
          locale: const Locale('ar'),
          overrides: [
            quranStatusProvider.overrideWithValue(const QuranReady(_installed)),
            lastQuranPageProvider.overrideWith((ref) async => 293),
            surasProvider.overrideWith((ref) async => _suras),
          ],
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.text('الكَهۡفِ · صفحة ٢٩٣'), findsOneWidget);
      expect(find.text('متابعة القراءة'), findsOneWidget);
      expect(find.text('متاح دون إنترنت'), findsOneWidget);
    });

    testWidgets('nothing shows before the first read or without a readable '
        'package', (tester) async {
      await _pump(tester, status: const QuranReady(_installed), page: null);
      expect(find.text('Continue Quran'), findsNothing);
      await _pump(tester, status: const QuranNotInstalled(), page: 293);
      expect(find.text('Continue Quran'), findsNothing);
    });
  });
}
