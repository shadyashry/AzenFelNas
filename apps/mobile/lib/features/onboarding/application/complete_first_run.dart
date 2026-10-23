import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';

/// Ends onboarding (§7.2 `CompleteFirstRun`): from now on the app opens on
/// Home. The context itself was stored when it was chosen; the active one
/// stays the stored context used last (§15 D73), so `activeContextId` is not
/// written (§15 D77).
final class CompleteFirstRun {
  /// Writes through [_write].
  const new(this._write);

  final WriteSetting _write;

  /// Marks onboarding complete.
  Future<void> call() => _write.write(AppSettings.onboardingComplete, true);
}
