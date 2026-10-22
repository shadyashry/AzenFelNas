import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// A routed screen whose slice is still to come: its title and a note,
/// nothing invented (§0.2: `Unknown` beats an invented value).
final class PlaceholderPage extends StatelessWidget {
  /// The page titled [title], with [actions] in the app bar.
  const new({required this.title, this.actions = const [], super.key});

  /// The screen title.
  final String title;

  /// App bar actions.
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title), actions: actions),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          AppLocalizations.of(context).notYetAvailable,
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}
