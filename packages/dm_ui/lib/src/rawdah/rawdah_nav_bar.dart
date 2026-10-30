import 'package:dm_ui/src/rawdah/athan_ring.dart';
import 'package:dm_ui/src/rawdah/rawdah_glyph.dart';
import 'package:dm_ui/src/rawdah/rawdah_glyph_kind.dart';
import 'package:dm_ui/src/rawdah/rawdah_tab.dart';
import 'package:dm_ui/src/rawdah/rawdah_tab_labels.dart';
import 'package:dm_ui/src/tokens/dm_elevation.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/hour_light.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/material.dart';

/// The deep-green navigation bar (§15 D89, D102), docked at the bottom with
/// rounded upper corners: a mihrab for Home, an eight-point star compass
/// whose needle points at the real Qibla, a minaret with the Athan ring, a
/// rosette for Settings. The current tab is gold, bold, and sits on a soft
/// gold pill tinted with the hour's [light], so the selection never rests
/// on colour alone. The bar's own colour runs under the system navigation
/// bar; its destinations stay above it.
///
/// Every destination is a button of at least 48 dp with its label and
/// selected state in semantics (REQ-UX-020); the order follows the text
/// direction (REQ-UX-030).
final class RawdahNavBar extends StatelessWidget {
  /// The bar with [current] selected.
  const new({
    required this.current,
    required this.labels,
    required this.onSelect,
    required this.light,
    this.qiblaBearingDeg,
    this.athanRing = AthanRing.unknown,
    super.key,
  });

  /// The selected destination.
  final RawdahTab current;

  /// Localised labels.
  final RawdahTabLabels labels;

  /// Called with the tapped destination.
  final ValueChanged<RawdahTab> onSelect;

  /// The hour light tinting the selected pill.
  final HourLight light;

  /// The Qibla bearing from true north, degrees; `null` (no place yet)
  /// draws the star without a needle.
  final double? qiblaBearingDeg;

  /// The Athan ring.
  final AthanRing athanRing;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: const BoxDecoration(
      color: RawdahPalette.emeraldDeep,
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(DmScales.radiusSheet),
      ),
      boxShadow: DmElevation.bar,
    ),
    child: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final tab in RawdahTab.values)
              Expanded(
                child: _Destination(
                  tab: tab,
                  label: labels.of(tab),
                  selected: tab == current,
                  light: light,
                  qiblaBearingDeg: qiblaBearingDeg,
                  athanRing: athanRing,
                  onTap: () => onSelect(tab),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

final class _Destination extends StatelessWidget {
  const new({
    required this.tab,
    required this.label,
    required this.selected,
    required this.light,
    required this.qiblaBearingDeg,
    required this.athanRing,
    required this.onTap,
  });

  final RawdahTab tab;
  final String label;
  final bool selected;
  final HourLight light;
  final double? qiblaBearingDeg;
  final AthanRing athanRing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? RawdahPalette.goldLight : RawdahPalette.ivoryMuted;
    final pill = Color.alphaBlend(
      light.glow.withValues(alpha: 0.08),
      RawdahPalette.gold.withValues(alpha: 0.18),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: InkResponse(
        onTap: onTap,
        radius: 32,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 56, minWidth: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? DmScales.motionReduced
                      : DmScales.motionStandard,
                  width: 56,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selected ? pill : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: selected
                          ? RawdahPalette.gold.withValues(alpha: 0.6)
                          : Colors.transparent,
                      width: 0.8,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: RawdahGlyph(
                    kind: switch (tab) {
                      RawdahTab.home => RawdahGlyphKind.mihrab,
                      RawdahTab.quran => RawdahGlyphKind.mushaf,
                      RawdahTab.qibla => RawdahGlyphKind.starCompass,
                      RawdahTab.athan => RawdahGlyphKind.minaret,
                      RawdahTab.settings => RawdahGlyphKind.rosette,
                    },
                    color: color,
                    size: DmScales.iconLarge,
                    qiblaBearingDeg: qiblaBearingDeg,
                    athanRing: athanRing,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: color,
                    fontSize: DmScales.label.size - 1,
                    height: 1.2,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
