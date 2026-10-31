import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_values.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The language of the app, chosen on the first screen (§15 D97, D126): a
/// compact English / العربية switch at the header's trailing edge, starting
/// from the device language; it is the Settings choice, so it applies at
/// once and persists. Each language is named in its own script, and the
/// two halves keep their left-to-right order in both languages.
final class LanguageChoice extends ConsumerWidget {
  /// The choice.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final shown = Localizations.localeOf(context).languageCode == 'ar'
        ? LocaleSetting.ar
        : LocaleSetting.en;
    void choose(LocaleSetting choice) =>
        ref.read(writeSettingProvider).write(AppSettings.locale, choice);
    return Semantics(
      label: l.settingsLanguage,
      container: true,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: EmeraldPalette.selectorTrack,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: EmeraldPalette.selectorBorder.withValues(
                alpha: EmeraldPalette.selectorBorderOpacity,
              ),
            ),
          ),
          // One row; at very large text the halves stack rather than
          // overflow.
          child: Wrap(
            children: [
              _Segment(
                label: 'English',
                script: StatusLocale.en,
                selected: shown == LocaleSetting.en,
                onTap: () => choose(LocaleSetting.en),
              ),
              _Segment(
                label: 'العربية',
                script: StatusLocale.ar,
                selected: shown == LocaleSetting.ar,
                onTap: () => choose(LocaleSetting.ar),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One language: a 48-unit tall target (Android's least) whose selected
/// state is an ivory pill.
final class _Segment extends StatelessWidget {
  const new({
    required this.label,
    required this.script,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final StatusLocale script;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    selected: selected,
    inMutuallyExclusiveGroup: true,
    label: label,
    // The node carries the tap itself: the ink below is excluded so the
    // label is read once.
    onTap: onTap,
    excludeSemantics: true,
    child: InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 36, minWidth: 64),
          child: DecoratedBox(
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: selected ? EmeraldPalette.selectorSelected : null,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  textDirection: switch (script) {
                    StatusLocale.en => TextDirection.ltr,
                    StatusLocale.ar => TextDirection.rtl,
                  },
                  style: WelcomeType.languageLabel(script).copyWith(
                    color: selected
                        ? EmeraldPalette.selectorSelectedText
                        : EmeraldPalette.selectorText,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
