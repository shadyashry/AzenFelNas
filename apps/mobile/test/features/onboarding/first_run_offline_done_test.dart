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

    // The welcome step asks for the place at once (§15 D98).
    await pumpUntil(tester, find.text('Find my location'));

    // Approximate location is refused (§18.3 denial branch).
    await tester.tap(find.text('Find my location'));
    await pumpUntil(tester, find.text('Location is not available'));
    expect(access.requests, 1);
    expect(find.byTooltip('Code LOC_PERMISSION_DENIED'), findsOneWidget);

    // Manual place: offline gazetteer search.
    await tester.tap(find.text('Choose another city'));
    await pumpUntil(tester, find.byKey(const Key('placeSearch')));
    await tester.enterText(find.byKey(const Key('placeSearch')), 'Cairo');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await pumpUntil(tester, find.byType(ListTile));
    await tester.tap(find.widgetWithText(ListTile, 'Cairo').first);
    await pumpUntil(tester, find.text('Your times are ready'));
    await tester.tap(find.text("Show today's times"));
    await pumpUntil(tester, find.byType(TimeRow));

    // Home: the manual place, no engine-default notice (the Egyptian seed
    // profile is in effect from 2026-10-01, §15 D97) and every event with
    // its label.
    expect(find.text('Cairo'), findsOneWidget);
    expect(
      find.text(
        'No local timetable for this area yet; times use the standard '
        'method.',
      ),
      findsNothing,
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
    await pumpUntil(tester, find.text('Find my location'));
    await tester.tap(find.text('Find my location'));
    await pumpUntil(tester, find.text('Your times are ready'));
    await tester.tap(find.text("Show today's times"));
    await pumpUntil(tester, find.byType(TimeRow));

    // The device location is named after the city it is in (§15 D101).
    await pumpUntil(tester, find.text('Cairo'));
    expect(find.byType(TimeRow), findsAtLeastNWidgets(6));

    await disposeApp(tester, dbs);
  });
}
