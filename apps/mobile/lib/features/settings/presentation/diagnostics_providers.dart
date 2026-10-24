import 'package:daily_muslim/features/settings/application/assemble_diagnostic_bundle.dart';
import 'package:daily_muslim/features/settings/application/export_diagnostic_bundle.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bound in `app/di.dart`.
final assembleDiagnosticBundleProvider = Provider<AssembleDiagnosticBundle>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bound in `app/di.dart`.
final exportDiagnosticBundleProvider = Provider<ExportDiagnosticBundle>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The text the Diagnostics page shows and exports (REQ-PRIV-005).
final FutureProvider<String> diagnosticTextProvider =
    FutureProvider.autoDispose<String>(
      (ref) async => ExportDiagnosticBundle.textOf(
        await ref.watch(assembleDiagnosticBundleProvider).call(),
      ),
    );
