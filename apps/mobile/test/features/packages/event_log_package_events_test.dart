import 'dart:convert';

import 'package:daily_muslim/features/packages/data/event_log_package_events.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, Object?> _wire(PackageEvent event) =>
    switch (jsonDecode(jsonEncode(EventLogPackageEvents.entryOf(event)))) {
      final Map<String, Object?> json => json,
      _ => throw const FormatException('not an object'),
    };

void main() {
  group('package events are Appendix J entries without identifiers '
      '(REQ-PRIV-001, REQ-PKG-001)', () {
    test(
      'an activation is PKG_ACTIVATED INFO with type, version and source',
      () {
        expect(
          _wire(
            const PackageActivated(
              utcMs: 5,
              type: PackageType.gazetteer,
              version: '3.0.2',
              source: PackageSource.bundled,
            ),
          ),
          {
            'utcMs': 5,
            'level': 'INFO',
            'code': 'PKG_ACTIVATED',
            'attrs': {
              'packageType': 'gazetteer',
              'version': '3.0.2',
              'reason': 'bundled',
            },
          },
        );
      },
    );

    test('a rollback is PKG_ROLLED_BACK WARN naming the restored version', () {
      final entry = EventLogPackageEvents.entryOf(
        const PackageRolledBack(
          utcMs: 5,
          type: PackageType.tzdata,
          fromVersion: '2026e',
          toVersion: '2026d',
        ),
      );
      expect(entry.level, EventLogLevel.warn);
      expect(entry.code, EventCode.pkgRolledBack);
      expect(entry.attrs.version, '2026d');
    });

    test('a failed sync is SYNC_RESULT WARN with its failure code', () {
      expect(
        _wire(
          const SyncFinished(
            utcMs: 5,
            outcome: 'failed',
            activated: 0,
            failure: FailureCode.pkgSigInvalid,
          ),
        ),
        {
          'utcMs': 5,
          'level': 'WARN',
          'code': 'SYNC_RESULT',
          'attrs': {'code': 'PKG_SIG_INVALID', 'reason': 'failed', 'count': 0},
        },
      );
    });

    test('expired metadata is SYNC_RESULT WARN PKG_EXPIRED_WARNING '
        '(REQ-PKG-002)', () {
      final entry = EventLogPackageEvents.entryOf(
        const FreshnessUnverified(utcMs: 5, expiredRoles: 2),
      );
      expect(entry.attrs.code, FailureCode.pkgExpiredWarning);
      expect(entry.attrs.reason, 'freshness_unverified');
    });

    test('a version outside the event-log pattern is left out', () {
      final entry = EventLogPackageEvents.entryOf(
        const PackageActivated(
          utcMs: 5,
          type: PackageType.tzdata,
          version: '2026e.1',
          source: PackageSource.downloaded,
        ),
      );
      expect(entry.attrs.version, isNull);
      expect(EventLogEntry.fromJson(entry.toJson()), entry);
    });
  });
}
