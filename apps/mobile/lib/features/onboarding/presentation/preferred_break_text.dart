import 'package:flutter/widgets.dart';

/// [text] with its line breaks kept where every line fits [width], and
/// joined into one naturally wrapping paragraph where one would not
/// (§15 D126): the reference breaks on a regular phone, no orphaned word on
/// a narrow one. Measured with the ambient direction and text scale; takes
/// the width from its parent so it needs no layout callback and can be
/// measured for intrinsic height.
final class PreferredBreakText extends StatelessWidget {
  /// The text.
  const new(
    this.text, {
    required this.style,
    required this.width,
    this.textAlign = TextAlign.start,
    super.key,
  });

  /// The copy, with `\n` at the preferred breaks.
  final String text;

  /// Its style.
  final TextStyle style;

  /// The width the text is laid out in.
  final double width;

  /// Its alignment.
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    final direction = Directionality.of(context);
    final scaler = MediaQuery.textScalerOf(context);
    bool fits(String line) {
      final painter = TextPainter(
        text: TextSpan(text: line, style: style),
        textDirection: direction,
        textScaler: scaler,
        maxLines: 1,
      )..layout(maxWidth: width);
      final fit = !painter.didExceedMaxLines;
      painter.dispose();
      return fit;
    }

    final lines = text.split('\n');
    final shown = lines.every(fits) ? text : lines.join(' ');
    return Text(shown, style: style, textAlign: textAlign);
  }
}
