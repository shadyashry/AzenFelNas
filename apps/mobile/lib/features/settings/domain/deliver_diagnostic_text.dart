/// Hands the diagnostic bundle text to the user, outside the app's egress
/// paths (§15 D84): the user decides where it goes.
abstract interface class DeliverDiagnosticText {
  /// True when [text] was handed over.
  Future<bool> call(String text);
}
