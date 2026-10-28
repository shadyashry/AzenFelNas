import 'package:dm_ui/src/components/confidence_chip.dart';
import 'package:dm_ui/src/copy/digit_style.dart';
import 'package:dm_ui/src/copy/status_copy.dart';
import 'package:dm_ui/src/copy/status_locale.dart';
import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/theme/dm_theme.dart';
import 'package:dm_ui/src/tokens/dm_scales.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/material.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// One prayer time on a content surface (§7.9, §15 D89): the event's light
/// swatch and its name in Amiri at the start, the time at the end, and its
/// quiet [ConfidenceChip] beside the name (REQ-UX-001). One semantics node
/// reads "event, time, confidence" (REQ-UX-020); the row is at least 48 dp
/// tall and wraps instead of overflowing at 200 % text. A gold hairline
/// closes it; [highlight] washes the next prayer in the hour's light.
final class TimeRow extends StatelessWidget {
  /// Creates a row.
  const new({
    required this.eventName,
    required this.timeText,
    required this.label,
    required this.locale,
    this.digits = DigitStyle.western,
    this.onTap,
    this.swatch,
    this.highlight,
    this.minor = false,
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

  /// The event's own light, drawn as a diamond before the name.
  final Color? swatch;

  /// The wash of the next prayer's row; `null` for the others.
  final Color? highlight;

  /// Sunrise and Imsak: set one step smaller, in secondary ink.
  final bool minor;

  @override
  Widget build(BuildContext context) {
    final chipText = StatusCopy.chip(label, locale, digits: digits);
    final next = highlight != null;
    final theme = Theme.of(context);
    final ink = theme.colorScheme.onSurface;
    final naskh = DmTheme.naskh(
      size: minor ? 18 : 21,
      color: next
          ? theme.colorScheme.primary
          : (minor ? (theme.textTheme.labelMedium?.color ?? ink) : ink),
      bold: next,
    );
    return Semantics(
      label: '$eventName, ${digits.apply(timeText)}, $chipText',
      button: onTap != null,
      onTap: onTap,
      container: true,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: switch (highlight) {
              final Color wash => LinearGradient(
                colors: [
                  wash.withValues(alpha: 0),
                  wash,
                  wash,
                  wash.withValues(alpha: 0),
                ],
                stops: const [0, 0.18, 0.82, 1],
              ),
              null => null,
            },
            border: const Border(
              bottom: BorderSide(color: RawdahPalette.hairline, width: 0.8),
            ),
          ),
          child: ConstrainedBox(
            // 48 dp: Android's tap target, above the 44 pt floor.
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Padding(
              padding: EdgeInsetsDirectional.symmetric(
                horizontal: DmScales.space[2],
                vertical: DmScales.space[0],
              ),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: DmScales.space[1],
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: DmScales.space[2],
                    children: [
                      if (swatch case final Color color) _Swatch(color),
                      Text(eventName, style: naskh),
                      ConfidenceChip(
                        label: label,
                        locale: locale,
                        digits: digits,
                      ),
                    ],
                  ),
                  Text(digits.apply(timeText), style: naskh),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

final class _Swatch extends StatelessWidget {
  const new(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: const Size.square(11),
    painter: _SwatchPainter(color),
  );
}

final class _SwatchPainter extends CustomPainter {
  const new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = OrnamentPaths.diamond(size.center(Offset.zero), 5);
    canvas
      ..drawPath(path, Paint()..color = color)
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = RawdahPalette.goldDeep.withValues(alpha: 0.5),
      );
  }

  @override
  bool shouldRepaint(_SwatchPainter old) => old.color != color;
}
