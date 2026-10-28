import 'package:daily_muslim/features/contexts/domain/location_access.dart';
import 'package:daily_muslim/features/settings/data/drift_settings_store.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/app_harness.dart';
import '../../support/fake_location_access.dart';
import '../../support/runtime_fixtures.dart';
import '../contexts/support/fake_device_locator.dart';

/// S17 done-test: a fresh install with no network and location refused
/// reaches today's schedule through a manual place (US-01, US-02).
void main() {
  testWidgets('REQ-PKG-003 first run offline: location refused, Cairo chosen '
      'by search, Home shows today’s times with labels', (tester) async {
    // A phone screen: Home's prayer list sits below the mihrab (§15 D89).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final dbs = memoryDatabases();
    final access = FakeLocationAccess();
    final locator = FakeDeviceLocator();
    await tester.pumpWidget(
      harnessApp(dbs, locator: locator, locationAccess: access),
    );
    await pumpUntil(tester, find.text('Prayer times for where you are'));

    // Welcome → location.
    await tester.tap(find.text('Get started'));
    await pumpUntil(tester, find.text('Use approximate location'));

    // Approximate location is refused (§18.3 denial branch).
    await tester.tap(find.text('Use approximate location'));
    await pumpUntil(tester, find.text('Location is not available'));
    expect(access.requests, 1);
    expect(find.textContaining('LOC_PERMISSION_DENIED'), findsOneWidget);

    // Manual place: offline gazetteer search.
    await tester.tap(find.text('Choose a place'));
    await pumpUntil(tester, find.byKey(const Key('placeSearch')));
    await tester.enterText(find.byKey(const Key('placeSearch')), 'Cairo');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpUntil(tester, find.byType(ListTile));
    await tester.tap(find.widgetWithText(ListTile, 'Cairo').first);
    await pumpUntil(tester, find.text('Your times are ready'));
    await tester.tap(find.text("Show today's times"));
    await pumpUntil(tester, find.byType(TimeRow));

    // Home: the manual place, the engine-default notice (the Egyptian seed
    // profile starts on 2026-11-01) and every event with its label.
    expect(find.text('Manual place · Cairo'), findsOneWidget);
    expect(
      find.text(
        'There is no local authority profile here; the engine default is '
        'used.',
      ),
      findsOneWidget,
    );
    expect(find.byType(TimeRow), findsAtLeastNWidgets(6));
    expect(find.text('Calculated'), findsAtLeastNWidgets(6));
    expect(find.bySemanticsLabel(RegExp('^Next: ')), findsOneWidget);
    final complete = await tester.runAsync(
      () => DriftSettingsStore(dbs.dm).read(AppSettings.onboardingComplete),
    );
    expect(complete, isTrue);

    await disposeApp(tester, dbs);
  });

  testWidgets('REQ-PRIV-002 granted location stores the device context and '
      'reaches Home without a manual place', (tester) async {
    // A phone screen: Home's prayer list sits below the mihrab (§15 D89).
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(tester.view.reset);
    final dbs = memoryDatabases();
    final access = FakeLocationAccess(LocationAccess.granted);
    final locator = FakeDeviceLocator()
      ..current = Ok(cairoFix(fixUtcMs: harnessNowUtcMs));
    await tester.pumpWidget(
      harnessApp(dbs, locator: locator, locationAccess: access),
    );
    await pumpUntil(tester, find.text('Get started'));
    await tester.tap(find.text('Get started'));
    await pumpUntil(tester, find.text('Use approximate location'));
    await tester.tap(find.text('Use approximate location'));
    await pumpUntil(tester, find.text('Your times are ready'));
    await tester.tap(find.text("Show today's times"));
    await pumpUntil(tester, find.byType(TimeRow));

    expect(find.text('Approximate location'), findsOneWidget);
    expect(find.byType(TimeRow), findsAtLeastNWidgets(6));

    await disposeApp(tester, dbs);
  });
}
