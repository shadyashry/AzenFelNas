import 'package:daily_muslim/features/settings/domain/deliver_diagnostic_text.dart';
import 'package:flutter/services.dart';

/// [DeliverDiagnosticText] through the system clipboard: the text leaves the
/// app only when the user pastes it somewhere (§15 D84). No share-sheet
/// dependency, as for Calculation links (D78).
final class ClipboardDiagnosticText implements DeliverDiagnosticText {
  /// The adapter.
  const new();

  @override
  Future<bool> call(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      return true;
    } on PlatformException {
      return false;
    }
  }
}
