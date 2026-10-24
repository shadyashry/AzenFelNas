import 'package:daily_muslim/features/athan/application/evaluate_athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_platform_ports.dart';
import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/read_last_test_heard.dart';
import 'package:daily_muslim/features/contexts/domain/context_kind.dart';
import 'package:daily_muslim/features/contexts/domain/location_context.dart';
import 'package:daily_muslim/features/contexts/domain/location_ports.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// Assembles the redacted diagnostic bundle of §7.2 (REQ-PRIV-005, §15 D84)
/// for the user to read before exporting it. Coordinates leave this class
/// only as whole hundredths of a degree; the context label, accuracy and
/// package hashes are left out, and no member holds an identifier
/// (REQ-PRIV-001).
final class AssembleDiagnosticBundle {
  /// The use case over its sources; `os` and `appVersion` describe this
  /// build.
  const new({
    required this._events,
    required this._platformHealth,
    required this._lastTestHeard,
    required this._contexts,
    required this._activePackages,
    required this._clock,
    required this._os,
    required this._appVersion,
    this._evaluate = const EvaluateAthanHealth(),
  });

  final Future<List<EventLogEntry>> Function() _events;
  final ReadPlatformHealth _platformHealth;
  final ReadLastTestHeard _lastTestHeard;
  final ReadLocationContexts _contexts;
  final Future<List<ActivePackage>> Function() _activePackages;
  final Clock _clock;
  final DiagnosticOs _os;
  final String _appVersion;
  final EvaluateAthanHealth _evaluate;

  /// The bundle as of now.
  Future<DiagnosticBundle> call() async {
    final report = await _platformHealth();
    final health = _evaluate(report, lastTestHeard: await _lastTestHeard());
    final active = switch (await _contexts.active()) {
      Ok(:final value) => value,
      Err() => null,
    };
    return DiagnosticBundle(
      schemaVersion: DiagnosticBundle.currentSchemaVersion,
      createdUtcMs: _clock.nowUtcMs(),
      files: DiagnosticFiles(
        events: await _events(),
        health: DiagnosticHealth(
          path: _path(report.path),
          state: _state(health),
          reasons: [for (final r in health.reasons) r.name],
          probes: [
            for (final p in report.probes)
              DiagnosticProbe(name: p.name, positive: p.positive),
          ],
          evaluatedAtUtcMs: report.evaluatedAtUtcMs,
        ),
        // No slice applies a plan from Dart yet (§15 D83, D84).
        plan: const DiagnosticPlan(status: DiagnosticPlanStatus.notApplied),
        packages: [
          for (final p in await _activePackages())
            DiagnosticPackage(
              type: p.type.wire,
              version: p.version,
              sequence: p.sequence,
            ),
        ],
        device: DiagnosticDevice(model: null, os: _os, appVersion: _appVersion),
        context: active == null ? null : _context(active),
      ),
    );
  }

  /// [e6] (millionths of a degree) rounded half away from zero to
  /// hundredths of a degree (REQ-PRIV-005).
  static int toE2(int e6) => (e6.abs() + 5000) ~/ 10000 * e6.sign;

  static DiagnosticContext _context(LocationContext c) => DiagnosticContext(
    kind: switch (c.kind) {
      ContextKind.current => DiagnosticContextKind.current,
      ContextKind.pinned => DiagnosticContextKind.pinned,
      ContextKind.manual => DiagnosticContextKind.manual,
    },
    source: c.source.wire,
    latE2: toE2(c.place.point.latE6),
    lonE2: toE2(c.place.point.lonE6),
    zoneId: c.place.zoneId,
    countryCode: c.place.country,
  );

  static DiagnosticDeliveryPath _path(DeliveryPath path) => switch (path) {
    DeliveryPath.androidExact => DiagnosticDeliveryPath.androidExact,
    DeliveryPath.androidInexact => DiagnosticDeliveryPath.androidInexact,
    DeliveryPath.iosAlarmKit => DiagnosticDeliveryPath.iosAlarmKit,
    DeliveryPath.iosNotification => DiagnosticDeliveryPath.iosNotification,
    DeliveryPath.unavailable => DiagnosticDeliveryPath.unavailable,
  };

  static DiagnosticHealthState _state(AthanHealth health) => switch (health) {
    AthanHealthReady() => DiagnosticHealthState.ready,
    AthanHealthLimited() => DiagnosticHealthState.limited,
    AthanHealthNotReady() => DiagnosticHealthState.notReady,
    AthanHealthUnknown() => DiagnosticHealthState.unknown,
  };
}
