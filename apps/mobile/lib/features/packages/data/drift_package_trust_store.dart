import 'package:daily_muslim/features/storage/data/dm_database.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:drift/drift.dart';

/// [PackageTrustStore] on drift: one `package_trust` row (§15 D74).
final class DriftPackageTrustStore implements PackageTrustStore {
  /// The store in [_db].
  const new(this._db);

  final DmDatabase _db;

  @override
  Future<ChannelTrust> read() async {
    final row = await _db.select(_db.packageTrust).getSingleOrNull();
    if (row == null) return ChannelTrust.initial;
    return ChannelTrust(
      rootJson: row.rootJson,
      sequences: TrustedSequences(
        timestamp: row.timestampSequence,
        snapshot: row.snapshotSequence,
        targets: row.targetsSequence,
        timestampSha256: row.timestampSha256,
        snapshotSha256: row.snapshotSha256,
        targetsSha256: row.targetsSha256,
      ),
      lastSyncUtcMs: row.lastSyncUtc,
      lastVerifiedUtcMs: row.lastVerifiedUtc,
    );
  }

  @override
  Future<Result<void, PackageFailure>> write(ChannelTrust trust) async {
    final s = trust.sequences;
    final root = trust.rootJson;
    try {
      await _db
          .into(_db.packageTrust)
          .insertOnConflictUpdate(
            PackageTrustCompanion.insert(
              id: const Value(1),
              rootJson: Value(root == null ? null : Uint8List.fromList(root)),
              timestampSequence: s.timestamp,
              snapshotSequence: s.snapshot,
              targetsSequence: s.targets,
              timestampSha256: Value(s.timestampSha256),
              snapshotSha256: Value(s.snapshotSha256),
              targetsSha256: Value(s.targetsSha256),
              lastSyncUtc: trust.lastSyncUtcMs,
              lastVerifiedUtc: Value(trust.lastVerifiedUtcMs),
            ),
          );
      return const Result.ok(null);
    } on Exception catch (error) {
      return Result.err(PackageFailure.storage('$error'));
    }
  }
}
