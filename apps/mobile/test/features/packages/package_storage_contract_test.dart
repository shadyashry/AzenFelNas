// REQ-TEST-004: the trust store and blob store contracts, run against the
// adapters and the in-memory fakes alike.
import 'dart:io';

import 'package:daily_muslim/features/packages/data/drift_package_trust_store.dart';
import 'package:daily_muslim/features/packages/data/io_package_blob_store.dart';
import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:dm_packages/testing.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final trustStores =
      <String, (PackageTrustStore, Future<void> Function()) Function()>{
        'DriftPackageTrustStore': () {
          final db = DmDatabase(NativeDatabase.memory());
          return (DriftPackageTrustStore(db), db.close);
        },
        'InMemoryTrustStore': () => (InMemoryTrustStore(), () async {}),
      };
  for (final MapEntry(key: name, value: open) in trustStores.entries) {
    group('$name honours the trust store contract (REQ-TEST-004, '
        'REQ-PKG-005)', () {
      test('nothing stored reads as the initial state', () async {
        final (store, close) = open();
        addTearDown(close);

        final trust = await store.read();

        expect(trust.rootJson, isNull);
        expect(trust.sequences, TrustedSequences.none);
        expect(trust.lastSyncUtcMs, 0);
        expect(trust.lastVerifiedUtcMs, isNull);
      });

      test(
        'a written state reads back unchanged and replaces the last',
        () async {
          final (store, close) = open();
          addTearDown(close);
          const sequences = TrustedSequences(
            timestamp: 7,
            snapshot: 5,
            targets: 4,
            timestampSha256: 'a',
            snapshotSha256: 'b',
            targetsSha256: 'c',
          );

          await store.write(
            const ChannelTrust(
              sequences: TrustedSequences.none,
              lastSyncUtcMs: 1,
            ),
          );
          final written = await store.write(
            const ChannelTrust(
              rootJson: [123, 125],
              sequences: sequences,
              lastSyncUtcMs: 2,
              lastVerifiedUtcMs: 3,
            ),
          );
          final trust = await store.read();

          expect(written, isA<Ok<void, PackageFailure>>());
          expect(trust.rootJson, [123, 125]);
          expect(trust.sequences, sequences);
          expect((trust.lastSyncUtcMs, trust.lastVerifiedUtcMs), (2, 3));
        },
      );
    });
  }

  final blobStores = <String, StorePackageBlobs Function()>{
    'IoPackageBlobStore': () => IoPackageBlobStore(
      Directory.systemTemp.createTempSync('dm_blobs_'),
    ),
    'InMemoryPackageBlobs': InMemoryPackageBlobs.new,
  };
  for (final MapEntry(key: name, value: open) in blobStores.entries) {
    group('$name honours the blob store contract (REQ-TEST-004)', () {
      test('write, read, overwrite and delete', () async {
        final store = open();
        const path = 'tzdata/2026e/abc.dmpkg';

        await store.write(path, [1, 2, 3]);
        await store.write(path, [4]);
        final read = await store.read(path);
        final deleted = await store.delete(path);
        final again = await store.delete(path);

        expect(
          read,
          isA<Ok<List<int>, PackageFailure>>().having(
            (o) => o.value,
            'bytes',
            [4],
          ),
        );
        expect(deleted, isA<Ok<void, PackageFailure>>());
        expect(again, isA<Ok<void, PackageFailure>>());
        expect(
          await store.read(path),
          isA<Err<List<int>, PackageFailure>>().having(
            (e) => e.failure.code,
            'code',
            FailureCode.pkgStorage,
          ),
        );
      });
    });
  }

  test('IoPackageBlobStore refuses a path that leaves its directory', () async {
    final root = Directory.systemTemp.createTempSync('dm_blobs_');
    final store = IoPackageBlobStore(root);

    final results = [
      await store.write('../escape.dmpkg', [1]),
      await store.write('/abs.dmpkg', [1]),
      await store.write('a/./b', [1]),
    ];

    for (final result in results) {
      expect(result, isA<Err<void, PackageFailure>>());
    }
    expect(File('${root.parent.path}/escape.dmpkg').existsSync(), isFalse);
  });
}
