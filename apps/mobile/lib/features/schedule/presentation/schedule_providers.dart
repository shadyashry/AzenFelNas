import 'package:daily_muslim/features/contexts/application/context_use_cases.dart';
import 'package:daily_muslim/features/schedule/application/calculate_schedule.dart';
import 'package:daily_muslim/features/schedule/application/load_runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/runtime_data.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Bound in `app/di.dart`.
final clockProvider = Provider<Clock>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bound in `app/di.dart`.
final loadRuntimeDataProvider = Provider<LoadRuntimeData>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bound in `app/di.dart`.
final calculateScheduleProvider = Provider<CalculateSchedule>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Bound in `app/di.dart`: the location use cases over loaded runtime data.
final contextUseCasesFactoryProvider =
    Provider<ContextUseCases Function(RuntimeData)>(
      (ref) => throw UnimplementedError('bound in app/di.dart'),
    );

/// The runtime data, loaded once after start-up imported the seeds.
final runtimeDataProvider = FutureProvider<Result<RuntimeData, Failure>>((
  ref,
) async {
  final load = ref.watch(loadRuntimeDataProvider);
  await ref.watch(appStartProvider.future);
  return await load();
});

/// The location use cases, or why the runtime data is missing.
final contextUseCasesProvider =
    FutureProvider<Result<ContextUseCases, Failure>>((ref) async {
      final build = ref.watch(contextUseCasesFactoryProvider);
      final data = await ref.watch(runtimeDataProvider.future);
      return data.map(build);
    });

/// A calculated schedule with the runtime data it was derived with.
typedef LoadedSchedule = ({Schedule schedule, RuntimeData data});

/// The active context's schedule: resolve the context, then calculate.
/// Invalidated when the user picks another place.
final scheduleProvider = FutureProvider<Result<LoadedSchedule, Failure>>((
  ref,
) async {
  final calculate = ref.watch(calculateScheduleProvider);
  final settings = ref.watch(watchSettingProvider);
  final useCases = await ref.watch(contextUseCasesProvider.future);
  final data = await ref.watch(runtimeDataProvider.future);
  final hijriOverrideDays = await settings
      .watch(AppSettings.hijriOverrideDays)
      .first;
  switch ((useCases, data)) {
    case (Err(:final failure), _) || (_, Err(:final failure)):
      return Err(failure);
    case (Ok(value: final useCases), Ok(value: final data)):
      final resolved = await useCases.resolve();
      return switch (resolved) {
        Err(:final failure) => Err(failure),
        Ok(value: final context) => calculate(
          context,
          data,
          hijriOverrideDays: hijriOverrideDays,
        ).map((schedule) => (schedule: schedule, data: data)),
      };
  }
});

/// The current instant, refreshed every [nowRefreshInterval] for countdowns.
final nowUtcMsProvider = StreamProvider<int>((ref) async* {
  final clock = ref.watch(clockProvider);
  yield clock.nowUtcMs();
  yield* Stream<int>.periodic(nowRefreshInterval, (_) => clock.nowUtcMs());
});

/// How often [nowUtcMsProvider] refreshes.
const Duration nowRefreshInterval = Duration(seconds: 30);
