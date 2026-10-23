import 'package:daily_muslim/features/athan/application/probe_rules.dart';
import 'package:daily_muslim/features/athan/domain/athan_health.dart';
import 'package:daily_muslim/features/athan/domain/athan_health_reason.dart';
import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/platform_health.dart';
import 'package:daily_muslim/features/athan/domain/probe_rule.dart';

/// The Athan Health state machine of §8.3 in Dart (S23, §15 D83).
///
/// Order (D81): a blocking `false` ⇒ `notReady`; else a degrading `false` ⇒
/// `limited`; else any blocking, degrading or unrecognised `null` ⇒
/// `unknown`; else `ready` (REQ-ALM-003). No probes ⇒ `unknown`. The iOS
/// notification path is never `ready` (REQ-ALM-033), the Android inexact
/// path is at most `limited` (REQ-ALM-027), and a Test the user did not hear
/// degrades to `limited(failedTest)`.
final class EvaluateAthanHealth {
  /// The evaluator over [_rules].
  const new([this._rules = const ProbeRules()]);

  final ProbeRules _rules;

  /// Health of [report], given the answer to the latest Test, if any.
  AthanHealth call(PlatformHealth report, {bool? lastTestHeard}) {
    final blocking = <AthanHealthReason>[];
    final degrading = <AthanHealthReason>[];
    final advisory = <AthanHealthReason>[];
    var degraded = false;
    var unknown = report.probes.isEmpty;
    for (final probe in report.probes) {
      final positive = probe.positive;
      switch (_rules.of(report.path, probe.name)) {
        case BlockingProbe(:final reason):
          if (positive == null) unknown = true;
          if (positive == false) blocking.add(reason);
        case DegradingProbe(:final reason):
          if (positive == null) unknown = true;
          if (positive == false) {
            degraded = true;
            if (reason != null) degrading.add(reason);
          }
        case AdvisoryProbe(:final reason):
          if (positive == false) advisory.add(reason);
        case InformationalProbe():
          break;
        case UnrecognisedProbe():
          if (positive != true) unknown = true;
      }
    }
    final pathReason = switch (report.path) {
      DeliveryPath.iosNotification => AthanHealthReason.unverifiableDelivery,
      DeliveryPath.androidInexact => AthanHealthReason.inexactFallback,
      DeliveryPath.androidExact ||
      DeliveryPath.iosAlarmKit ||
      DeliveryPath.unavailable => null,
    };
    if (pathReason != null) {
      degraded = true;
      degrading.add(pathReason);
    }
    if (lastTestHeard == false) {
      degraded = true;
      degrading.add(AthanHealthReason.failedTest);
    }
    if (blocking.isNotEmpty) {
      return AthanHealthNotReady(_distinct([...blocking, ...degrading, ...advisory]));
    }
    if (degraded) {
      return AthanHealthLimited(_distinct([...degrading, ...advisory]));
    }
    if (unknown) return AthanHealthUnknown(_distinct(advisory));
    return AthanHealthReady(_distinct(advisory));
  }

  static List<AthanHealthReason> _distinct(List<AthanHealthReason> reasons) =>
      List.unmodifiable(reasons.toSet());
}
