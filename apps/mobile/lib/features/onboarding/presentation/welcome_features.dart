import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// What the app does, in three evenly spaced marks at the foot of the
/// welcome panel (§15 D126): information, not buttons or cards.
final class WelcomeFeatures extends StatelessWidget {
  /// The marks, captioned in [type].
  const new({required this.type, super.key});

  /// The type scale of the language shown.
  final WelcomeType type;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (icon, label) in [
          (Icons.cloud_off_outlined, l.welcomeFeatureOffline),
          (Icons.notifications_active_outlined, l.welcomeFeatureAlerts),
          (Icons.explore_outlined, l.welcomeFeatureQibla),
        ])
          Expanded(
            child: MergeSemantics(
              child: Column(
                children: [
                  Icon(icon, size: 22, color: EmeraldPalette.inkMuted),
                  const SizedBox(height: 7),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: type.caption.copyWith(
                      color: EmeraldPalette.inkMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
