import 'dart:io';

import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/app/startup_failure_app.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/presentation/app_tab_bar.dart';
import 'package:daily_muslim/features/storage/data/opened_databases.dart';
import 'package:daily_muslim/features/storage/domain/storage_failure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

/// A widget test of the real app at [location] over in-memory databases.
void shellTest(
  String description,
  Future<void> Function(WidgetTester tester, OpenedDatabases dbs) body, {
  String location = '/',
}) => testWidgets(description, (tester) async {
  final dbs = memoryDatabases();
  await tester.pumpWidget(harnessApp(dbs, initialLocation: location));
  await tester.pumpAndSettle();
  await body(tester, dbs);
  await disposeApp(tester, dbs);
});

void main() {
  shellTest(
    'the first start opens onboarding in the device language',
    (tester, _) async {
      expect(find.text('Let’s make it local.'), findsOneWidget);
    },
  );

  shellTest(
    'choosing Arabic switches the copy and the direction',
    location: '/settings',
    (tester, dbs) async {
      await tester.tap(find.text('Device language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية').last);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      // The page title and its navigation label.
      expect(find.text('الإعدادات'), findsNWidgets(2));
      expect(
        Directionality.of(tester.element(find.text('الإعدادات').first)),
        TextDirection.rtl,
      );
      final stored = await tester.runAsync(
        () => DriftSettingsStore(dbs.dm).read(AppSettings.locale),
      );
      expect(stored, LocaleSetting.ar);
    },
  );

  shellTest(
    'a refused deep link lands on Home (REQ-SEC-010)',
    location: '/calc/not-an-id',
    (tester, _) async => expect(
      find.text('Let’s make it local.'),
      findsOneWidget,
    ),
  );

  testWidgets(
    'a valid Calculation ID link opens the Passport (REQ-SEC-010)',
    (tester) async {
      // The Passport shows progress while the runtime data loads, so this
      // test pumps until the page is up instead of settling.
      final dbs = memoryDatabases();
      await tester.pumpWidget(
        harnessApp(dbs, initialLocation: '/calc/GS-ABCDEFGHIJKLMNOP#fajr'),
      );
      await pumpUntil(tester, find.text('Accuracy Passport'));
      await disposeApp(tester, dbs);
    },
  );

  shellTest(
    'Attributions shows every bundled data source',
    location: '/settings/attributions',
    (tester, _) async {
      expect(find.text('GeoNames'), findsOneWidget);
      expect(find.textContaining('CC BY 4.0'), findsWidgets);
      expect(find.text('timezone-boundary-builder'), findsOneWidget);
      // The list is longer than the screen: check each entry as it scrolls
      // into view.
      await tester.scrollUntilVisible(
        find.textContaining('King Fahd Glorious Quran Printing Complex').first,
        200,
      );
      await tester.scrollUntilVisible(
        find.text('Athan voice: Abdul Basit Abdus Samad'),
        200,
      );
      expect(
        find.text('Athan voice: Abdul Basit Abdus Samad'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(
        find.text('Athan voice: Ahmed El-Haddad'),
        200,
      );
      await tester.scrollUntilVisible(find.text('Open-source licences'), 200);
      expect(find.text('Open-source licences'), findsOneWidget);
    },
  );

  testWidgets(
    'a database that cannot open shows Needs attention with its code '
    '(REQ-ERR-002)',
    (tester) async {
      await tester.pumpWidget(
        StartupFailureApp(
          const DescribeFailure()(const MigrationFailed('dm.sqlite')),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Needs attention'), findsOneWidget);
      expect(find.byTooltip('Code DB_MIGRATION_FAILED'), findsOneWidget);
      expect(
        find.text('Install the latest version of the app.'),
        findsOneWidget,
      );
    },
  );

  test('AppBuild.version is the pubspec version', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    expect(pubspec, contains('\nversion: ${AppBuild.version}+'));
  });

  shellTest(
    'Settings offers "Report a problem", said in words a reader knows',
    location: '/settings',
    (tester, _) async {
      expect(find.text('Report a problem'), findsOneWidget);
      expect(
        find.text('Copy a report for support if something goes wrong'),
        findsOneWidget,
      );
    },
  );

  // The app is drawn edge to edge: the last row of a tab page must scroll
  // clear of the floating tab bar and the system navigation bar (§15 D100).
  for (final (location, lastRow) in [
    ('/settings', 'Data sources and licences'),
    ('/health', 'Isha'),
  ]) {
    testWidgets('REQ-UX-020 the last row of $location scrolls clear of the '
        'tab bar (§15 D100)', (tester) async {
      tester.view.physicalSize = const Size(1080, 1920);
      tester.view.devicePixelRatio = 2.625;
      tester.view.padding = const FakeViewPadding(bottom: 126);
      addTearDown(tester.view.reset);
      final dbs = memoryDatabases();
      await tester.pumpWidget(harnessApp(dbs, initialLocation: location));
      // Bounded frames: a page may keep scheduling frames.
      Future<void> frames() async {
        for (var i = 0; i < 40; i++) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 5)),
          );
          await tester.pump(const Duration(milliseconds: 50));
        }
      }

      await frames();
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -3000));
      await frames();
      final row = tester.getRect(find.text(lastRow).last);
      final bar = tester.getRect(find.byType(AppTabBar));
      expect(row.bottom, lessThanOrEqualTo(bar.top));
      await disposeApp(tester, dbs);
    });
  }
}
