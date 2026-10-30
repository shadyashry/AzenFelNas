import 'package:meta/meta.dart';

/// How far a download has come, in verified bytes and files.
@immutable
final class DownloadProgress {
  /// The progress.
  const new({
    required this.doneBytes,
    required this.totalBytes,
    required this.doneFiles,
    required this.totalFiles,
  });

  /// Bytes written and verified, including partial files.
  final int doneBytes;

  /// Bytes in the package.
  final int totalBytes;

  /// Files verified.
  final int doneFiles;

  /// Files in the package.
  final int totalFiles;

  /// 0..1.
  double get fraction =>
      totalBytes == 0 ? 0 : (doneBytes / totalBytes).clamp(0, 1).toDouble();

  @override
  bool operator ==(Object other) =>
      other is DownloadProgress &&
      other.doneBytes == doneBytes &&
      other.totalBytes == totalBytes &&
      other.doneFiles == doneFiles &&
      other.totalFiles == totalFiles;

  @override
  int get hashCode => Object.hash(doneBytes, totalBytes, doneFiles, totalFiles);
}
