import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/shell/application/start_app.dart';
import 'package:daily_muslim/features/shell/domain/start_report.dart';
import 'package:dm_packages/dm_packages.dart';
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

/// The package sync (§7.4), bound in `app/di.dart`; null on a channel whose
/// root keys this binary does not embed yet (beta and production until S27).
final syncPackagesProvider = Provider<SyncPackages?>((ref) => null);

/// One sync per process on app open, after the start-up work and never in
/// the alarm path (REQ-PKG-004 rate-limits it to every 6 h). Its failures
/// are in the report and the event log; the data in use stays active
/// (REQ-PKG-001), and an activated package is read at the next start.
final packageSyncProvider = FutureProvider<SyncReport?>((ref) async {
  await ref.watch(appStartProvider.future);
  final sync = ref.watch(syncPackagesProvider);
  if (sync == null) return null;
  return await sync(nowUtcMs: ref.read(clockProvider).nowUtcMs());
});
