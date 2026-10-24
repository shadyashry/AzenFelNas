// S27 automated accessibility audit (§18.6 beta exit, REQ-UX-020): every
// routed screen of the real app, in English and Arabic, at 100 % and 200 %
// text, meets Flutter's tap-target (Android 48 dp, iOS 44 pt), labelled
// tap-target and text-contrast guidelines. The audit with two screen-reader
// users (§18.10) is owed by the owner: docs/release/accessibility-audit.md.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/app_harness.dart';

const List<String> _screens = [
  '/',
  '/settings',
  '/settings/attributions',
  '/settings/diagnostics',
  '/timeline',
  '/place',
  '/health',
  '/qibla',
];

void main() {
  for (final locale in const [Locale('en'), Locale('ar')]) {
    for (final scale in const [1.0, 2.0]) {
      for (final screen in _screens) {
        testWidgets('REQ-UX-020 $screen meets the tap-target, label and '
            'contrast guidelines (${locale.languageCode}, ${scale}x text)', (
          tester,
        ) async {
          final semantics = tester.ensureSemantics();
          tester.platformDispatcher.localesTestValue = [locale];
          tester.platformDispatcher.textScaleFactorTestValue = scale;
          addTearDown(tester.platformDispatcher.clearAllTestValues);
          final dbs = memoryDatabases();
          await tester.pumpWidget(harnessApp(dbs, initialLocation: screen));
          // Bounded frames: /timeline keeps scheduling frames, so
          // pumpAndSettle would never return there.
          for (var i = 0; i < 40; i++) {
            await tester.runAsync(
              () => Future<void>.delayed(const Duration(milliseconds: 5)),
            );
            await tester.pump(const Duration(milliseconds: 50));
          }

          await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
          await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
          await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
          await expectLater(tester, meetsGuideline(textContrastGuideline));

          await disposeApp(tester, dbs);
          semantics.dispose();
        });
      }
    }
  }
}
