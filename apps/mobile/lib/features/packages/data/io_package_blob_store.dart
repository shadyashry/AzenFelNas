import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// [StorePackageBlobs] under one directory. A write goes to a `.part` file
/// that is then renamed over the target, so a reader never sees a partial
/// file. Paths are relative, `/`-separated and never contain `..`.
final class IoPackageBlobStore implements StorePackageBlobs {
  /// The store rooted at [_root].
  const new(this._root);

  final Directory _root;

  @override
  Future<Result<void, PackageFailure>> write(
    String path,
    List<int> bytes,
  ) async {
    final file = _file(path);
    if (file == null) return _badPath(path);
    try {
      await file.parent.create(recursive: true);
      final part = File('${file.path}.part');
      await part.writeAsBytes(bytes, flush: true);
      await part.rename(file.path);
      return const Result.ok(null);
    } on FileSystemException catch (error) {
      return Result.err(PackageFailure.storage(error.message));
    }
  }

  @override
  Future<Result<List<int>, PackageFailure>> read(String path) async {
    final file = _file(path);
    if (file == null) return _badPath(path);
    try {
      return Result.ok(await file.readAsBytes());
    } on FileSystemException catch (error) {
      return Result.err(PackageFailure.storage(error.message));
    }
  }

  @override
  Future<Result<void, PackageFailure>> delete(String path) async {
    final file = _file(path);
    if (file == null) return _badPath(path);
    try {
      if (file.existsSync()) await file.delete();
      return const Result.ok(null);
    } on FileSystemException catch (error) {
      return Result.err(PackageFailure.storage(error.message));
    }
  }

  File? _file(String path) {
    final segments = path.split('/');
    final safe =
        path.isNotEmpty &&
        !path.startsWith('/') &&
        segments.every((s) => s.isNotEmpty && s != '.' && s != '..');
    return safe ? File('${_root.path}/$path') : null;
  }

  static Result<Never, PackageFailure> _badPath(String path) =>
      Result.err(PackageFailure.storage('not a relative blob path: $path'));
}
