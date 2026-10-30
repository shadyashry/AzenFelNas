import 'package:meta/meta.dart';

/// Why downloading, installing or opening the Quran package failed
/// (§15 D106). Each variant maps to one message and one action.
@immutable
sealed class QuranFailure {
  const new();
}

/// The CDN could not be reached (offline, DNS, timeout).
final class QuranOffline extends QuranFailure {
  /// The failure.
  const new();
}

/// The CDN answered with an error status.
final class QuranServerRefused extends QuranFailure {
  /// The failure for HTTP [status].
  const new(this.status);

  /// The HTTP status.
  final int status;

  @override
  bool operator ==(Object other) =>
      other is QuranServerRefused && other.status == status;

  @override
  int get hashCode => status.hashCode;
}

/// The device has less free space than the download needs.
final class QuranNoSpace extends QuranFailure {
  /// The failure with the [neededBytes] still to write and the
  /// [availableBytes] the platform reported (`null` when the write itself
  /// ran out of space).
  const new({required this.neededBytes, this.availableBytes});

  /// Bytes still needed, measured from the manifest.
  final int neededBytes;

  /// Free bytes reported by the platform.
  final int? availableBytes;

  @override
  bool operator ==(Object other) =>
      other is QuranNoSpace &&
      other.neededBytes == neededBytes &&
      other.availableBytes == availableBytes;

  @override
  int get hashCode => Object.hash(neededBytes, availableBytes);
}

/// A file's size or SHA-256 differs from the pinned manifest.
final class QuranIntegrityFailed extends QuranFailure {
  /// The failure for the package file at [path].
  const new(this.path);

  /// Path inside the package.
  final String path;

  @override
  bool operator ==(Object other) =>
      other is QuranIntegrityFailed && other.path == path;

  @override
  int get hashCode => path.hashCode;
}

/// Reading or writing app storage failed.
final class QuranStorageFailed extends QuranFailure {
  /// The failure with a [detail] for diagnostics (no paths with user data).
  const new(this.detail);

  /// What failed.
  final String detail;

  @override
  bool operator ==(Object other) =>
      other is QuranStorageFailed && other.detail == detail;

  @override
  int get hashCode => detail.hashCode;
}

/// The local search index could not be built or did not answer.
final class QuranSearchUnavailable extends QuranFailure {
  /// The failure.
  const new();
}

/// The reader cancelled the download.
final class QuranCancelled extends QuranFailure {
  /// The failure.
  const new();
}
