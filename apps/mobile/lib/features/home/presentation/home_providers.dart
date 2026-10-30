import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/home/application/build_day_views.dart';
import 'package:daily_muslim/features/home/application/build_fasting_day.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/fasting_day.dart';
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

/// The gazetteer place Home's header names (§15 D101, D104): the place the
/// device location is in, or the place a chosen place's label names, so the
/// header reads in the reader's language; `null` while loading, when no
/// place is near, or for a name the user typed.
final placeNameProvider = FutureProvider<GazetteerHit?>((ref) async {
  final loaded = switch (ref.watch(scheduleProvider)) {
    AsyncData(value: Ok(:final value)) => value,
    AsyncData() || AsyncError() || AsyncLoading() => null,
  };
  final context = loaded?.schedule.context.context;
  if (context == null) return null;
  return switch (await ref.watch(contextUseCasesProvider.future)) {
    Ok(value: final useCases) => switch (context.kind) {
      ContextKind.current => await useCases.nameNearest(context.place.point),
      ContextKind.pinned || ContextKind.manual => await useCases.nameStored(
        context.place.point,
        context.place.label,
      ),
    },
    Err() => null,
  };
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

/// Home's Ramadan card (REQ-RAM-001): the fasting day of the shown
/// schedule, or nothing while it loads or fails.
final fastingDayProvider = Provider<FastingDay>((ref) {
  switch (ref.watch(scheduleProvider)) {
    case AsyncData(value: Ok(value: final loaded)):
      final schedule = loaded.schedule;
      return const BuildFastingDay()(
        views: BuildDayViews(loaded.data.tzdb)(schedule.days, schedule.zoneId),
        hijri: [for (final inputs in schedule.inputs) inputs.hijri],
        nowUtcMs: ref.watch(clockProvider).nowUtcMs(),
      );
    case AsyncData() || AsyncError() || AsyncLoading():
      return const NotFasting();
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
    hijri: schedule.inputs.isEmpty
        ? null
        : schedule.inputs.first.hijri.dateAtDawn,
  );
}

TimeRowView _row(DayView day, NextPrayer next) =>
    day.rows.firstWhere((row) => row.event == next.time.event);

/// The light of the current prayer interval (§15 D89): Home's field and
/// the active navigation tab follow it; the day light while Home has no
/// schedule.
final hourLightProvider = Provider<HourLight>(
  (ref) => switch (ref.watch(homeStateProvider)) {
    HomeReady(:final content) || HomeNoProfile(:final content) =>
      HourLight.before(content.nextPrayer?.event),
    HomeLoading() ||
    HomeNeedsLocation() ||
    HomeNeedsAttention() ||
    HomeError() => HourLight.day,
  },
);

/// The Qibla bearing of the scheduled place, for the navigation needle;
/// `null` until a schedule loads.
final qiblaBearingProvider = Provider<double?>(
  (ref) => switch (ref.watch(scheduleProvider)) {
    AsyncData(value: Ok(value: final loaded)) => const CalculateQibla()(
      ObserverOf.context(loaded.schedule.context),
    ).bearingDeg,
    AsyncData() || AsyncError() || AsyncLoading() => null,
  },
);
