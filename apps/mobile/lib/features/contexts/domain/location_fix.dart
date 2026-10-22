import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:meta/meta.dart';

/// One device location fix, as a platform adapter reports it.
@immutable
final class LocationFix {
  /// A fix at [point] taken at [fixUtcMs].
  const new({
    required this.point,
    required this.horizontalAccuracyM,
    required this.fixUtcMs,
    required this.isMock,
  });

  /// Location in micro-degrees.
  final GeoPointE6 point;

  /// Horizontal accuracy in metres.
  final double horizontalAccuracyM;

  /// When the platform says the fix was taken (UTC epoch ms).
  final int fixUtcMs;

  /// Whether the platform marks the fix as mock (`isMock`,
  /// `isSimulatedBySoftware`): recorded in diagnostics only (§7.5).
  final bool isMock;

  @override
  bool operator ==(Object other) =>
      other is LocationFix &&
      other.point == point &&
      other.horizontalAccuracyM == horizontalAccuracyM &&
      other.fixUtcMs == fixUtcMs &&
      other.isMock == isMock;

  @override
  int get hashCode => Object.hash(point, horizontalAccuracyM, fixUtcMs, isMock);

  /// No coordinates (REQ-PRIV-001).
  @override
  String toString() =>
      'LocationFix(±${horizontalAccuracyM.round()} m, $fixUtcMs, '
      'mock: $isMock)';
}
