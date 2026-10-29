import 'package:daily_muslim/features/qibla/application/find_shadow_times.dart';
import 'package:daily_muslim/features/qibla/application/observe_heading.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/qibla/domain/shadow_times.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// The compass port, bound in `app/di.dart`.
final headingSourceProvider = Provider<HeadingSource>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The active place as an engine [Observer] with the pinned TZDB that
/// reads its local time; `null` when no place resolves (no context yet, or
/// the runtime data failed).
final FutureProvider<({Observer observer, PinnedTzDatabase tzdb})?>
qiblaPlaceProvider = FutureProvider.autoDispose((ref) async {
  final useCases = await ref.watch(contextUseCasesProvider.future);
  final data = await ref.watch(runtimeDataProvider.future);
  switch ((useCases, data)) {
    case (Ok(value: final useCases), Ok(value: final data)):
      return switch (await useCases.resolve()) {
        Ok(:final value) => (
          observer: ObserverOf.context(value),
          tzdb: data.tzdb,
        ),
        Err() => null,
      };
    case (Err(), _) || (_, Err()):
      return null;
  }
});

/// The Qibla screen state; `null` data when no place resolves.
final StreamProvider<QiblaState?> qiblaStateProvider =
    StreamProvider.autoDispose<QiblaState?>((
      ref,
    ) async* {
      final observe = ObserveHeading(ref.watch(headingSourceProvider));
      final place = await ref.watch(qiblaPlaceProvider.future);
      if (place == null) {
        yield null;
      } else {
        yield* observe(place.observer);
      }
    });

/// The sensor-free Qibla of the active place (§15 D91); `null` data when
/// no place resolves.
final FutureProvider<ShadowTimes?> shadowTimesProvider =
    FutureProvider.autoDispose((ref) async {
      final place = await ref.watch(qiblaPlaceProvider.future);
      if (place == null) return null;
      return FindShadowTimes(
        place.tzdb,
      )(place.observer, nowUtcMs: ref.watch(clockProvider).nowUtcMs());
    });
