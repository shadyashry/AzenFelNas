import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/shell/domain/record_app_start.dart';
import 'package:daily_muslim/features/shell/domain/start_report.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// The work of every app start, after the databases are open: log
/// `APP_START`, drain native Athan events (REQ-ALM-041), import the bundled
/// seeds (REQ-PKG-003) and collect package
/// garbage (§7.4). Never in the alarm path; offline by construction.
final class StartApp {
  /// The use case.
  const new({
    required this._importSeeds,
    required this._collectGarbage,
    required this._recordStart,
    required this._drainNativeEvents,
    required this._clock,
  });

  final ImportBundledSeeds _importSeeds;
  final CollectPackageGarbage _collectGarbage;
  final RecordAppStart _recordStart;
  final DrainNativeEvents _drainNativeEvents;
  final Clock _clock;

  /// Runs the start-up work once.
  Future<StartReport> call() async {
    final now = _clock.nowUtcMs();
    await _recordStart(now);
    await _drainNativeEvents();
    final seeds = await _importSeeds(nowUtcMs: now);
    final garbage = await _collectGarbage(nowUtcMs: now);
    return StartReport(seeds: seeds, garbage: garbage);
  }
}
