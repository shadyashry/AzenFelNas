import 'package:daily_muslim/features/contexts/domain/location_failure.dart';
import 'package:daily_muslim/features/home/domain/athan_readiness.dart';
import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:daily_muslim/features/home/domain/place_view.dart';
import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:daily_muslim/features/shell/application/describe_failure.dart';
import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Home (§18.4): `loading`, `ready(day, nextPrayer, health, sky)`,
/// `needsLocation`, `needsAttention(reasons)`, `noProfile(engineDefault)`,
/// `error(failure)`. Rendered by an exhaustive switch.
sealed class HomeState {
  const new();

  /// The state for a [failure] on the way to a schedule (§15 D77): a
  /// location failure asks for a place, an engine failure is an error, and
  /// anything else (data, storage, profiles) needs attention with its
  /// remediation.
  static HomeState ofFailure(Failure failure) => switch (failure) {
    LocationFailure() => const HomeNeedsLocation(),
    EngineFailure() => HomeError(failure),
    _ => HomeNeedsAttention([const DescribeFailure()(failure)]),
  };
}

/// The schedule is being prepared.
final class HomeLoading extends HomeState {
  /// The state.
  const new();
}

/// Today's times under a local profile.
final class HomeReady extends HomeState {
  /// The state over [content].
  const new(this.content);

  /// What Home shows.
  final HomeContent content;
}

/// No usable place: location refused or unavailable and no manual place.
final class HomeNeedsLocation extends HomeState {
  /// The state.
  const new();
}

/// The schedule cannot be prepared until the user acts on [reasons].
final class HomeNeedsAttention extends HomeState {
  /// The state.
  const new(this.reasons);

  /// What to do, most important first; never empty.
  final List<NeedsAttention> reasons;
}

/// Today's times under `engine.default`: there is no local profile here and
/// the user is told so (US-06, ADR-007).
final class HomeNoProfile extends HomeState {
  /// The state over [content].
  const new(this.content);

  /// What Home shows.
  final HomeContent content;
}

/// The engine refused the day (e.g. `ENGINE_ORDERING`).
final class HomeError extends HomeState {
  /// The state.
  const new(this.failure);

  /// What went wrong.
  final Failure failure;
}

/// The content of [HomeReady] and [HomeNoProfile].
@immutable
final class HomeContent {
  /// Today, the next prayer, Athan readiness, the sky and the place.
  const new({
    required this.day,
    required this.nextPrayer,
    required this.health,
    required this.sky,
    required this.place,
    this.hijri,
  });

  /// Today.
  final DayView day;

  /// The next prayer (possibly tomorrow's Fajr), `null` when none follows.
  final TimeRowView? nextPrayer;

  /// Athan readiness.
  final AthanReadiness health;

  /// The sky of the observer's sun now (§7.9).
  final SkyTheme sky;

  /// The place calculated for.
  final PlaceView place;

  /// Today's Hijri date at dawn, for the header and its Moon (§15 D89);
  /// `null` when the schedule carries none.
  final HijriDate? hijri;
}
