import 'package:dm_ui/src/components/confidence_chip.dart';
import 'package:dm_ui/src/copy/digit_style.dart';
import 'package:dm_ui/src/copy/status_copy.dart';
import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// One prayer time on a content surface (§7.9): event name at the start,
/// time at the end, its [ConfidenceChip] below (REQ-UX-001). One semantics
/// node reads "event, time, confidence" (REQ-UX-020); the row is at least
/// 44 pt tall and wraps instead of overflowing at 200 % text.
final class TimeRow extends StatelessWidget {
  /// Creates a row.
  const new({
    required this.eventName,
    required this.timeText,
    required this.label,
    required this.locale,
    this.digits = DigitStyle.western,
    this.onTap,
    super.key,
  });

  /// Localised event name.
  final String eventName;

  /// Localised, formatted displayed time.
  final String timeText;

  /// The time's confidence.
  final ConfidenceLabel label;

  /// Copy locale.
  final StatusLocale locale;

  /// Numeral style.
  final DigitStyle digits;

  /// Opens the Passport entry (US-05); `null` for a read-only row.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final chipText = StatusCopy.chip(label, locale, digits: digits);
    return Semantics(
      label: '$eventName, ${digits.apply(timeText)}, $chipText',
      button: onTap != null,
      onTap: onTap,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: DmScales.minTarget),
          child: Padding(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: DmScales.space[3],
              vertical: DmScales.space[1],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  spacing: DmScales.space[1],
                  children: [
                    Text(eventName, style: text.titleLarge),
                    Text(digits.apply(timeText), style: text.titleLarge),
                  ],
                ),
                SizedBox(height: DmScales.space[0]),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: ConfidenceChip(
                    label: label,
                    locale: locale,
                    digits: digits,
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
