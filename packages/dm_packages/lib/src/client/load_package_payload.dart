import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/package_file.dart';
import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/ports/hash_payload.dart';
import 'package:dm_packages/src/client/ports/inflate_payload.dart';
import 'package:dm_packages/src/client/ports/read_bundled_seeds.dart';
import 'package:dm_packages/src/client/ports/store_package_blobs.dart';
import 'package:dm_packages/src/client/sync_policy.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// The payload of a stored package file, re-checked against the SHA-256 the
/// catalog recorded, so a file changed on disk is never used
/// (REQ-DIST-003).
final class LoadPackagePayload {
  /// The use case over its ports.
  const new({
    required this._blobs,
    required this._inflate,
    required this._seeds,
    this._hash = const Sha256Payload(),
  });

  final StorePackageBlobs _blobs;
  final HashPayload _hash;
  final InflatePayload _inflate;
  final ReadBundledSeeds _seeds;

  /// The payload of [file]: `PKG_HASH_MISMATCH` when the stored bytes are
  /// not the recorded ones, `PKG_STORAGE` when they cannot be read.
  Future<Result<List<int>, PackageFailure>> call(PackageFile file) async {
    switch (file.source) {
      case PackageSource.downloaded:
        return (await _hashed(file, await _blobs.read(file.path))).flatMap(
          (dmpkg) => _inflate(dmpkg, maxBytes: SyncPolicy.maxInflatedBytes),
        );
      case PackageSource.bundled:
        for (final seed in await _seeds.seeds()) {
          if (seed.type == file.type && seed.version == file.version) {
            return await _hashed(file, await _seeds.payload(seed));
          }
        }
        return Result.err(
          PackageFailure.storage('$file is not bundled in this build'),
        );
    }
  }

  Future<Result<List<int>, PackageFailure>> _hashed(
    PackageFile file,
    Result<List<int>, PackageFailure> read,
  ) async => switch (read) {
    Err(:final failure) => Result.err(failure),
    Ok(value: final bytes) =>
      await _hash(bytes) == file.sha256
          ? Result.ok(bytes)
          : Result.err(
              PackageFailure.hashMismatch('$file changed since it was stored'),
            ),
  };
}
