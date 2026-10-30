import 'dart:io';

import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/services.dart';

/// [QuranOrigin] over the copy of the pinned package bundled in the app
/// (§15 D117): the same files the CDN serves, read from the app's assets,
/// so the Quran installs with no network and through the same checks as a
/// download (pinned manifest, size and SHA-256 of every file, search index).
/// A build without the copy sends every call to [_fallback], the CDN.
final class BundledQuranOrigin implements QuranOrigin {
  /// The copy under [prefix] in [_bundle], else [_fallback].
  const new(this._bundle, this._fallback, {this.prefix = defaultPrefix});

  /// Where the package is bundled.
  static const String defaultPrefix = 'assets/quran/';

  final AssetBundle _bundle;
  final QuranOrigin _fallback;

  /// The asset key prefix of the package's files.
  final String prefix;

  /// Whether this build carries the package.
  Future<bool> available() async => (await AssetManifest.loadFromAssetBundle(
    _bundle,
  )).listAssets().contains('${prefix}manifest.json');

  @override
  Future<Result<List<int>, QuranFailure>> manifest({
    required int maxBytes,
  }) async {
    if (!await available()) return await _fallback.manifest(maxBytes: maxBytes);
    final bytes = await _bytes('manifest.json');
    if (bytes == null || bytes.length > maxBytes) {
      return const Result.err(QuranIntegrityFailed('manifest.json'));
    }
    return Result.ok(bytes);
  }

  @override
  Future<Result<void, QuranFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async {
    if (!await available()) {
      return await _fallback.download(
        path,
        partPath,
        totalBytes: totalBytes,
        onBytes: onBytes,
        cancelled: cancelled,
      );
    }
    if (cancelled()) return const Result.err(QuranCancelled());
    final bytes = await _bytes(path);
    if (bytes == null || bytes.length != totalBytes) {
      return Result.err(QuranIntegrityFailed(path));
    }
    final part = File(partPath);
    try {
      final had = part.existsSync() ? part.lengthSync() : 0;
      await part.parent.create(recursive: true);
      await part.writeAsBytes(bytes, flush: true);
      onBytes(bytes.length - had);
      return const Result.ok(null);
    } on FileSystemException catch (error) {
      final code = error.osError?.errorCode;
      if (code == 28 || code == 112 || code == 39) {
        return Result.err(QuranNoSpace(neededBytes: totalBytes));
      }
      return Result.err(QuranStorageFailed(error.message));
    }
  }

  Future<Uint8List?> _bytes(String path) async {
    final key = '$prefix$path';
    final assets = await AssetManifest.loadFromAssetBundle(_bundle);
    if (!assets.listAssets().contains(key)) return null;
    final data = await _bundle.load(key);
    return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  }
}
