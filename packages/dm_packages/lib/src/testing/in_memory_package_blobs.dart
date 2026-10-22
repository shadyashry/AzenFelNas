import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/ports/store_package_blobs.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// [StorePackageBlobs] in memory, for tests.
final class InMemoryPackageBlobs implements StorePackageBlobs {
  /// An empty store.
  new();

  /// The stored files by path; tests may change them to simulate tampering
  /// on disk.
  final Map<String, List<int>> files = {};

  @override
  Future<Result<void, PackageFailure>> write(
    String path,
    List<int> bytes,
  ) async {
    files[path] = List.unmodifiable(bytes);
    return const Result.ok(null);
  }

  @override
  Future<Result<List<int>, PackageFailure>> read(String path) async =>
      switch (files[path]) {
        final bytes? => Result.ok(bytes),
        null => Result.err(PackageFailure.storage('no file at $path')),
      };

  @override
  Future<Result<void, PackageFailure>> delete(String path) async {
    files.remove(path);
    return const Result.ok(null);
  }
}
