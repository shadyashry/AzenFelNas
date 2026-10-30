import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/staged_quran.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// [QuranPackageDisk] under `<app support>/quran` (§15 D106):
///
/// ```
/// active.json                          pointer: packageId, version
/// packages/<packageId>/<version>/      the active package (+ search.sqlite)
/// staging/<packageId>-<version>/       a download: files, *.part, .verified
/// ```
///
/// A file enters a package directory only after its size and SHA-256 match
/// the manifest; the pointer is replaced by writing a temporary file and
/// renaming it, so a crash leaves either the old or the new pointer.
final class IoQuranPackageDisk implements QuranPackageDisk {
  /// The disk under [root], accepting only the manifest with
  /// [pinnedManifestSha256].
  const new(this.root, {required this.pinnedManifestSha256});

  /// `<app support>/quran`.
  final Directory root;

  /// SHA-256 of the one manifest this build accepts.
  final String pinnedManifestSha256;

  static const _manifest = 'manifest.json';
  static const _ledger = '.verified';
  static const _part = '.part';

  File get _pointer => File('${root.path}/active.json');

  Directory _packageDir(String id, String version) =>
      Directory('${root.path}/packages/$id/$version');

  Directory _stagingDir(String id, String version) =>
      Directory('${root.path}/staging/$id-$version');

  @override
  String partPath(String directory, String path) => '$directory/$path$_part';

  @override
  Future<InstalledQuran?> active() async {
    try {
      if (!_pointer.existsSync()) return null;
      final pointer = _jsonObject(await _pointer.readAsString());
      final id = pointer['packageId'];
      final version = pointer['version'];
      if (id is! String || version is! String) return null;
      final dir = _packageDir(id, version);
      _recoverInterruptedSwap(dir);
      final manifest = await _readManifest(dir);
      if (manifest == null) return null;
      return InstalledQuran(
        directory: dir.path,
        manifest: manifest,
        installedBytes: _sizeOf(dir),
      );
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  @override
  Future<List<String>> quickCheck(InstalledQuran installed) async => [
    for (final file in installed.manifest.files)
      if (!_hasSize(File('${installed.directory}/${file.path}'), file.bytes))
        file.path,
  ];

  @override
  Future<List<String>> fullCheck(
    InstalledQuran installed, {
    void Function(int done, int total)? progress,
  }) async {
    final files = installed.manifest.files;
    final bad = <String>[];
    for (final (index, file) in files.indexed) {
      final target = File('${installed.directory}/${file.path}');
      if (!_hasSize(target, file.bytes) ||
          await _sha256(target) != file.sha256) {
        bad.add(file.path);
      }
      progress?.call(index + 1, files.length);
    }
    return bad;
  }

  @override
  Future<StagedQuran?> staging() async {
    final staging = Directory('${root.path}/staging');
    if (!staging.existsSync()) return null;
    for (final dir in staging.listSync().whereType<Directory>()) {
      final manifest = await _readManifest(dir);
      if (manifest == null) continue;
      return _staged(dir, manifest);
    }
    return null;
  }

  @override
  Future<Result<StagedQuran, QuranFailure>> startStaging(
    List<int> manifestBytes,
    QuranPackageManifest manifest,
  ) => _guard(() async {
    final staging = Directory('${root.path}/staging');
    if (staging.existsSync()) await staging.delete(recursive: true);
    final dir = _stagingDir(manifest.packageId, manifest.version);
    await dir.create(recursive: true);
    await File('${dir.path}/$_manifest')
        .writeAsBytes(manifestBytes, flush: true);
    return _staged(dir, manifest);
  });

  @override
  Future<Result<void, QuranFailure>> commitFile(
    String directory,
    QuranPackageFile file,
  ) => _guard(() async {
    final part = File(partPath(directory, file.path));
    if (!_hasSize(part, file.bytes) || await _sha256(part) != file.sha256) {
      if (part.existsSync()) await part.delete();
      return Result<void, QuranFailure>.err(QuranIntegrityFailed(file.path));
    }
    await part.rename('$directory/${file.path}');
    await File(
      '$directory/$_ledger',
    ).writeAsString('${file.path}\n', mode: FileMode.append, flush: true);
    return const Result<void, QuranFailure>.ok(null);
  }).then((r) => r.flatMap((inner) => inner));

  @override
  Future<void> discardFile(String directory, String path) async {
    for (final f in [
      File('$directory/$path'),
      File(partPath(directory, path)),
    ]) {
      if (f.existsSync()) await f.delete();
    }
  }

  @override
  Future<Result<InstalledQuran, QuranFailure>> activate(StagedQuran staged) =>
      _guard(() async {
        final manifest = staged.manifest;
        final target = _packageDir(manifest.packageId, manifest.version);
        await target.parent.create(recursive: true);
        final aside = Directory('${target.path}.old');
        if (aside.existsSync()) await aside.delete(recursive: true);
        if (target.existsSync()) await target.rename(aside.path);
        await Directory(staged.directory).rename(target.path);
        final ledger = File('${target.path}/$_ledger');
        if (ledger.existsSync()) await ledger.delete();
        await _writePointer(manifest.packageId, manifest.version);
        await _deleteOthers(target);
        return InstalledQuran(
          directory: target.path,
          manifest: manifest,
          installedBytes: _sizeOf(target),
        );
      });

  @override
  Future<Result<void, QuranFailure>> removeAll() => _guard(() async {
    if (_pointer.existsSync()) await _pointer.delete();
    for (final name in ['packages', 'staging']) {
      final dir = Directory('${root.path}/$name');
      if (dir.existsSync()) await dir.delete(recursive: true);
    }
  });

  Future<StagedQuran> _staged(
    Directory dir,
    QuranPackageManifest manifest,
  ) async {
    final ledger = File('${dir.path}/$_ledger');
    final listed = ledger.existsSync()
        ? (await ledger.readAsLines()).toSet()
        : <String>{};
    final verified = <String>{};
    final partial = <String, int>{};
    for (final file in manifest.files) {
      if (listed.contains(file.path) &&
          _hasSize(File('${dir.path}/${file.path}'), file.bytes)) {
        verified.add(file.path);
        continue;
      }
      final part = File(partPath(dir.path, file.path));
      if (part.existsSync()) partial[file.path] = part.lengthSync();
    }
    return StagedQuran(
      directory: dir.path,
      manifest: manifest,
      verified: verified,
      partialBytes: partial,
    );
  }

  Future<QuranPackageManifest?> _readManifest(Directory dir) async {
    final file = File('${dir.path}/$_manifest');
    if (!file.existsSync()) return null;
    final bytes = await file.readAsBytes();
    if (sha256.convert(bytes).toString() != pinnedManifestSha256) return null;
    return QuranPackageManifest.fromJson(_jsonObject(utf8.decode(bytes)));
  }

  /// A crash between the two renames of [activate] leaves the previous
  /// package at `<target>.old` and no target: put it back.
  void _recoverInterruptedSwap(Directory target) {
    final aside = Directory('${target.path}.old');
    if (!target.existsSync() && aside.existsSync()) {
      aside.renameSync(target.path);
    }
  }

  Future<void> _writePointer(String id, String version) async {
    final tmp = File('${_pointer.path}.tmp');
    await tmp.writeAsString(
      jsonEncode({'packageId': id, 'version': version}),
      flush: true,
    );
    await tmp.rename(_pointer.path);
  }

  Future<void> _deleteOthers(Directory keep) async {
    final packages = Directory('${root.path}/packages');
    for (final id in packages.listSync().whereType<Directory>()) {
      for (final version in id.listSync().whereType<Directory>()) {
        if (version.path != keep.path) await version.delete(recursive: true);
      }
    }
  }

  static bool _hasSize(File file, int bytes) =>
      file.existsSync() && file.lengthSync() == bytes;

  static Future<String> _sha256(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  static int _sizeOf(Directory dir) => dir
      .listSync(recursive: true)
      .whereType<File>()
      .fold(0, (sum, f) => sum + f.lengthSync());

  static Map<String, Object?> _jsonObject(String text) => switch (jsonDecode(
    text,
  )) {
    final Map<String, Object?> map => map,
    _ => throw const FormatException('not a JSON object'),
  };

  /// Runs [body], turning file-system errors into [QuranFailure]s; a full
  /// disk is [QuranNoSpace].
  static Future<Result<T, QuranFailure>> _guard<T>(
    Future<T> Function() body,
  ) async {
    try {
      return Result.ok(await body());
    } on FileSystemException catch (error) {
      final code = error.osError?.errorCode;
      // ENOSPC on Android and iOS, ERROR_DISK_FULL / ERROR_HANDLE_DISK_FULL
      // on Windows test hosts.
      if (code == 28 || code == 112 || code == 39) {
        return const Result.err(QuranNoSpace(neededBytes: 0));
      }
      return Result.err(QuranStorageFailed(error.message));
    }
  }
}
