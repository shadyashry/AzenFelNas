import 'package:meta/meta.dart';

/// Where a trusted time sample came from (§7.6).
enum TimeSource {
  /// The time of a GNSS location fix.
  gnssFix,

  /// The `Date` header of a CDN response.
  cdnDate,
}

/// One trusted time sample and the device clock reading taken with it.
@immutable
final class TimeReference {
  /// [referenceUtcMs] from [source], seen when the device clock read
  /// [deviceUtcMs].
  const new({
    required this.source,
    required this.referenceUtcMs,
    required this.deviceUtcMs,
  });

  /// Where the sample came from.
  final TimeSource source;

  /// The trusted time (UTC epoch ms).
  final int referenceUtcMs;

  /// The device clock at the same moment (UTC epoch ms).
  final int deviceUtcMs;

  /// Device minus reference; positive when the device clock runs ahead.
  int get skewMs => deviceUtcMs - referenceUtcMs;

  @override
  bool operator ==(Object other) =>
      other is TimeReference &&
      other.source == source &&
      other.referenceUtcMs == referenceUtcMs &&
      other.deviceUtcMs == deviceUtcMs;

  @override
  int get hashCode => Object.hash(source, referenceUtcMs, deviceUtcMs);

  @override
  String toString() => 'TimeReference(${source.name}, skew: $skewMs ms)';
}
