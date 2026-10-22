import 'package:daily_muslim/features/shell/domain/needs_attention.dart';
import 'package:daily_muslim/features/shell/presentation/needs_attention_card.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:dm_ui/dm_ui.dart';
import 'package:flutter/material.dart';

/// Shown instead of the app when the databases cannot be opened
/// (`DB_MIGRATION_FAILED`): no settings are readable, so the device language
/// and brightness apply. The files are left untouched.
final class StartupFailureApp extends StatelessWidget {
  /// The app showing [notice].
  const new(this.notice, {super.key});

  /// What failed and what to do.
  final NeedsAttention notice;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: DmTheme.of(Brightness.light, StatusLocale.en),
    darkTheme: DmTheme.of(Brightness.dark, StatusLocale.en),
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context).startupFailedTitle),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: NeedsAttentionCard(notice),
        ),
      ),
    ),
  );
}
