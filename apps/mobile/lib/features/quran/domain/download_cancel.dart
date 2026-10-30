/// Lets the reader stop a download; checked between chunks.
final class DownloadCancel {
  /// A token that is not cancelled.
  new();

  bool _cancelled = false;

  /// Whether [cancel] was called.
  bool get isCancelled => _cancelled;

  /// Stops the download at the next chunk; what is on disk is kept.
  void cancel() => _cancelled = true;
}
