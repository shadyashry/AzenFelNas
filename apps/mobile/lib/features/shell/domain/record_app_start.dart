/// Records that the app started (`APP_START`, Appendix J). Contract: never
/// throws.
abstract interface class RecordAppStart {
  /// Records a start at [utcMs].
  Future<void> call(int utcMs);
}
