import 'package:daily_muslim/app/app_router.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_providers.dart';
import 'package:daily_muslim/features/home/presentation/home_state.dart';
import 'package:daily_muslim/features/onboarding/presentation/home_gate.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/features/shell/presentation/brand_intro.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root widget: language, theme and the router, all read from the Appendix K
/// settings. Locale changes presentation only (REQ-DOM-040).
final class DailyMuslimApp extends ConsumerStatefulWidget {
  /// The app; [initialLocation] and [intro] are for tests.
  const new({this.initialLocation = '/', this.intro = true, super.key});

  /// Where the router starts.
  final String initialLocation;

  /// Whether the opening intro plays (§15 D113); app tests that drive the
  /// screens leave it out, `brand_intro_test.dart` covers it.
  final bool intro;

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

  /// Whether the launch opened a link, so the intro is the short one and
  /// the linked page comes quickly (§15 D113).
  late final bool _linked =
      WidgetsBinding.instance.platformDispatcher.defaultRouteName !=
      Navigator.defaultRouteName;

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

  /// Whether the first screen has its content, so the intro can fade into
  /// it (§15 D101): the welcome step at once, Home once its times are in.
  bool _ready() => switch (ref.watch(onboardingCompleteProvider)) {
    AsyncData(value: true) => ref.watch(homeStateProvider) is! HomeLoading,
    AsyncData(value: false) || AsyncError() => true,
    AsyncLoading() => false,
  };

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
      // The launch screen's emerald continues into the app (§15 D100).
      // Status bar icons that read on the page's ground (§15 D101); pages
      // with an app bar or a dark field set their own.
      builder: (context, child) => AnnotatedRegion(
        value: DmTheme.statusBarOn(Theme.of(context).brightness),
        child: switch ((widget.intro, child)) {
          (true, final Widget app) => BrandIntro(
            // A linked page has its own loading states; it does not wait
            // for Home's times.
            ready: _linked || _ready(),
            brief: _linked,
            child: app,
          ),
          (false, final Widget app) => app,
          (_, null) => const SizedBox.shrink(),
        },
      ),
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
