import 'package:daily_muslim/features/home/application/build_day_views.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/place_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/home/presentation/timeline_state.dart';
import 'package:daily_muslim/features/schedule/domain/next_prayer.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Home's state (§18.4).
final homeStateProvider = Provider<HomeState>((ref) {
  switch (ref.watch(scheduleProvider)) {
    case AsyncData(value: Err(:final failure)):
      return HomeState.ofFailure(failure);
    case AsyncData(value: Ok(value: final loaded)):
      final clock = ref.watch(clockProvider);
      final content = homeContentOf(loaded, clock.nowUtcMs());
      return loaded.schedule.engineDefault
          ? HomeNoProfile(content)
          : HomeReady(content);
    case AsyncError(:final error, :final stackTrace):
      Error.throwWithStackTrace(error, stackTrace);
    case AsyncLoading():
      return const HomeLoading();
  }
});

/// The day timeline's state (§18.4).
final timelineStateProvider = Provider<TimelineState>((ref) {
  switch (ref.watch(scheduleProvider)) {
    case AsyncData(value: Err(:final failure)):
      return TimelineError(failure);
    case AsyncData(value: Ok(value: final loaded)):
      return TimelineReady(
        BuildDayViews(loaded.data.tzdb)(
          loaded.schedule.days,
          loaded.schedule.zoneId,
        ),
      );
    case AsyncError(:final error, :final stackTrace):
      Error.throwWithStackTrace(error, stackTrace);
    case AsyncLoading():
      return const TimelineLoading();
  }
});

/// Home's content for [loaded] at [nowUtcMs]: today, the next prayer, the
/// sky phase of the observer's sun and the place.
HomeContent homeContentOf(LoadedSchedule loaded, int nowUtcMs) {
  final schedule = loaded.schedule;
  final views = BuildDayViews(loaded.data.tzdb)(schedule.days, schedule.zoneId);
  final next = NextPrayer.after(schedule.days, nowUtcMs);
  final solar = const ComputeSolarState()(
    observer: ObserverOf.context(schedule.context),
    utcMs: nowUtcMs,
  );
  final context = schedule.context.context;
  return HomeContent(
    day: views.first,
    nextPrayer: next == null ? null : _row(views[next.dayIndex], next),
    health: const AthanReadinessUnknown(),
    sky: SkyTheme.forPhase(solar.phase),
    place: PlaceView(kind: context.kind, label: context.place.label),
  );
}

TimeRowView _row(DayView day, NextPrayer next) =>
    day.rows.firstWhere((row) => row.event == next.time.event);
