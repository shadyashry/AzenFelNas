import 'dart:convert';
import 'dart:math';

import 'package:daily_muslim/features/settings/application/assemble_diagnostic_bundle.dart';
import 'package:daily_muslim/features/settings/application/export_diagnostic_bundle.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

import '../athan/support/fake_athan_platform.dart';
import '../athan/support/health_reports.dart';
import '../contexts/support/fake_location_context_store.dart';
import 'support/diagnostic_fixtures.dart';

/// A number with three or more decimals anywhere in a text.
final _fineNumber = RegExp(r'\d\.\d{3,}');

/// Every object key in [json], at any depth.
Iterable<String> _keys(Object? json) sync* {
  if (json is Map<String, Object?>) {
    for (final MapEntry(:key, :value) in json.entries) {
      yield key;
      yield* _keys(value);
    }
  } else if (json is List<Object?>) {
    for (final item in json) {
      yield* _keys(item);
    }
  }
}

/// A key naming a raw coordinate or an identifier; `zoneId` is a time-zone
/// name and `entryId` a plan-entry hash, neither identifies anyone.
bool _forbidden(String key) =>
    RegExp(r'^(lat|lon|latitude|longitude|uuid|idfa|idfv)$').hasMatch(key) ||
    (RegExp(r'[iI]d$').hasMatch(key) && key != 'zoneId' && key != 'entryId');

void main() {
  test('REQ-PRIV-005 the bundle holds the context at 0.01° without its '
      'label or accuracy', () async {
    final store = FakeLocationContextStore();
    await addPlace(store, latE6: 30044412, lonE6: 31235749);

    final bundle = await assembleOver(store)();
    final text = ExportDiagnosticBundle.textOf(bundle);

    expect(
      bundle.files.context,
      const DiagnosticContext(
        kind: DiagnosticContextKind.manual,
        source: 'gazetteer',
        latE2: 3004,
        lonE2: 3124,
        zoneId: 'Africa/Cairo',
        countryCode: 'EG',
      ),
    );
    expect(text, isNot(contains('Home of my aunt')));
    expect(text, isNot(contains('12.5')));
    expect(text, isNot(matches(_fineNumber)));
  });

  test('REQ-PRIV-005 coordinates round half away from zero to hundredths', () {
    expect(AssembleDiagnosticBundle.toE2(30044999), 3004);
    expect(AssembleDiagnosticBundle.toE2(30045000), 3005);
    expect(AssembleDiagnosticBundle.toE2(-30045000), -3005);
    expect(AssembleDiagnosticBundle.toE2(-4999), 0);
    expect(AssembleDiagnosticBundle.toE2(90000000), 9000);
    expect(AssembleDiagnosticBundle.toE2(-180000000), -18000);
  });

  test('REQ-PRIV-001 REQ-PRIV-005 over 500 random places no number in the '
      'bundle text has more than 2 decimals and no key names a coordinate or '
      'an identifier', () async {
    final random = Random(24);
    for (var i = 0; i < 500; i++) {
      final store = FakeLocationContextStore();
      await addPlace(
        store,
        latE6: random.nextInt(180000001) - 90000000,
        lonE6: random.nextInt(360000001) - 180000000,
      );
      final text = ExportDiagnosticBundle.textOf(await assembleOver(store)());

      expect(text, isNot(matches(_fineNumber)));
      expect(_keys(jsonDecode(text)).where(_forbidden), isEmpty);
    }
  });

  test('REQ-PRIV-005 the shown text decodes back to the same bundle', () async {
    final store = FakeLocationContextStore();
    await addPlace(store, latE6: 21422487, lonE6: 39826206);
    final bundle = await assembleOver(store)();

    final decoded = DiagnosticBundle.fromJson(
      jsonDecode(ExportDiagnosticBundle.textOf(bundle)) as Map<String, Object?>,
    );

    expect(decoded, bundle);
    expect(decoded.schemaVersion, DiagnosticBundle.currentSchemaVersion);
    expect(decoded.files.events, sampleEvents);
    expect(decoded.files.packages, const [
      DiagnosticPackage(type: 'gazetteer', version: '2026.10.1', sequence: 3),
    ]);
    expect(decoded.files.plan.status, DiagnosticPlanStatus.notApplied);
    expect(
      decoded.files.device,
      const DiagnosticDevice(
        model: null,
        os: DiagnosticOs.android,
        appVersion: '0.1.0',
      ),
    );
  });

  test('REQ-PRIV-005 without a context the bundle says so with null', () async {
    final text = ExportDiagnosticBundle.textOf(
      await assembleOver(FakeLocationContextStore())(),
    );

    expect(text, contains('"context.json": null'));
  });

  test('REQ-ALM-003 health.json carries the state Dart derived and every '
      'probe', () async {
    final platform = FakeAthanPlatform(
      report: androidReport({
        'areNotificationsEnabled': false,
        'backgroundUnrestricted': null,
      }),
    );

    final health = (await assembleOver(
      FakeLocationContextStore(),
      platform: platform,
    )()).files.health;

    expect(health.path, DiagnosticDeliveryPath.androidExact);
    expect(health.state, DiagnosticHealthState.notReady);
    expect(health.reasons, contains('needsNotificationPermission'));
    expect(health.probes, hasLength(7));
    expect(
      health.probes.firstWhere((p) => p.name == 'backgroundUnrestricted'),
      const DiagnosticProbe(name: 'backgroundUnrestricted', positive: null),
    );
  });

  test('REQ-PRIV-005 the export hands over exactly the shown text', () async {
    final deliver = FakeDeliverDiagnosticText();
    final text = ExportDiagnosticBundle.textOf(
      await assembleOver(FakeLocationContextStore())(),
    );

    final result = await ExportDiagnosticBundle(deliver)(text);

    expect(result, isA<Ok<void, FailureCode>>());
    expect(deliver.delivered, [text]);
  });

  test('REQ-ERR-002 a refused hand-over is DIAG_EXPORT_FAILED', () async {
    final result = await ExportDiagnosticBundle(
      FakeDeliverDiagnosticText(accept: false),
    )('{}');

    expect(
      result,
      isA<Err<void, FailureCode>>().having(
        (e) => e.failure,
        'failure',
        FailureCode.diagExportFailed,
      ),
    );
  });
}
