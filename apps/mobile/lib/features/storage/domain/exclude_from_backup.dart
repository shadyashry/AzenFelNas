/// Keeps a directory and everything in it out of OS backups (REQ-PRIV-003).
///
/// Contract: idempotent; safe to call on every start (iOS can clear the flag
/// on restore); never throws. Returns `false` when the platform refused, so
/// the caller can record it; the directory stays usable either way.
abstract interface class ExcludeFromBackup {
  /// Excludes the directory at [directoryPath].
  Future<bool> call(String directoryPath);
}
