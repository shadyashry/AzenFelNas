import 'package:daily_muslim/features/home/presentation/home_page.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_page.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// `onboardingComplete` (Appendix K).
final onboardingCompleteProvider = StreamProvider<bool>(
  (ref) =>
      ref.watch(watchSettingProvider).watch(AppSettings.onboardingComplete),
);

/// The root location: onboarding on the first run, Home afterwards.
final class HomeGate extends ConsumerWidget {
  /// The gate.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(onboardingCompleteProvider)) {
        AsyncData(value: true) => const HomePage(),
        AsyncData(value: false) => const OnboardingPage(),
        AsyncError(:final error, :final stackTrace) =>
          Error.throwWithStackTrace(error, stackTrace),
        AsyncLoading() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      };
}
