/// Why a voice download or install stopped (§15 D111). Every failure keeps
/// the bytes already verified, so trying again resumes.
sealed class VoiceFailure {
  const new();
}

/// No connection, or the server stopped answering.
final class VoiceOffline extends VoiceFailure {
  /// The failure.
  const new();
}

/// The CDN answered with another status than the file.
final class VoiceServerRefused extends VoiceFailure {
  /// The failure with HTTP [status].
  const new(this.status);

  /// The HTTP status.
  final int status;
}

/// Not enough free space for the file.
final class VoiceNoSpace extends VoiceFailure {
  /// The failure.
  const new({required this.neededBytes});

  /// Bytes the download still needs.
  final int neededBytes;
}

/// The downloaded bytes did not match the pinned size and SHA-256; they were
/// deleted.
final class VoiceIntegrityFailed extends VoiceFailure {
  /// The failure.
  const new();
}

/// The file could not be written, moved or handed to the alarm player.
final class VoiceStorageFailed extends VoiceFailure {
  /// The failure with the platform's [detail] (never shown).
  const new(this.detail);

  /// What the platform said.
  final String detail;
}

/// The user cancelled; the partial file is kept.
final class VoiceCancelled extends VoiceFailure {
  /// The failure.
  const new();
}
