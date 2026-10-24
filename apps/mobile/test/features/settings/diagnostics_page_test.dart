import 'package:daily_muslim/features/settings/application/export_diagnostic_bundle.dart';
import 'package:daily_muslim/features/settings/presentation/diagnostics_page.dart';
import 'package:daily_muslim/features/settings/presentation/diagnostics_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/state_harness.dart';
import '../contexts/support/fake_location_context_store.dart';
import 'support/diagnostic_fixtures.dart';

Future<FakeDeliverDiagnosticText> _pump(
  WidgetTester tester, {
  bool accept = true,
}) async {
  final store = FakeLocationContextStore();
  await addPlace(store, latE6: 30044412, lonE6: 31235749);
  final deliver = FakeDeliverDiagnosticText(accept: accept);
  await tester.pumpWidget(
    localizedApp(
      const DiagnosticsPage(),
      overrides: [
        assembleDiagnosticBundleProvider.overrideWithValue(assembleOver(store)),
        exportDiagnosticBundleProvider.overrideWithValue(
          ExportDiagnosticBundle(deliver),
        ),
      ],
    ),
  );
  await tester.pumpAndSettle();
  return deliver;
}

String _shown(WidgetTester tester) =>
    tester
        .widget<SelectableText>(find.byKey(const Key('diagnosticsContents')))
        .data ??
    '';

void main() {
  testWidgets('REQ-PRIV-005 the whole report is shown before it is copied, '
      'and the copy is exactly what was shown', (tester) async {
    final deliver = await _pump(tester);

    final shown = _shown(tester);
    expect(shown, contains('"latE2": 3004'));
    expect(shown, contains('"events.jsonl"'));
    expect(deliver.delivered, isEmpty);

    await tester.tap(find.text('Copy report'));
    await tester.pumpAndSettle();

    expect(deliver.delivered, [shown]);
    expect(find.text('Report copied'), findsOneWidget);
  });

  testWidgets('REQ-ERR-002 a refused copy shows the DIAG_EXPORT_FAILED '
      'remediation', (tester) async {
    await _pump(tester, accept: false);

    await tester.tap(find.text('Copy report'));
    await tester.pumpAndSettle();

    expect(find.text('Report copied'), findsNothing);
    expect(find.textContaining('DIAG_EXPORT_FAILED'), findsOneWidget);
  });
}
