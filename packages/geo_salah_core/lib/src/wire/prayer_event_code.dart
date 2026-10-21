import 'package:json_annotation/json_annotation.dart';

/// Wire name of a prayer event (`IMSAK` … `ISHA`) in plans, snapshots and
/// traces.
@JsonEnum(fieldRename: FieldRename.screamingSnake)
enum PrayerEventCode {
  /// Imsak.
  imsak,

  /// Fajr.
  fajr,

  /// Sunrise.
  sunrise,

  /// Dhuhr.
  dhuhr,

  /// Asr.
  asr,

  /// Maghrib.
  maghrib,

  /// Isha.
  isha,
}
