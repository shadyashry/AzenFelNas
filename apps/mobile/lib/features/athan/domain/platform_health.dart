import 'package:daily_muslim/features/athan/domain/delivery_path.dart';
import 'package:daily_muslim/features/athan/domain/health_probe.dart';
import 'package:meta/meta.dart';

/// What the native layer reported: the path and every probe. Dart derives
/// the state itself (§15 D83), so a native bug cannot claim `ready`.
@immutable
final class PlatformHealth {
  /// The report evaluated at [evaluatedAtUtcMs].
  const new({
    required this.path,
    required this.probes,
    required this.evaluatedAtUtcMs,
  });

  /// No native layer answered: nothing is known.
  factory unavailable(int evaluatedAtUtcMs) => PlatformHealth(
    path: DeliveryPath.unavailable,
    probes: const [],
    evaluatedAtUtcMs: evaluatedAtUtcMs,
  );

  /// The delivery path.
  final DeliveryPath path;

  /// Probes in native order.
  final List<HealthProbe> probes;

  /// UTC epoch ms of the evaluation.
  final int evaluatedAtUtcMs;
}
