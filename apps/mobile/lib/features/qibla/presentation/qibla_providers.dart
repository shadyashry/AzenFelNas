import 'package:daily_muslim/features/qibla/application/observe_heading.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';
import 'package:daily_muslim/features/qibla/domain/qibla_state.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The compass port, bound in `app/di.dart`.
final headingSourceProvider = Provider<HeadingSource>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The Qibla screen state; `null` data when no place resolves (no context
/// yet, or the runtime data failed).
final StreamProvider<QiblaState?> qiblaStateProvider =
    StreamProvider.autoDispose<QiblaState?>((
      ref,
    ) async* {
      final observe = ObserveHeading(ref.watch(headingSourceProvider));
      final useCases = await ref.watch(contextUseCasesProvider.future);
      final context = switch (useCases) {
        Ok(:final value) => switch (await value.resolve()) {
          Ok(:final value) => value,
          Err() => null,
        },
        Err() => null,
      };
      if (context == null) {
        yield null;
      } else {
        yield* observe(ObserverOf.context(context));
      }
    });
