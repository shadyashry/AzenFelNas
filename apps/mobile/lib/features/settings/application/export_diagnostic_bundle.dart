import 'dart:convert';

import 'package:daily_muslim/features/settings/domain/deliver_diagnostic_text.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Exports exactly the text the user was shown (REQ-PRIV-005, §15 D84). A
/// refused hand-over is `DIAG_EXPORT_FAILED`; Appendix J has no event code
/// for an export, so neither outcome is written to the event log.
final class ExportDiagnosticBundle {
  /// The use case over [_deliver].
  const new(this._deliver);

  final DeliverDiagnosticText _deliver;

  /// The text shown in the preview and exported: indented JSON of [bundle].
  static String textOf(DiagnosticBundle bundle) =>
      const JsonEncoder.withIndent('  ').convert(bundle.toJson());

  /// Hands [shownText] over.
  Future<Result<void, FailureCode>> call(String shownText) async =>
      await _deliver(shownText)
      ? const Result.ok(null)
      : const Result.err(FailureCode.diagExportFailed);
}
