import 'package:daily_muslim/app/app_router.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root widget: language, theme and the router, all read from the Appendix K
/// settings. Locale changes presentation only (REQ-DOM-040).
final class DailyMuslimApp extends ConsumerStatefulWidget {
  /// The app; [initialLocation] is for tests.
  const new({this.initialLocation = '/', super.key});

  /// Where the router starts.
  final String initialLocation;

  @override
  ConsumerState<DailyMuslimApp> createState() => _DailyMuslimAppState();
}

final class _DailyMuslimAppState extends ConsumerState<DailyMuslimApp> {
  late final GoRouter _router = AppRouter.create(
    initialLocation: widget.initialLocation,
  );

  /// Back from system settings (a permission, a muted channel), Athan Health
  /// is evaluated again (§15 D96).
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(athanHealthProvider),
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(packageSyncProvider, (_, _) {});
    final locale = ref.watch(localeSettingProvider).value;
    final mode = ref.watch(themeModeSettingProvider).value;
    final status = locale == LocaleSetting.ar
        ? StatusLocale.ar
        : StatusLocale.en;
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      routerConfig: _router,
      locale: switch (locale) {
        LocaleSetting.ar => const Locale('ar'),
        LocaleSetting.en => const Locale('en'),
        LocaleSetting.system || null => null,
      },
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: DmTheme.of(Brightness.light, status),
      darkTheme: DmTheme.of(Brightness.dark, status),
      themeMode: switch (mode) {
        ThemeModeSetting.light => ThemeMode.light,
        ThemeModeSetting.dark => ThemeMode.dark,
        ThemeModeSetting.sky ||
        ThemeModeSetting.system ||
        null => ThemeMode.system,
      },
    );
  }
}
