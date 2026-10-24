import 'dart:ui';

import 'package:daily_muslim/features/athan/application/build_snapshot.dart';
import 'package:daily_muslim/features/athan/application/refresh_widget_snapshot.dart';
import 'package:daily_muslim/features/athan/application/write_widget_snapshot.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/schedule/presentation/schedule_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stores the widget snapshot natively (bound in `app/di.dart`).
final writeWidgetSnapshotProvider = Provider<WriteWidgetSnapshot>(
  (ref) => throw UnimplementedError('bound in app/di.dart'),
);

/// The widget snapshot, rewritten whenever the schedule, the locale or Athan
/// Health changes (REQ-WID-003); true when the host stored it. Home keeps it
/// alive, so it refreshes on every open.
final FutureProvider<bool> widgetSnapshotProvider =
    FutureProvider.autoDispose<bool>((ref) async {
      final loaded = await ref.watch(scheduleProvider.future);
      final locale = await ref.watch(localeSettingProvider.future);
      final health = await ref.watch(athanHealthProvider.future);
      switch (loaded) {
        case Err():
          return false;
        case Ok(value: final loaded):
          final refresh = RefreshWidgetSnapshot(
            BuildSnapshot(loaded.data.tzdb),
            ref.watch(writeWidgetSnapshotProvider),
            ref.watch(clockProvider),
          );
          return await refresh(
            loaded.schedule,
            locale: snapshotLocaleOf(
              locale,
              PlatformDispatcher.instance.locale.languageCode,
            ),
            health: snapshotHealthOf(health),
          );
      }
    });

/// The snapshot language of the `locale` setting; `system` follows the
/// device language [deviceLanguage] when it is Arabic, else English.
PlanLocale snapshotLocaleOf(LocaleSetting setting, String deviceLanguage) =>
    switch (setting) {
      LocaleSetting.ar => PlanLocale.ar,
      LocaleSetting.en => PlanLocale.en,
      LocaleSetting.system =>
        deviceLanguage == 'ar' ? PlanLocale.ar : PlanLocale.en,
    };

/// The snapshot's health of [health].
SnapshotHealth snapshotHealthOf(AthanHealth health) => SnapshotHealth(
  state: switch (health) {
    AthanHealthReady() => HealthStateCode.ready,
    AthanHealthLimited() => HealthStateCode.limited,
    AthanHealthNotReady() => HealthStateCode.notReady,
    AthanHealthUnknown() => HealthStateCode.unknown,
  },
  reasonsCount: health.reasons.length,
);
