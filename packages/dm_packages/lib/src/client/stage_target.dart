import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/check_compatibility.dart';
import 'package:dm_packages/src/client/package_file.dart';
import 'package:dm_packages/src/client/package_file_state.dart';
import 'package:dm_packages/src/client/package_source.dart';
import 'package:dm_packages/src/client/ports/check_payload.dart';
import 'package:dm_packages/src/client/ports/fetch_channel.dart';
import 'package:dm_packages/src/client/ports/inflate_payload.dart';
import 'package:dm_packages/src/client/ports/store_package_blobs.dart';
import 'package:dm_packages/src/client/ports/write_package_catalog.dart';
import 'package:dm_packages/src/client/staged_package.dart';
import 'package:dm_packages/src/client/sync_policy.dart';
import 'package:dm_packages/src/client/target_choice.dart';
import 'package:dm_packages/src/verify/package_failure.dart';
import 'package:dm_packages/src/verify/verify_target_file.dart';

/// Downloads and stages one verified target (REQ-PKG-001, REQ-PKG-006):
/// compat before download, then length + SHA-256, inflate, the type's
/// schema check, the blob write and a `staged` catalog row. Any failure
/// stores nothing the client would activate.
final class StageTarget {
  /// The use case over its ports.
  const new({
    required this._compatibility,
    required this._fetch,
    required this._inflate,
    required this._checkPayload,
    required this._blobs,
    required this._catalog,
  });

  final CheckCompatibility _compatibility;
  final FetchChannel _fetch;
  final InflatePayload _inflate;
  final CheckPayload _checkPayload;
  final StorePackageBlobs _blobs;
  final WritePackageCatalog _catalog;

  static const VerifyTargetFile _verifyFile = VerifyTargetFile();

  /// The staged package of [choice], recorded at [nowUtcMs].
  Future<Result<StagedPackage, PackageFailure>> call(
    TargetChoice choice, {
    required int nowUtcMs,
  }) async {
    final target = choice.target;
    if (_compatibility(choice.type, target.custom) case Err(:final failure)) {
      return Result.err(failure);
    }
    final List<int> dmpkg;
    switch (await _fetch.package(
      choice.type,
      choice.version,
      target.sha256,
      maxBytes: target.length,
    )) {
      case Ok(:final value):
        dmpkg = value.bytes;
      case Err(:final failure):
        return Result.err(failure);
    }
    final checked = _verifyFile(choice.name, target, dmpkg)
        .flatMap(
          (_) => _inflate(dmpkg, maxBytes: SyncPolicy.maxInflatedBytes),
        )
        .flatMap(
          (payload) => _checkPayload(
            choice.type,
            target.custom.schemaVersion,
            payload,
          ).map((_) => payload),
        );
    final List<int> payload;
    switch (checked) {
      case Ok(:final value):
        payload = value;
      case Err(:final failure):
        return Result.err(failure);
    }
    final file = PackageFile(
      type: choice.type,
      version: choice.version,
      path: PackageFile.downloadedPath(
        choice.type,
        choice.version,
        target.sha256,
      ),
      sha256: target.sha256,
      source: PackageSource.downloaded,
      state: PackageFileState.staged,
      updatedUtcMs: nowUtcMs,
    );
    if (await _blobs.write(file.path, dmpkg) case Err(:final failure)) {
      return Result.err(failure);
    }
    return (await _catalog.record(file)).map(
      (_) => StagedPackage(file: file, payload: payload),
    );
  }
}
