import 'package:daily_muslim/features/athan/application/apply_athan_plan.dart';
import 'package:daily_muslim/features/athan/application/apply_schedule_plan.dart';
import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/application/plan_schedule.dart';
import 'package:daily_muslim/features/athan/domain/plan_target.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/athan/presentation/widget_snapshot_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Plans the Athan days (bound in `app/di.dart`).
final planScheduleProvider = Provider<PlanSchedule>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// Hands plans to the native host (bound in `app/di.dart`).
final applySchedulePlanProvider = Provider<ApplySchedulePlan>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The Athan armed for the active place (§15 D94): planned again and handed
/// to the native host whenever the schedule, the place, the Athan choices,
/// the bundled sounds or the locale change; true when the host stored the
/// plan. Home and the Athan screen keep it alive, so it runs on every open.
final FutureProvider<bool> athanPlanProvider = FutureProvider.autoDispose<bool>(
  (ref) async {
    final loaded = await ref.watch(scheduleProvider.future);
    final enabled = await ref.watch(athanEnabledSettingProvider.future);
    final soundId = await ref.watch(athanSoundSettingProvider.future);
    final sounds = await ref.watch(athanSoundsProvider.future);
    final preReminder = await ref.watch(preReminderSettingProvider.future);
    final locale = await ref.watch(localeSettingProvider.future);
    final hijri = await ref.watch(hijriOverrideSettingProvider.future);
    switch (loaded) {
      case Err():
        return false;
      case Ok(value: final loaded):
        final settings = ref.watch(watchSettingProvider);
        final apply = ApplyAthanPlan(
          plan: ref.watch(planScheduleProvider),
          apply: ref.watch(applySchedulePlanProvider),
          read: settings,
          write: ref.watch(writeSettingProvider),
        );
        final applied = await apply(
          loaded.data,
          loaded.schedule.context,
          preferences: AthanPreferences.ofSettings(
            enabled: enabled,
            soundId: soundId,
            sounds: sounds,
            preReminderMinutes: preReminder,
            locale: snapshotLocaleOf(
              locale,
              PlatformDispatcher.instance.locale.languageCode,
            ),
          ),
          target: planTargetOf(defaultTargetPlatform),
          hijriOverrideDays: hijri,
        );
        return applied is Ok;
    }
  },
);

/// The plan target of [platform]: iOS fits its slot budget, every other
/// platform plans Android's 30 days.
PlanTarget planTargetOf(TargetPlatform platform) => switch (platform) {
  TargetPlatform.iOS => const IosPlanTarget(),
  TargetPlatform.android ||
  TargetPlatform.fuchsia ||
  TargetPlatform.linux ||
  TargetPlatform.macOS ||
  TargetPlatform.windows => const AndroidPlanTarget(),
};
