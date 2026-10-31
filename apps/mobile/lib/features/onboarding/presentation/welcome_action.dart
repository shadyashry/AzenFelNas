import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// The look of a [WelcomeAction].
enum WelcomeActionKind {
  /// Filled emerald with ivory text.
  primary,

  /// Ivory with a thin warm border and emerald text.
  secondary,
}

/// A welcome or city-picker action (§15 D126): at least 54 units tall,
/// 17-unit corners, the [icon] and label centred together and [trailing]
/// at the end edge. Arrows and chevrons mirror in Arabic; other icons do
/// not. Pressed and focused states come from the button; [loading] shows
/// progress in place of [icon] and blocks presses; a `null` [onPressed]
/// is disabled.
final class WelcomeAction extends StatelessWidget {
  /// The action.
  const new({
    required this.kind,
    required this.label,
    required this.onPressed,
    required this.textStyle,
    this.icon,
    this.trailing,
    this.loading = false,
    this.loadingLabel,
    super.key,
  });

  /// Its look.
  final WelcomeActionKind kind;

  /// Its label.
  final String label;

  /// Called on a press; `null` disables the action.
  final VoidCallback? onPressed;

  /// The label's style; the colour comes from [kind].
  final TextStyle textStyle;

  /// The leading icon.
  final IconData? icon;

  /// The trailing arrow or chevron.
  final IconData? trailing;

  /// Work is running: progress shows and presses are ignored.
  final bool loading;

  /// What a screen reader says of the progress while [loading].
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, border) = switch (kind) {
      WelcomeActionKind.primary => (
        EmeraldPalette.action,
        EmeraldPalette.onAction,
        BorderSide.none,
      ),
      WelcomeActionKind.secondary => (
        EmeraldPalette.surface,
        EmeraldPalette.ink,
        const BorderSide(color: EmeraldPalette.surfaceBorder),
      ),
    };
    // Loading keeps the full colour; only a disabled action fades.
    final faded = onPressed == null && !loading;
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(64, 54)),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(17),
          side: border,
        ),
      ),
      backgroundColor: WidgetStatePropertyAll(
        faded ? background.withValues(alpha: 0.55) : background,
      ),
      foregroundColor: WidgetStatePropertyAll(
        faded ? foreground.withValues(alpha: 0.7) : foreground,
      ),
      overlayColor: WidgetStateProperty.resolveWith(
        (states) => states.contains(WidgetState.pressed)
            ? foreground.withValues(alpha: 0.12)
            : states.contains(WidgetState.focused) ||
                  states.contains(WidgetState.hovered)
            ? foreground.withValues(alpha: 0.08)
            : null,
      ),
      elevation: const WidgetStatePropertyAll(0),
      textStyle: WidgetStatePropertyAll(textStyle),
    );
    return TextButton(
      onPressed: loading ? null : onPressed,
      style: style,
      child: _Content(
        label: label,
        icon: icon,
        trailing: trailing,
        loading: loading,
        loadingLabel: loadingLabel,
        color: faded ? foreground.withValues(alpha: 0.7) : foreground,
      ),
    );
  }
}

final class _Content extends StatelessWidget {
  const new({
    required this.label,
    required this.icon,
    required this.trailing,
    required this.loading,
    required this.loadingLabel,
    required this.color,
  });

  final String label;
  final IconData? icon;
  final IconData? trailing;
  final bool loading;
  final String? loadingLabel;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final lead = switch ((loading, icon)) {
      (true, _) => SizedBox.square(
        dimension: 18,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: color,
          semanticsLabel: loadingLabel,
        ),
      ),
      (false, final IconData mark) => Icon(mark, size: 20, color: color),
      (false, null) => null,
    };
    return Row(
      children: [
        // Balances the trailing mark, so the label sits in the middle.
        const SizedBox(width: 22),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (lead case final Widget mark) ...[
                mark,
                const SizedBox(width: 12),
              ],
              Flexible(child: Text(label, textAlign: TextAlign.center)),
            ],
          ),
        ),
        SizedBox(
          width: 22,
          child: trailing == null
              ? null
              : Icon(trailing, size: 20, color: color),
        ),
      ],
    );
  }
}
