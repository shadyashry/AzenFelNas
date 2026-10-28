import 'package:flutter/material.dart';

/// A settings row choosing one of [choices], each shown by [label].
final class ChoiceTile<T extends Object> extends StatelessWidget {
  /// The row titled [title] showing [value].
  const new({
    required this.title,
    required this.value,
    required this.choices,
    required this.label,
    required this.onChanged,
    super.key,
  });

  /// The row title.
  final String title;

  /// The current choice, or `null` while loading.
  final T? value;

  /// Every choice, in order.
  final List<T> choices;

  /// The text of a choice.
  final String Function(T choice) label;

  /// Called with the new choice.
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => ListTile(
    title: Text(title, style: Theme.of(context).textTheme.labelMedium),
    // The current choice reads as the row's value, in the primary ink; the
    // panel's hairlines replace the dropdown's underline (§15 D89).
    subtitle: DropdownButton<T>(
      isExpanded: true,
      underline: const SizedBox.shrink(),
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      iconEnabledColor: Theme.of(context).colorScheme.secondary,
      value: value,
      items: [
        for (final c in choices)
          DropdownMenuItem(value: c, child: Text(label(c))),
      ],
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    ),
  );
}
