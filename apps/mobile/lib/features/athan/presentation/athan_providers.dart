import 'package:daily_muslim/features/athan/application/evaluate_athan_health.dart';
import 'package:daily_muslim/features/athan/application/record_athan_test_result.dart';
import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/read_athan_sound_names.dart';
import 'package:daily_muslim/features/athan/domain/read_athan_sounds.dart';
import 'package:daily_muslim/features/athan/domain/read_last_test_heard.dart';
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
final drainNativeEventsProvider = Provider<DrainNativeEvents>(
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

/// Asks the user for an Athan permission (bound in `app/di.dart`).
final requestAthanGrantProvider = Provider<RequestAthanGrant>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The bundled Athan sounds (bound in `app/di.dart`).
final readAthanSoundsProvider = Provider<ReadAthanSounds>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The bundled sounds' names, bound in `app/di.dart`; none until bound
/// (§15 D123).
final readAthanSoundNamesProvider = Provider<ReadAthanSoundNames>(
  (ref) => const _NoSoundNames(),
);

final class _NoSoundNames implements ReadAthanSoundNames {
  const new();

  @override
  Future<Map<String, SoundName>> call() async => const {};
}

/// Athan Health, re-evaluated whenever the provider is refreshed (§8.3:
/// on open and after events); loading is the `evaluating` state.
final FutureProvider<AthanHealth> athanHealthProvider =
    FutureProvider.autoDispose<AthanHealth>((
      ref,
    ) async {
      final report = await ref.watch(readPlatformHealthProvider).call();
      final heard = await ref.watch(readLastTestHeardProvider).call();
      return const EvaluateAthanHealth()(report, lastTestHeard: heard);
    });

/// The bundled Athan sounds.
final FutureProvider<List<String>> athanSoundsProvider =
    FutureProvider.autoDispose<List<String>>(
      (ref) => ref.watch(readAthanSoundsProvider).call(),
    );

/// The bundled sounds' names (§15 D123).
final FutureProvider<Map<String, SoundName>> athanSoundNamesProvider =
    FutureProvider.autoDispose<Map<String, SoundName>>(
      (ref) => ref.watch(readAthanSoundNamesProvider).call(),
    );

/// One tick per second while the Athan page is open.
final StreamProvider<int> athanTicksProvider = StreamProvider.autoDispose<int>(
  (ref) => Stream<int>.periodic(const Duration(seconds: 1), (i) => i),
);
