import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

import '../support/client_harness.dart';

TufTargetCustom _custom({
  String minApp = '1.0.0',
  int minEngineSchema = 1,
  int schemaVersion = 1,
}) => TufTargetCustom(
  schemaVersion: schemaVersion,
  payloadFormat: PayloadFormatCode.json,
  compat: TufCompat(minApp: minApp, minEngineSchema: minEngineSchema),
  effectiveFrom: '2026-01-01',
  priority: TargetPriorityCode.normal,
  changeNote: const TufChangeNote(ar: 'أ', en: 'a'),
);

void main() {
  final check = CheckCompatibility(
    AppCompat(
      appVersion: '1.4.2',
      engineSchema: 2,
      schemaVersions: const {PackageType.gazetteer: 1, PackageType.tzdata: 2},
    ),
  );

  group('compat is checked before download and activation (REQ-PKG-006)', () {
    final cases = <String, (PackageType, TufTargetCustom, bool)>{
      'same app version': (
        PackageType.gazetteer,
        _custom(minApp: '1.4.2'),
        true,
      ),
      'older minApp': (PackageType.gazetteer, _custom(minApp: '0.9.10'), true),
      'newer patch': (PackageType.gazetteer, _custom(minApp: '1.4.3'), false),
      'newer minor': (PackageType.gazetteer, _custom(minApp: '1.10.0'), false),
      'newer major': (PackageType.gazetteer, _custom(minApp: '2.0.0'), false),
      'engine schema reached': (
        PackageType.tzdata,
        _custom(minEngineSchema: 2),
        true,
      ),
      'engine schema beyond': (
        PackageType.tzdata,
        _custom(minEngineSchema: 3),
        false,
      ),
      'payload schema supported': (
        PackageType.tzdata,
        _custom(schemaVersion: 2),
        true,
      ),
      'payload schema beyond': (
        PackageType.gazetteer,
        _custom(schemaVersion: 2),
        false,
      ),
      'type not read by this build': (PackageType.hijri, _custom(), false),
    };
    for (final MapEntry(key: name, value: (type, custom, ok))
        in cases.entries) {
      test(name, () {
        // Act
        final result = check(type, custom);

        // Assert
        if (ok) {
          expect(result, isA<Ok<void, PackageFailure>>());
        } else {
          expect(
            result,
            isA<Err<void, PackageFailure>>().having(
              (e) => e.failure.code,
              'code',
              FailureCode.pkgIncompatible,
            ),
          );
        }
      });
    }
  });

  test('an app version that is not major.minor.patch is refused at wiring', () {
    expect(
      () => AppCompat(
        appVersion: '1.0',
        engineSchema: 1,
        schemaVersions: const {},
      ),
      throwsFormatException,
    );
  });

  test('an incompatible target is never downloaded (REQ-PKG-006)', () async {
    // Arrange
    final harness = await ClientHarness.create();
    harness.channel.publish(
      PackageType.gazetteer,
      '9.0.0',
      utf8.encode('future'),
      minApp: '9.0.0',
    );
    await harness.fetch.publish(sequence: 1);

    // Act
    final report = await harness.syncAt(0);

    // Assert
    expect(
      report.targetFailures['gazetteer/9.0.0']?.code,
      FailureCode.pkgIncompatible,
    );
    expect(harness.fetch.requests, isNot(contains('gazetteer/9.0.0')));
    expect(await harness.catalog.activeAll(), isEmpty);
  });
}
