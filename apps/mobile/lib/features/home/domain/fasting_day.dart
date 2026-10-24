import 'package:daily_muslim/features/home/domain/time_row_view.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Home's Ramadan card (US-23, REQ-RAM-001): the fasting window of the day
/// it concerns, or nothing outside Ramadan.
sealed class FastingDay {
  const new();
}

/// The day is not in Ramadan: Home shows no card.
final class NotFasting extends FastingDay {
  /// The state.
  const new();
}

/// A Ramadan day whose Fajr or Maghrib has no time here (polar day or night):
/// the card says so rather than invent a window (§0.2 rule 9).
final class FastingUnknown extends FastingDay {
  /// The state for [ramadan].
  const new(this.ramadan);

  /// Which Ramadan day and how sure the date is.
  final RamadanDate ramadan;
}

/// The fasting window of a Ramadan day: from [begins] (Fajr) to [ends]
/// (Maghrib), both the profile's own times, with [imsak] when the profile
/// defines it.
final class FastingWindow extends FastingDay {
  /// The window of [ramadan].
  const new({
    required this.ramadan,
    required this.begins,
    required this.ends,
    required this.imsak,
  });

  /// Which Ramadan day and how sure the date is.
  final RamadanDate ramadan;

  /// Fajr of the day.
  final TimeRowView begins;

  /// Maghrib of the day.
  final TimeRowView ends;

  /// Imsak of the day; null when the profile has none.
  final TimeRowView? imsak;
}

/// The Ramadan day number of a fasting day and how its Hijri date is known.
@immutable
final class RamadanDate {
  /// Day [day] of Ramadan, known with [confidence].
  const new({required this.day, required this.confidence});

  /// 1–30.
  final int day;

  /// Confirmed, expected (tabular, not announced) or the user's ±1 override.
  final HijriConfidence confidence;

  @override
  bool operator ==(Object other) =>
      other is RamadanDate &&
      other.day == day &&
      other.confidence == confidence;

  @override
  int get hashCode => Object.hash(day, confidence);
}
