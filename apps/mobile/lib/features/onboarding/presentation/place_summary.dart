import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The selected place on the setup-completion screen (§15 D127): a pin,
/// *Selected location*, the place in the reader's language and *Change*,
/// which reopens the city picker.
final class PlaceSummary extends StatelessWidget {
  /// The summary of [place].
  const new({
    required this.place,
    required this.type,
    required this.onChange,
    super.key,
  });

  /// The place and its country, as shown.
  final String place;

  /// The type scale of the language shown.
  final WelcomeType type;

  /// Reopens the city picker.
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final small = type.privacy.copyWith(
      color: EmeraldPalette.inkMuted,
      fontSize: 13,
      height: 20 / 13,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: EmeraldPalette.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: EmeraldPalette.surfaceBorder),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 6, 14),
        child: Row(
          children: [
            const ExcludeSemantics(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: EmeraldPalette.wash,
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(11),
                  child: Icon(
                    Icons.location_on_outlined,
                    size: 22,
                    color: EmeraldPalette.ink,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: MergeSemantics(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.setupSelectedLocation, style: small),
                    const SizedBox(height: 2),
                    Text(
                      place,
                      key: const Key('setupPlace'),
                      style: type.cityName.copyWith(color: EmeraldPalette.ink),
                    ),
                  ],
                ),
              ),
            ),
            Semantics(
              button: true,
              label: l.setupChangeLabel,
              excludeSemantics: true,
              onTap: onChange,
              child: TextButton(
                key: const Key('setupChange'),
                onPressed: onChange,
                style: TextButton.styleFrom(
                  foregroundColor: EmeraldPalette.ink,
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                ),
                child: Text(
                  l.setupChange,
                  style: small.copyWith(
                    color: EmeraldPalette.ink,
                    decoration: TextDecoration.underline,
                    decorationColor: EmeraldPalette.ink,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
