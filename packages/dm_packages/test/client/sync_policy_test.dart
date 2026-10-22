import 'dart:convert';
import 'dart:math';

import 'package:dm_packages/dm_packages.dart';
import 'package:test/test.dart';

import '../support/client_harness.dart';

const PackageType _poly = PackageType.tzPolygons;

/// About 2.1 MB that gzip cannot shrink.
List<int> _large() {
  final random = Random(7);
  return [for (var i = 0; i < 2100000; i++) random.nextInt(256)];
}

void main() {
  group('sync interval: at most every 6 h on open (REQ-PKG-004)', () {
    const policy = SyncPolicy();
    final cases = <String, (int last, int now, bool due)>{
      'never synced': (0, harnessNow, true),
      '5 h 59 min later': (harnessNow, harnessNow + 6 * hourMs - 60000, false),
      'exactly 6 h later': (harnessNow, harnessNow + 6 * hourMs, true),
      'clock moved backwards': (harnessNow, harnessNow - hourMs, true),
    };
    for (final MapEntry(key: name, value: (last, now, due)) in cases.entries) {
      test(name, () {
        expect(policy.due(lastSyncUtcMs: last, nowUtcMs: now), due);
      });
    }

    test('a second open within 6 h fetches nothing', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.channel.publish(_poly, '2026e', utf8.encode('poly'));
      await harness.fetch.publish(sequence: 1);
      await harness.syncAt(0);
      harness.fetch.requests.clear();

      // Act
      final report = await harness.syncAt(5);

      // Assert
      expect(report.outcome, SyncOutcome.skippedInterval);
      expect(harness.fetch.requests, isEmpty);
    });

    test('an unchanged channel is up to date and downloads nothing', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.channel.publish(_poly, '2026e', utf8.encode('poly'));
      await harness.fetch.publish(sequence: 1);
      await harness.syncAt(0);
      harness.fetch.requests.clear();

      // Act
      final report = await harness.syncAt(6);

      // Assert
      expect(report.outcome, SyncOutcome.upToDate);
      expect(harness.fetch.requests, hasLength(4));
      expect(
        harness.fetch.requests.where((r) => !r.endsWith('.json')),
        isEmpty,
      );
    });

    test('offline: nothing fetched and the next open retries', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.network.kind = NetworkKind.offline;

      // Act
      final report = await harness.syncAt(0);

      // Assert
      expect(report.outcome, SyncOutcome.offline);
      expect(harness.fetch.requests, isEmpty);
      expect(harness.trust.state.lastSyncUtcMs, 0);
    });

    test(
      'a network failure is PKG_NETWORK and changes nothing active',
      () async {
        // Arrange
        final harness = await ClientHarness.create();
        harness.fetch.offline = true;

        // Act
        final report = await harness.syncAt(0);

        // Assert
        expect(report.outcome, SyncOutcome.failed);
        expect(report.failure, isA<PackageNetworkFailure>());
        expect(await harness.catalog.activeAll(), isEmpty);
      },
    );
  });

  group('payload size policy (REQ-PKG-004)', () {
    test(
      '> 2 MB waits on a metered network, then installs unmetered',
      () async {
        // Arrange
        final harness = await ClientHarness.create();
        harness.network.kind = NetworkKind.metered;
        harness.channel.publish(_poly, '2026e', _large());
        harness.channel.publish(
          PackageType.hijri,
          '2026.1.0',
          utf8.encode('h'),
        );
        await harness.fetch.publish(sequence: 1);

        // Act
        final metered = await harness.syncAt(0);
        harness.network.kind = NetworkKind.unmetered;
        final unmetered = await harness.syncAt(6);

        // Assert
        expect(metered.deferred, ['tz_polygons/2026e']);
        expect(metered.activated.map((a) => a.type), [PackageType.hijri]);
        expect(unmetered.activated.map((a) => a.type), [_poly]);
      },
    );

    test('an urgent payload > 2 MB downloads on a metered network', () async {
      // Arrange
      final harness = await ClientHarness.create();
      harness.network.kind = NetworkKind.metered;
      harness.channel.publish(_poly, '2026e', _large(), priority: 'urgent');
      await harness.fetch.publish(sequence: 1);

      // Act
      final report = await harness.syncAt(0);

      // Assert
      expect(report.deferred, isEmpty);
      expect(report.activated.single.version, '2026e');
    });
  });

  group('clock integrity sample (REQ-TIME-010)', () {
    test('the CDN Date of timestamp.json is reported, never judged', () async {
      // Arrange: the CDN clock is 10 minutes ahead of the device.
      const cdnDate = harnessNow + 10 * 60 * 1000;
      final harness = await ClientHarness.create(serverDateUtcMs: cdnDate);
      harness.channel.publish(_poly, '2026e', utf8.encode('poly'));
      await harness.fetch.publish(sequence: 1);

      // Act
      final report = await harness.syncAt(0);

      // Assert
      expect(report.serverDateUtcMs, cdnDate);
      expect(report.activated.single.version, '2026e');
    });
  });
}
