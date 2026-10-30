import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/staged_quran.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Downloads, verifies and installs the pinned Quran package (§15 D106,
/// REQ-QRN-010..014).
///
/// 1. The manifest must be byte for byte the pinned one (size, SHA-256) and
///    name the pinned package, layout and every page.
/// 2. Free space must cover what is left to download plus the search index.
/// 3. Each file is downloaded to a `.part` file (resumed with an HTTP range
///    after a cancel, a lost connection or the app being closed), checked
///    against its size and SHA-256 and only then moved into the staging
///    directory.
/// 4. With every file verified, the local search index is built and must
///    answer a query; only then does one rename make the package active.
///
/// Until that rename an existing package stays active and readable, and a
/// failure at any step keeps what was verified for the next attempt.
final class DownloadQuranPackage {
  /// The use case over its ports.
  const new({
    required this._disk,
    required this._origin,
    required this._freeSpace,
    required this._buildIndex,
  });

  final QuranPackageDisk _disk;
  final QuranOrigin _origin;
  final ReadFreeSpace _freeSpace;
  final BuildSearchIndex _buildIndex;

  /// Space kept free beyond the package and its index.
  static const int safetyMarginBytes = 16 * 1024 * 1024;

  /// The statuses of one attempt; the last is [QuranReady], [QuranPaused]
  /// (resumable) or [QuranNotInstalled].
  Stream<QuranPackageStatus> call(DownloadCancel cancel) async* {
    var staged = await _disk.staging();
    if (staged == null) {
      yield const QuranDownloading(
        DownloadProgress(
          doneBytes: 0,
          totalBytes: QuranEditionPin.downloadBytes,
          doneFiles: 0,
          totalFiles: 0,
        ),
      );
      switch (await _startStaging()) {
        case Err(:final failure):
          yield QuranNotInstalled(failure: failure);
          return;
        case Ok(:final value):
          staged = value;
      }
    }
    final progress = _Progress(staged);
    if (await _checkSpace(staged) case final QuranFailure failure) {
      yield QuranPaused(progress.snapshot, failure: failure);
      return;
    }
    yield QuranDownloading(progress.snapshot);
    for (final file in staged.manifest.files) {
      if (staged.verified.contains(file.path)) continue;
      final failure = await _fetchFile(staged, file, progress, cancel);
      if (failure != null) {
        yield QuranPaused(progress.snapshot, failure: failure);
        return;
      }
      yield QuranDownloading(progress.snapshot);
    }
    yield const QuranInstalling();
    if (await _buildIndex(staged.directory) case Err(:final failure)) {
      yield QuranPaused(progress.snapshot, failure: failure);
      return;
    }
    switch (await _disk.activate(staged)) {
      case Ok(:final value):
        yield QuranReady(value);
      case Err(:final failure):
        yield QuranPaused(progress.snapshot, failure: failure);
    }
  }

  Future<Result<StagedQuran, QuranFailure>> _startStaging() async {
    final fetched = await _origin.manifest(
      maxBytes: QuranEditionPin.manifestBytes,
    );
    switch (fetched) {
      case Err(:final failure):
        return Result.err(failure);
      case Ok(value: final bytes):
        final manifest = acceptManifest(bytes);
        if (manifest == null) {
          return const Result.err(QuranIntegrityFailed('manifest.json'));
        }
        return _disk.startStaging(bytes, manifest);
    }
  }

  /// [bytes] decoded when they are the pinned manifest of the pinned
  /// package: every page present once and every path inside the package.
  static QuranPackageManifest? acceptManifest(List<int> bytes) {
    if (bytes.length != QuranEditionPin.manifestBytes ||
        sha256.convert(bytes).toString() != QuranEditionPin.manifestSha256) {
      return null;
    }
    final QuranPackageManifest manifest;
    try {
      manifest = switch (jsonDecode(utf8.decode(bytes))) {
        final Map<String, Object?> json => QuranPackageManifest.fromJson(json),
        _ => throw const FormatException('not an object'),
      };
    } on FormatException {
      return null;
    }
    final paths = manifest.files.map((f) => f.path).toSet();
    final pages = QuranEditionPin.layout.pageCount;
    final ok =
        manifest.packageId == QuranEditionPin.packageId &&
        manifest.version == QuranEditionPin.version &&
        manifest.layoutId == QuranEditionPin.layoutId &&
        manifest.edition.pageCount == pages &&
        paths.length == manifest.files.length &&
        paths.every(_safePath.hasMatch) &&
        paths.contains('quran.sqlite') &&
        [
          for (var p = 1; p <= pages; p++)
            manifest.pageImage.pathPattern.replaceFirst(
              '{page:03}',
              p.toString().padLeft(3, '0'),
            ),
        ].every(paths.contains);
    return ok ? manifest : null;
  }

  static final _safePath = RegExp(
    r'^[a-z0-9][a-z0-9_.-]*(/[a-z0-9_-][a-z0-9_.-]*)*$',
  );

  Future<QuranFailure?> _checkSpace(StagedQuran staged) async {
    final needed =
        staged.totalBytes -
        staged.doneBytes +
        QuranEditionPin.searchIndexBytes +
        safetyMarginBytes;
    final available = await _freeSpace(staged.directory);
    if (available != null && available < needed) {
      return QuranNoSpace(neededBytes: needed, availableBytes: available);
    }
    return null;
  }

  Future<QuranFailure?> _fetchFile(
    StagedQuran staged,
    QuranPackageFile file,
    _Progress progress,
    DownloadCancel cancel,
  ) async {
    // One retry: a file that fails its check twice is reported.
    for (var attempt = 0; attempt < 2; attempt++) {
      if (cancel.isCancelled) return const QuranCancelled();
      final fetched = await _origin.download(
        file.path,
        _disk.partPath(staged.directory, file.path),
        totalBytes: file.bytes,
        onBytes: progress.add,
        cancelled: () => cancel.isCancelled,
      );
      if (fetched case Err(:final failure)) return failure;
      switch (await _disk.commitFile(staged.directory, file)) {
        case Ok():
          progress.fileDone(file);
          return null;
        case Err(failure: final QuranIntegrityFailed failure):
          progress.fileDiscarded(file);
          if (attempt == 1) return failure;
        case Err(:final failure):
          return failure;
      }
    }
    return QuranIntegrityFailed(file.path);
  }
}

/// Progress of one attempt, from the staging state on disk.
final class _Progress {
  new(StagedQuran staged)
    : _bytes = staged.doneBytes,
      _files = staged.verified.length,
      _partial = Map.of(staged.partialBytes),
      _totalBytes = staged.totalBytes,
      _totalFiles = staged.manifest.files.length;

  int _bytes;
  int _files;
  final Map<String, int> _partial;
  final int _totalBytes;
  final int _totalFiles;

  void add(int bytes) => _bytes += bytes;

  void fileDone(QuranPackageFile file) {
    _files++;
    _partial.remove(file.path);
  }

  /// A file failed its check: its bytes no longer count.
  void fileDiscarded(QuranPackageFile file) {
    _bytes -= file.bytes;
    _partial.remove(file.path);
  }

  DownloadProgress get snapshot => DownloadProgress(
    doneBytes: _bytes < 0 ? 0 : (_bytes > _totalBytes ? _totalBytes : _bytes),
    totalBytes: _totalBytes,
    doneFiles: _files,
    totalFiles: _totalFiles,
  );
}
