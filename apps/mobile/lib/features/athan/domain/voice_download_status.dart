import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:meta/meta.dart';

/// Where one voice download stands (§15 D111).
@immutable
sealed class VoiceDownloadStatus {
  const new();
}

/// Bytes are arriving; [doneBytes] includes a resumed partial file.
final class VoiceDownloading extends VoiceDownloadStatus {
  /// The status.
  const new({required this.doneBytes, required this.totalBytes});

  /// Bytes on disk.
  final int doneBytes;

  /// Size of the file.
  final int totalBytes;

  /// 0..1.
  double get fraction =>
      totalBytes == 0 ? 0 : (doneBytes / totalBytes).clamp(0, 1).toDouble();

  @override
  bool operator ==(Object other) =>
      other is VoiceDownloading &&
      other.doneBytes == doneBytes &&
      other.totalBytes == totalBytes;

  @override
  int get hashCode => Object.hash(doneBytes, totalBytes);
}

/// Verified, on disk and handed to the alarm player (REQ-ALM-051).
final class VoiceDownloaded extends VoiceDownloadStatus {
  /// The status.
  const new();
}

/// Stopped by [failure]; verified bytes are kept for the next attempt.
final class VoiceDownloadFailed extends VoiceDownloadStatus {
  /// The status.
  const new(this.failure);

  /// Why.
  final VoiceFailure failure;
}
