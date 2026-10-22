import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/bundled_seed.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// The seeds shipped in the binary (REQ-PKG-003). Contract: `seeds` lists
/// each type at most once; `payload` of an unlisted or unreadable seed is
/// `PKG_STORAGE`.
abstract interface class ReadBundledSeeds {
  /// The bundled seeds.
  Future<List<BundledSeed>> seeds();

  /// The payload bytes of [seed], unverified.
  Future<Result<List<int>, PackageFailure>> payload(BundledSeed seed);
}
