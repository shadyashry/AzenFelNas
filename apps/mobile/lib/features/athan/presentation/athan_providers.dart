import 'package:daily_muslim/features/athan/application/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/application/drain_athan_events.dart';
import 'package:daily_muslim/features/athan/application/evaluate_athan_health.dart';
import 'package:daily_muslim/features/athan/application/read_athan_sounds.dart';
import 'package:daily_muslim/features/athan/application/read_last_test_heard.dart';
import 'package:daily_muslim/features/athan/application/record_athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Native probes (bound in `app/di.dart`).
final readPlatformHealthProvider = Provider<ReadPlatformHealth>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Arms the Athan Test (bound in `app/di.dart`).
final armAthanTestProvider = Provider<ArmAthanTest>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Drains native events into the event log (bound in `app/di.dart`).
final drainAthanEventsProvider = Provider<DrainAthanEvents>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Stores Test answers (bound in `app/di.dart`).
final recordAthanTestResultProvider = Provider<RecordAthanTestResult>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The latest Test answer (bound in `app/di.dart`).
final readLastTestHeardProvider = Provider<ReadLastTestHeard>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The bundled Athan sounds (bound in `app/di.dart`).
final readAthanSoundsProvider = Provider<ReadAthanSounds>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Athan Health, re-evaluated whenever the provider is refreshed (§8.3:
/// on open and after events); loading is the `evaluating` state.
final athanHealthProvider = FutureProvider.autoDispose<AthanHealth>((
  ref,
) async {
  final report = await ref.watch(readPlatformHealthProvider).call();
  final heard = await ref.watch(readLastTestHeardProvider).call();
  return const EvaluateAthanHealth()(report, lastTestHeard: heard);
});

/// The bundled Athan sounds.
final athanSoundsProvider = FutureProvider.autoDispose<List<AthanSound>>(
  (ref) => ref.watch(readAthanSoundsProvider).call(),
);

/// One tick per second while the Athan page is open.
final athanTicksProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream<int>.periodic(const Duration(seconds: 1), (i) => i),
);
