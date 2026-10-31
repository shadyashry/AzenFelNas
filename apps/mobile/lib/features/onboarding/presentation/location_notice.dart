import 'package:daily_muslim/features/contexts/domain/gazetteer_hit.dart';
import 'package:daily_muslim/features/contexts/presentation/manual_place_view.dart';
import 'package:daily_muslim/features/onboarding/presentation/onboarding_controller.dart';
import 'package:daily_muslim/features/onboarding/presentation/welcome_action.dart';
import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_action.dart';
import 'package:daily_muslim/features/shell/presentation/remediation_copy.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Why location did not work, inside the welcome panel (§18.3, §15 D98,
/// D100, D126): the fix in words, the failure code on a long press for
/// support, the city the phone's time zone suggests (one tap), and the
/// system setting that fixes it only when one does, opened only when the
/// user taps it (back from it, location is tried again). *Use my location*
/// and *Choose a city instead* stay below it.
final class LocationNotice extends ConsumerWidget {
  /// The notice for [notice], offering [suggestion] when there is one.
  const new({
    required this.notice,
    required this.suggestion,
    required this.type,
    super.key,
  });

  /// The failure's code and remediation.
  final NeedsAttention notice;

  /// The city of the phone's time zone, or `null`.
  final GazetteerHit? suggestion;

  /// The type scale of the language shown.
  final WelcomeType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingProvider.notifier);
    final settings = RemediationAction.hasAction(notice.remediation);
    final place = suggestion;
    return Semantics(
      liveRegion: true,
      container: true,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: EmeraldPalette.wash,
          borderRadius: BorderRadius.circular(17),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Tooltip(
                message: l.needsAttentionCode(notice.code.wire),
                triggerMode: TooltipTriggerMode.longPress,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_disabled_outlined,
                      size: 20,
                      color: EmeraldPalette.ink,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.onboardingFailedTitle,
                        style: type.action.copyWith(color: EmeraldPalette.ink),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                RemediationCopy.of(l, notice.remediation),
                style: _detail(type),
              ),
              if (place != null)
                Text(
                  l.onboardingSuggestion(place.displayName),
                  style: _detail(type),
                ),
              if (place != null) ...[
                const SizedBox(height: 12),
                WelcomeAction(
                  key: const Key('onboardingUseSuggestion'),
                  // Quieter than *Use my location* below it.
                  kind: WelcomeActionKind.secondary,
                  label: l.onboardingUseSuggestion(place.displayName),
                  textStyle: type.action,
                  icon: Icons.check,
                  onPressed: () => controller.useSuggestion(place),
                ),
                if (subtitleOf(place) case final String detail
                    when detail.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      detail,
                      textAlign: TextAlign.center,
                      style: type.privacy.copyWith(
                        color: EmeraldPalette.inkMuted,
                      ),
                    ),
                  ),
              ],
              if (settings) ...[
                const SizedBox(height: 10),
                Theme(
                  data: Theme.of(context).copyWith(
                    outlinedButtonTheme: _settingsButton,
                    filledButtonTheme: FilledButtonThemeData(
                      style: _settingsButton.style,
                    ),
                  ),
                  child: RemediationAction(
                    notice.remediation,
                    onReturn: controller.useApproximateLocation,
                    secondary: true,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The notice's smaller lines.
TextStyle _detail(WelcomeType type) => type.privacy.copyWith(
  color: EmeraldPalette.inkMuted,
  fontSize: 13,
  height: 20 / 13,
);

/// The settings button in the panel's secondary look.
final OutlinedButtonThemeData _settingsButton = OutlinedButtonThemeData(
  style: OutlinedButton.styleFrom(
    minimumSize: const Size(64, 48),
    foregroundColor: EmeraldPalette.ink,
    backgroundColor: EmeraldPalette.surface,
    side: const BorderSide(color: EmeraldPalette.surfaceBorder),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17)),
  ),
);
