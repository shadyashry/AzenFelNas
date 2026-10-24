import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/contexts/domain/resolved_context.dart';
import 'package:meta/meta.dart';

/// What a plan is built for, apart from the runtime data (§7.7): the
/// context, the user's Athan choices, the platform and the next generation.
@immutable
final class PlanSubject {
  /// A subject for [context].
  const new({
    required this.context,
    required this.preferences,
    required this.target,
    required this.generation,
    this.hijriOverrideDays = 0,
  });

  /// The resolved location context.
  final ResolvedContext context;

  /// The user's Athan choices.
  final AthanPreferences preferences;

  /// The platform the plan is fitted for.
  final PlanTarget target;

  /// Plan generation, strictly above the last applied one.
  final int generation;

  /// The user's Hijri day override (US-07).
  final int hijriOverrideDays;
}
