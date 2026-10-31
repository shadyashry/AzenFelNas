import 'package:daily_muslim/features/radio/presentation/radio_arch.dart';
import 'package:daily_muslim/features/radio/presentation/radio_tokens.dart';
import 'package:daily_muslim/features/radio/presentation/radio_type.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The Radio header (§15 D122): a quiet green gradient under the status
/// bar with the overline, title and tagline, and a small gold arch
/// opposite them (mirrored in Arabic by the text direction). [compact]
/// (short landscape windows) keeps the title and drops the decoration.
final class RadioHeader extends StatelessWidget {
  /// The header.
  const new({this.compact = false, super.key});

  /// The short form.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = RadioTokens.of(context);
    final type = RadioType.of(context);
    final reverse = Directionality.of(context) == TextDirection.rtl;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: reverse ? Alignment.centerRight : Alignment.centerLeft,
          end: reverse ? Alignment.bottomLeft : Alignment.bottomRight,
          colors: [t.header, t.header, t.headerDeep],
          stops: const [0, 0.55, 1],
        ),
        border: Border(
          bottom: BorderSide(color: t.gold.withValues(alpha: 0.55)),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: compact
              ? const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 10)
              : const EdgeInsetsDirectional.fromSTEB(20, 22, 20, 24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!compact) ...[
                      Text(
                        l.radioOverline,
                        style: type.overline.copyWith(color: t.gold),
                      ),
                      const SizedBox(height: 6),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        l.radioTitle,
                        style: (compact ? type.compactHeading : type.heading)
                            .copyWith(color: RadioMiniTokens.text),
                      ),
                    ),
                    if (!compact) ...[
                      const SizedBox(height: 6),
                      Text(
                        l.radioTagline,
                        style: type.tagline.copyWith(
                          color: RadioMiniTokens.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!compact) ...[
                const SizedBox(width: 16),
                RadioArch(
                  width: 52,
                  height: 62,
                  border: BorderSide(color: t.gold, width: 1.2),
                  child: RawdahGlyph(
                    kind: RawdahGlyphKind.radio,
                    color: t.gold,
                    size: 22,
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
