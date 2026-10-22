import 'dart:io';

import 'package:daily_muslim/app/app_build.dart';
import 'package:daily_muslim/app/startup_failure_app.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
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
  shellTest('the app starts on Home in the device language', (tester, _) async {
    expect(find.text('Today'), findsOneWidget);
    expect(find.byTooltip('Settings'), findsOneWidget);
  });

  shellTest(
    'choosing Arabic switches the copy and the direction',
    location: '/settings',
    (tester, dbs) async {
      await tester.tap(find.text('Device language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('العربية').last);
      await tester.runAsync(() => Future<void>.delayed(Duration.zero));
      await tester.pumpAndSettle();

      expect(find.text('الإعدادات'), findsOneWidget);
      expect(
        Directionality.of(tester.element(find.text('الإعدادات'))),
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
    (tester, _) async => expect(find.text('Today'), findsOneWidget),
  );

  shellTest(
    'a valid Calculation ID link opens the Passport (REQ-SEC-010)',
    location: '/calc/GS-ABCDEFGHIJKLMNOP',
    (tester, _) async => expect(find.text('Accuracy Passport'), findsOneWidget),
  );

  shellTest(
    'Attributions shows every bundled data source',
    location: '/settings/attributions',
    (tester, _) async {
      expect(find.text('GeoNames'), findsOneWidget);
      expect(find.textContaining('CC BY 4.0'), findsWidgets);
      expect(find.text('timezone-boundary-builder'), findsOneWidget);
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
      expect(find.text('Code DB_MIGRATION_FAILED'), findsOneWidget);
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
}
