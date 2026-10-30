import 'package:daily_muslim/features/shell/domain/open_system_settings.dart';
import 'package:daily_muslim/features/shell/domain/remediation.dart';
import 'package:daily_muslim/features/shell/presentation/shell_providers.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The button of a remediation that is a system setting (§10.2, §15 D97):
/// *Turn on location* opens the device's location settings, *Open
/// settings* the app's; nothing for any other remediation. [onReturn] runs
/// once when the user comes back from the screen the button opened.
final class RemediationAction extends ConsumerStatefulWidget {
  /// The action for [remediation].
  const new(
    this.remediation, {
    this.onReturn,
    this.secondary = false,
    super.key,
  });

  /// What the user can do.
  final Remediation remediation;

  /// Called once the user is back from the settings the button opened.
  final VoidCallback? onReturn;

  /// Drawn as an outlined button, beside a filled main action.
  final bool secondary;

  /// Whether [remediation] has a button.
  static bool hasAction(Remediation remediation) =>
      _action(remediation) != null;

  static Future<void> Function(OpenSystemSettings)? _action(
    Remediation remediation,
  ) => switch (remediation) {
    Remediation.turnOnLocationServices => (s) => s.location(),
    Remediation.grantLocationPermission => (s) => s.app(),
    Remediation.chooseManualPlace ||
    Remediation.waitForDataUpdate ||
    Remediation.retryWhenOnline ||
    Remediation.freeUpStorage ||
    Remediation.tryAgain ||
    Remediation.updateApp ||
    Remediation.grantAlarmPermission ||
    Remediation.openAthanHealth ||
    Remediation.checkDeviceClock => null,
  };

  @override
  ConsumerState<RemediationAction> createState() => _RemediationActionState();
}

final class _RemediationActionState extends ConsumerState<RemediationAction> {
  late final AppLifecycleListener _lifecycle;

  /// Whether the button sent the user to system settings.
  bool _awaitingReturn = false;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _resumed);
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  void _resumed() {
    if (!_awaitingReturn) return;
    _awaitingReturn = false;
    widget.onReturn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final open = RemediationAction._action(widget.remediation);
    if (open == null) return const SizedBox.shrink();
    Future<void> onPressed() async {
      _awaitingReturn = true;
      await open(ref.read(openSystemSettingsProvider));
    }

    final label = Text(switch (widget.remediation) {
      Remediation.turnOnLocationServices => l.remediationActionTurnOnLocation,
      Remediation.grantLocationPermission ||
      Remediation.chooseManualPlace ||
      Remediation.waitForDataUpdate ||
      Remediation.retryWhenOnline ||
      Remediation.freeUpStorage ||
      Remediation.tryAgain ||
      Remediation.updateApp ||
      Remediation.grantAlarmPermission ||
      Remediation.openAthanHealth ||
      Remediation.checkDeviceClock => l.remediationActionOpenSettings,
    });
    const icon = Icon(Icons.settings_outlined);
    return widget.secondary
        ? OutlinedButton.icon(onPressed: onPressed, icon: icon, label: label)
        : FilledButton.icon(onPressed: onPressed, icon: icon, label: label);
  }
}
