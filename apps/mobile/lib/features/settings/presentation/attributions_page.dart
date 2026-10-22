import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Data sources and licences (§10.4): every bundled dataset's notice, and the
/// software licences collected by Flutter's `LicenseRegistry`.
final class AttributionsPage extends ConsumerWidget {
  /// The page.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final sources = ref.watch(attributionsProvider).value ?? const [];
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAttributions)),
      body: ListView(
        children: [
          for (final a in sources)
            ListTile(
              title: Text(a.name),
              subtitle: Text('${a.notice}\n${a.licence}'),
              isThreeLine: true,
            ),
          ListTile(
            title: Text(l.attributionsOpenSource),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: l.appTitle,
            ),
          ),
        ],
      ),
    );
  }
}
