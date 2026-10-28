import 'package:dm_ui/src/rawdah/ornament_paths.dart';
import 'package:dm_ui/src/theme/dm_theme.dart';
import 'package:dm_ui/src/tokens/rawdah_palette.dart';
import 'package:flutter/material.dart';

/// A group of related rows on a content page (§15 D89): an Amiri heading
/// led by a small gold star, then one pearl panel with a gilded hairline
/// edge whose rows are parted by gold hairlines. No nested cards: the
/// panel is the only container.
final class RawdahSection extends StatelessWidget {
  /// The rows of [children] under [title]; no heading when it is `null`.
  const new({
    required this.children,
    this.title,
    this.footnote,
    this.padding = const EdgeInsets.fromLTRB(16, 18, 16, 0),
    super.key,
  });

  /// The heading.
  final String? title;

  /// The rows, parted by hairlines.
  final List<Widget> children;

  /// A quiet line under the panel.
  final String? footnote;

  /// Space around the section.
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final light = theme.brightness == Brightness.light;
    final heading = title;
    final note = footnote;
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (heading != null)
            Padding(
              padding: const EdgeInsetsDirectional.only(start: 6, bottom: 8),
              child: Row(
                children: [
                  const _Star(),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Semantics(
                      header: true,
                      child: Text(
                        heading,
                        style: DmTheme.naskh(
                          size: 20,
                          color: theme.colorScheme.primary,
                          bold: true,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // A Material surface, so rows keep their ink ripples.
          Material(
            color: light ? const Color(0xFFFFFEFA) : theme.colorScheme.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: RawdahPalette.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  if (i > 0)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                  children[i],
                ],
              ],
            ),
          ),
          if (note != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 8, 0),
              child: Text(note, style: theme.textTheme.labelMedium),
            ),
        ],
      ),
    );
  }
}

final class _Star extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) => const ExcludeSemantics(
    child: SizedBox.square(
      dimension: 12,
      child: CustomPaint(painter: _StarPainter()),
    ),
  );
}

final class _StarPainter extends CustomPainter {
  const new();

  @override
  void paint(Canvas canvas, Size size) => canvas.drawPath(
    OrnamentPaths.star(size.center(Offset.zero), size.width / 2),
    Paint()..color = RawdahPalette.gold,
  );

  @override
  bool shouldRepaint(_StarPainter old) => false;
}
