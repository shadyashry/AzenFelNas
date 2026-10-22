import 'package:daily_muslim/features/shell/application/start_app.dart';
import 'package:daily_muslim/features/shell/domain/start_report.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bound in `app/di.dart`.
final startAppProvider = Provider<StartApp>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The start-up work, run once per process; screens that need the bundled
/// data (S17) wait on it.
final appStartProvider = FutureProvider<StartReport>(
  (ref) => ref.watch(startAppProvider).call(),
);
