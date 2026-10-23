/// The user's answer to the latest Athan Test, for Health's `failedTest`
/// (§15 D83).
abstract interface class ReadLastTestHeard {
  /// True or false from the newest `TEST_RESULT`; null when none is stored.
  Future<bool?> call();
}
