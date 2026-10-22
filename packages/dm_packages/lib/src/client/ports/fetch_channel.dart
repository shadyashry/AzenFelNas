import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/fetched_file.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/verify/metadata_role.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Reads one channel of the distribution plane (§9.1): only
/// `cdn.dailymuslim.app`. Contract: a transport error, a non-200 answer or
/// a body over the caller's `maxBytes` is `PKG_NETWORK`; bytes are returned
/// unmodified, never verified here.
abstract interface class FetchChannel {
  /// `metadata/<role>.json`.
  Future<Result<FetchedFile, PackageFailure>> metadata(
    MetadataRole role, {
    required int maxBytes,
  });

  /// `packages/<type>/<version>/<sha256>.dmpkg`.
  Future<Result<FetchedFile, PackageFailure>> package(
    PackageType type,
    String version,
    String sha256, {
    required int maxBytes,
  });
}
