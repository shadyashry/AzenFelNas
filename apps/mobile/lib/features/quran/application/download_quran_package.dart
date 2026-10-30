import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/domain/download_progress.dart';
import 'package:daily_muslim/features/quran/domain/quran_edition_pin.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest.dart';
import 'package:daily_muslim/features/quran/domain/quran_manifest_file.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_disk.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/domain/staged_quran.dart';
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
  /// The use case over its ports. `accept` decides whether downloaded
  /// manifest bytes are the pinned manifest (`QuranManifestCodec.acceptPinned`
  /// in the app);
  /// `extraBytes` is the free space needed beyond the files (the search
  /// index and a margin).
  const new({
    required this._disk,
    required this._origin,
    required this._freeSpace,
    required this._buildIndex,
    required this._accept,
    this._extraBytes = QuranEditionPin.searchIndexBytes + safetyMarginBytes,
  });

  final QuranPackageDisk _disk;
  final QuranOrigin _origin;
  final ReadFreeSpace _freeSpace;
  final BuildSearchIndex _buildIndex;
  final QuranManifest? Function(List<int> bytes) _accept;
  final int _extraBytes;

  /// Space kept free beyond the package and its index.
  static const int safetyMarginBytes = 16 * 1024 * 1024;

  /// The statuses of one attempt; the last is [QuranReady], [QuranPaused]
  /// (resumable) or [QuranNotInstalled].
  Stream<QuranPackageStatus> call(DownloadCancel cancel) async* {
    // An installed package stays readable during an update.
    final current = await _disk.active();
    var staged = await _disk.staging();
    if (staged == null) {
      yield QuranDownloading(
        const DownloadProgress(
          doneBytes: 0,
          totalBytes: QuranEditionPin.downloadBytes,
          doneFiles: 0,
          totalFiles: 0,
        ),
        current: current,
      );
      switch (await _startStaging()) {
        case Err(:final failure):
          yield current == null
              ? QuranNotInstalled(failure: failure)
              : QuranReady(current, updateAvailable: true);
          return;
        case Ok(:final value):
          staged = value;
      }
    }
    final progress = _Progress(staged);
    QuranPaused paused(QuranFailure failure) =>
        QuranPaused(progress.snapshot, failure: failure, current: current);
    if (await _checkSpace(staged) case final QuranFailure failure) {
      yield paused(failure);
      return;
    }
    yield QuranDownloading(progress.snapshot, current: current);
    for (final file in staged.manifest.files) {
      if (staged.verified.contains(file.path)) continue;
      final failure = await _fetchFile(staged, file, progress, cancel);
      if (failure != null) {
        yield paused(failure);
        return;
      }
      yield QuranDownloading(progress.snapshot, current: current);
    }
    yield QuranInstalling(current: current);
    if (await _buildIndex(staged.directory) case Err(:final failure)) {
      yield paused(failure);
      return;
    }
    switch (await _disk.activate(staged)) {
      case Ok(:final value):
        yield QuranReady(value);
      case Err(:final failure):
        yield paused(failure);
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
        final manifest = _accept(bytes);
        if (manifest == null) {
          return const Result.err(QuranIntegrityFailed('manifest.json'));
        }
        return await _disk.startStaging(bytes, manifest);
    }
  }

  Future<QuranFailure?> _checkSpace(StagedQuran staged) async {
    final needed = staged.totalBytes - staged.doneBytes + _extraBytes;
    final available = await _freeSpace(staged.directory);
    if (available != null && available < needed) {
      return QuranNoSpace(neededBytes: needed, availableBytes: available);
    }
    return null;
  }

  Future<QuranFailure?> _fetchFile(
    StagedQuran staged,
    QuranManifestFile file,
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
        case Err(:final QuranIntegrityFailed failure):
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

  void fileDone(QuranManifestFile file) {
    _files++;
    _partial.remove(file.path);
  }

  /// A file failed its check: its bytes no longer count.
  void fileDiscarded(QuranManifestFile file) {
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
