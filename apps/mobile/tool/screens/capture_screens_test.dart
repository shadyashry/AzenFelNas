// Development-only screen capture: renders the real app (in-memory
// databases, bundled seeds, fake device ports) with the bundled fonts on a
// phone viewport and writes one PNG per screen to tool/screens/out/. Not a
// CI test: it lives outside test/ and is run by hand:
//
//   flutter test tool/screens/capture_screens_test.dart
//
// The PNGs are review evidence for the design pass, not goldens.
import 'dart:io';

import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../test/features/contexts/support/fake_device_locator.dart';
import '../../test/support/app_harness.dart';
import '../../test/support/fake_location_access.dart';
import '../../test/support/runtime_fixtures.dart';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final path in paths) {
    final bytes = File(path).readAsBytesSync();
    loader.addFont(Future.value(ByteData.sublistView(bytes)));
  }
  await loader.load();
}

Future<void> _loadFonts() async {
  final flutterRoot = Platform.environment['FLUTTER_ROOT'] ?? '';
  final material = '$flutterRoot/bin/cache/artifacts/material_fonts';
  await _loadFont('MaterialIcons', ['$material/materialicons-regular.otf']);
  await _loadFont('Roboto', ['$material/roboto-regular.ttf']);
  const ui = '../../packages/dm_ui/fonts';
  await _loadFont(DmTheme.latinFamily, ['$ui/Inter-Variable.ttf']);
  await _loadFont(DmTheme.arabicFamily, [
    for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold'])
      '$ui/IBMPlexSansArabic-$w.ttf',
  ]);
  await _loadFont(DmTheme.naskhFamily, [
    '$ui/Amiri-Regular.ttf',
    '$ui/Amiri-Bold.ttf',
  ]);
}

Future<void> _shot(WidgetTester tester, String name) async {
  await tester.pump(const Duration(milliseconds: 400));
  await expectLater(
    find.byType(MaterialApp).first,
    matchesGoldenFile('out/$name.png'),
  );
}

Future<void> _go(WidgetTester tester, String location, Finder until) async {
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(location);
  await pumpUntil(tester, until);
}

/// Cairo, 22 October 2026 (UTC+3): before Fajr, forenoon, after Asr,
/// after Maghrib.
const Map<String, int> _moments = {
  'a_before_fajr': 1792635600000,
  'b_forenoon': 1792659600000,
  'c_after_asr': 1792676400000,
  'd_after_maghrib': 1792683000000,
};

Future<OpenedDatabases> _firstRun(WidgetTester tester, int nowUtcMs) async {
  final dbs = memoryDatabases();
  final locator = FakeDeviceLocator()
    ..current = Ok(cairoFix(fixUtcMs: nowUtcMs));
  await tester.pumpWidget(
    harnessApp(
      dbs,
      locator: locator,
      locationAccess: FakeLocationAccess(LocationAccess.granted),
      clock: FixedClock(nowUtcMs),
    ),
  );
  await pumpUntil(tester, find.byType(FilledButton));
  return dbs;
}

Future<void> _toHome(WidgetTester tester) async {
  await tester.tap(find.byType(FilledButton).first);
  await pumpUntil(tester, find.byType(OutlinedButton));
  await tester.tap(find.byType(FilledButton).first);
  await pumpUntil(tester, find.byType(FilledButton));
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.byType(FilledButton).first);
  await pumpUntil(tester, find.byType(TimeRow));
}

void main() {
  setUpAll(() async {
    autoUpdateGoldenFiles = true;
    await _loadFonts();
  });

  for (final locale in [const Locale('ar'), const Locale('en')]) {
    final tag = locale.languageCode;

    void phone(WidgetTester tester) {
      tester.view.physicalSize = const Size(1080, 2340);
      tester.view.devicePixelRatio = 2.625;
      tester.platformDispatcher.localesTestValue = [locale];
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearLocalesTestValue);
    }

    testWidgets('capture $tag screens', (tester) async {
      phone(tester);
      final dbs = await _firstRun(tester, _moments['b_forenoon'] ?? 0);
      await _shot(tester, '${tag}_01_onboarding_welcome');
      await _toHome(tester);
      await _shot(tester, '${tag}_04_home');
      await _go(tester, '/timeline', find.byType(TimeRow));
      await _shot(tester, '${tag}_05_timeline');
      await _go(tester, '/qibla', find.byType(Scaffold));
      await _shot(tester, '${tag}_06_qibla');
      await _go(tester, '/health', find.byType(Scaffold));
      await _shot(tester, '${tag}_07_athan');
      await _go(tester, '/settings', find.byType(Scaffold));
      await _shot(tester, '${tag}_08_settings');
      await _go(tester, '/', find.byType(TimeRow));
      await tester.tap(find.byType(TimeRow).first);
      await pumpUntil(tester, find.byType(Scaffold));
      await tester.pump(const Duration(milliseconds: 500));
      await _shot(tester, '${tag}_10_passport');
      await disposeApp(tester, dbs);
    });

    for (final MapEntry(key: moment, value: utcMs) in _moments.entries) {
      testWidgets('capture $tag home $moment', (tester) async {
        phone(tester);
        final dbs = await _firstRun(tester, utcMs);
        await _toHome(tester);
        await _shot(tester, '${tag}_home_$moment');
        await disposeApp(tester, dbs);
      });
    }
  }
}
