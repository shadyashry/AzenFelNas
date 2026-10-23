import 'package:daily_muslim/features/home/domain/day_view.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// Day timeline (§18.4): `loading`, `ready(days)`, `error`.
sealed class TimelineState {
  const new();
}

/// The days are being prepared.
final class TimelineLoading extends TimelineState {
  /// The state.
  const new();
}

/// The days from today.
final class TimelineReady extends TimelineState {
  /// The state over [days].
  const new(this.days);

  /// Consecutive days, today first.
  final List<DayView> days;
}

/// No days: [failure] says why.
final class TimelineError extends TimelineState {
  /// The state.
  const new(this.failure);

  /// What went wrong.
  final Failure failure;
}
