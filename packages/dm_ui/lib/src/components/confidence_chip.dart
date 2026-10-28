import 'package:dm_ui/src/copy/digit_style.dart';
import 'package:dm_ui/src/copy/status_copy.dart';
import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// A time's confidence (§7.9, REQ-UX-040): a sealed [ConfidenceLabel] in,
/// copy from `StatusCopy` only, and an icon per variant so the status never
/// depends on colour alone (REQ-UX-020).
///
/// Set quietly (§15 D89): a small icon and label in the secondary ink of
/// the surface, no box, so six rows of "Calculated" read as one calm
/// column instead of six badges.
final class ConfidenceChip extends StatelessWidget {
  /// Creates a chip.
  const new({
    required this.label,
    required this.locale,
    this.digits = DigitStyle.western,
    super.key,
  });

  /// The label shown.
  final ConfidenceLabel label;

  /// Copy locale.
  final StatusLocale locale;

  /// Numeral style.
  final DigitStyle digits;

  /// The non-colour cue of [label].
  static IconData iconOf(ConfidenceLabel label) => switch (label) {
    Calculated() => Icons.calculate_outlined,
    AuthorityAligned() => Icons.account_balance_outlined,
    Verified() => Icons.verified_outlined,
    Estimated() => Icons.straighten,
    Observed() => Icons.groups_outlined,
    Unknown() => Icons.help_outline,
  };

  @override
  Widget build(BuildContext context) {
    final text = StatusCopy.chip(label, locale, digits: digits);
    final style = Theme.of(context).textTheme.labelMedium;
    final color = style?.color ?? Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: text,
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconOf(label), size: DmScales.label.size - 1, color: color),
          SizedBox(width: DmScales.space[0]),
          Flexible(child: Text(text, style: style)),
        ],
      ),
    );
  }
}
