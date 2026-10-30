// On-device check of the offline Quran (§15 D107). Needs the package already
// downloaded on the device and is meant to run with the network off:
//
//   flutter drive --profile --driver=test_driver/integration_test.dart \
//     --target=integration_test/quran_device_test.dart
//
// It reports search latency and frame times while turning pages to
// build/integration_response_data.json. Not part of CI (needs a device).
import 'dart:ui';

import 'package:daily_muslim/app/bootstrap.dart';
import 'package:daily_muslim/features/quran/data/sqlite_mushaf_index.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  Future<void> settle(WidgetTester tester, [int ms = 1500]) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('REQ-QRN-040/041: offline search and page turns on device', (
    tester,
  ) async {
    final report = <String, Object>{};

    // The app: open the Quran tab and, on a fresh install, download the
    // package from the loopback copy of the CDN (dev build, adb reverse).
    await tester.pumpWidget(await Bootstrap.run());
    await settle(tester, 6000);
    // A fresh install starts in onboarding; the Quran needs no place.
    GoRouter.of(tester.element(find.byType(Navigator).first)).go('/quran');
    await settle(tester, 3000);
    final download = find.byIcon(Icons.download);
    if (download.evaluate().isNotEmpty) {
      final watch = Stopwatch()..start();
      await tester.tap(download.first);
      while (find.byType(PageView).evaluate().isEmpty &&
          watch.elapsed < const Duration(minutes: 5)) {
        await settle(tester, 1000);
      }
      report['downloadAndInstallMs'] = watch.elapsedMilliseconds;
    }
    expect(find.byType(PageView), findsOneWidget);
    final support = await getApplicationSupportDirectory();
    final dir =
        '${support.path}/quran/packages/${QuranEditionPin.packageId}/'
        '${QuranEditionPin.version}';

    // Search latency, straight on the installed index.
    final index = SqliteMushafIndex(dir);
    final queries = [
      'الله لا إله إلا هو الحي القيوم',
      'الصلاة',
      'الرحمن',
      'يا أيها الذين آمنوا',
      'قل هو الله أحد',
      'الجنة',
      'موسى',
      'سبحان',
    ];
    final timings = <int>[];
    final totals = <String, int>{};
    for (final q in queries) {
      final watch = Stopwatch()..start();
      final result = await index.search(q, limit: 200);
      timings.add(watch.elapsedMicroseconds);
      totals[q] = switch (result) {
        Ok(:final value) => value.total,
        Err() => -1,
      };
    }
    await index.close();
    timings.sort();
    report['searchMicros'] = timings;
    report['searchTotals'] = totals;
    debugPrint('QURAN_TOTALS $totals $timings');
    expect(totals.values.every((n) => n > 0), isTrue);

    // Search in the app and open a result.
    tester.testTextInput.register();
    await tester.tap(find.byIcon(Icons.search));
    await settle(tester);
    await tester.showKeyboard(find.byType(TextField));
    await tester.enterText(find.byType(TextField), 'الحي القيوم');
    await settle(tester, 2000);
    final hit = find.textContaining(RegExp('Verse 255|آية ٢٥٥|آية 255'));
    expect(hit, findsWidgets);
    await tester.tap(hit.first);
    await settle(tester, 2000);
    expect(
      find.textContaining(RegExp('Page 42|صفحة ٤٢|صفحة 42')),
      findsOneWidget,
    );

    // Frame times while turning 20 pages.
    final frames = <FrameTiming>[];
    void collect(List<FrameTiming> t) => frames.addAll(t);
    SchedulerBinding.instance.addTimingsCallback(collect);
    final surface = tester.getCenter(find.byType(PageView));
    for (var i = 0; i < 20; i++) {
      await tester.flingFrom(surface, const Offset(400, 0), 2000);
      await settle(tester, 600);
    }
    SchedulerBinding.instance.removeTimingsCallback(collect);
    List<int> ms(int Function(FrameTiming) f) =>
        (frames.map(f).toList()..sort());
    final build = ms((t) => t.buildDuration.inMicroseconds);
    final raster = ms((t) => t.rasterDuration.inMicroseconds);
    int p(List<int> l, double q) =>
        l.isEmpty ? 0 : l[(l.length * q).floor().clamp(0, l.length - 1)];
    report['frames'] = frames.length;
    report['buildMicrosP50P90P99'] = [
      p(build, .5),
      p(build, .9),
      p(build, .99),
    ];
    report['rasterMicrosP50P90P99'] = [
      p(raster, .5),
      p(raster, .9),
      p(raster, .99),
    ];
    expect(
      find.textContaining(RegExp('Page 62|صفحة ٦٢|صفحة 62')),
      findsOneWidget,
    );
    binding.reportData = report;
  });
}
