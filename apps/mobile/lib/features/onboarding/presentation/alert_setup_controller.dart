import 'package:daily_muslim/features/athan/domain/athan_grant.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/presentation/athan_providers.dart';
import 'package:daily_muslim/features/onboarding/application/classify_alerts.dart';
import 'package:daily_muslim/features/onboarding/domain/alert_status.dart';
import 'package:daily_muslim/features/onboarding/presentation/alert_setup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Drives [AlertSetup] (§15 D127): asks for the grants an explicit tap
/// names, one system prompt or settings screen at a time, then reads Athan
/// Health again, so the screen shows what the phone reports, never what was
/// tapped. A tap while one is open is ignored.
final class AlertSetupController extends Notifier<AlertSetup> {
  @override
  AlertSetup build() => const AlertSetup();

  /// *Set up prayer alerts*: asks for each of [grants] in turn.
  Future<void> setUp(List<AthanGrant> grants) => _ask(grants, markAsked: true);

  /// *Review alert settings*: opens [grant]'s prompt or settings screen.
  Future<void> review(AthanGrant grant) => _ask([grant], markAsked: false);

  Future<void> _ask(
    List<AthanGrant> grants, {
    required bool markAsked,
  }) async {
    if (state.busy) return;
    state = AlertSetup(asked: state.asked, busy: true);
    final request = ref.read(requestAthanGrantProvider);
    for (final grant in grants) {
      await request(grant);
    }
    if (!ref.mounted) return;
    state = AlertSetup(asked: state.asked || markAsked);
    ref.invalidate(athanHealthProvider);
  }
}

/// The first run's alert setup.
final NotifierProvider<AlertSetupController, AlertSetup> alertSetupProvider =
    NotifierProvider<AlertSetupController, AlertSetup>(
      AlertSetupController.new,
    );

/// Where alerts stand: Athan Health classified (§15 D127). A health read
/// that fails is unknown, never ready; a refresh keeps the last reading.
final Provider<AlertStatus> alertStatusProvider = Provider<AlertStatus>((ref) {
  final health = switch (ref.watch(athanHealthProvider)) {
    AsyncError() => const AthanHealthUnknown(),
    final AsyncValue<AthanHealth> value => value.value,
  };
  return const ClassifyAlerts()(
    health,
    asked: ref.watch(alertSetupProvider).asked,
  );
});
