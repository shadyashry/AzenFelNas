import 'package:daily_muslim/features/passport/application/measure_sensitivity.dart';
import 'package:daily_muslim/features/passport/domain/passport_entry.dart';
import 'package:daily_muslim/features/schedule/domain/observer_of.dart';
import 'package:daily_muslim/features/schedule/domain/schedule.dart';
import 'package:geo_salah_core/geo_salah_core.dart';

/// Finds a Calculation ID in this device's schedule (§6.4 ¶11, US-05):
/// `<calcId>#<event>` resolves to that day's [PassportEntry], focused on the
/// event. `null` when no day of [Schedule] has the ID, or the event has no
/// row that day.
final class ResolveCalculationId {
  /// The use case over [_tzdb].
  const new(this._tzdb);

  final TzDatabase _tzdb;

  /// The entry of [calculationId] in [schedule], focused on [event].
  PassportEntry? call(
    Schedule schedule,
    String calculationId, {
    PrayerEvent? event,
  }) {
    final index = schedule.days.indexWhere(
      (day) => day.calculationId == calculationId,
    );
    if (index < 0) return null;
    final day = schedule.days[index];
    if (event != null && !day.times.any((time) => time.event == event)) {
      return null;
    }
    final inputs = schedule.inputs[index];
    return PassportEntry(
      day: day,
      inputs: inputs,
      zoneId: schedule.zoneId,
      profile: schedule.profile,
      sensitivityMs: MeasureSensitivity(_tzdb)(
        observer: ObserverOf.context(schedule.context),
        profile: schedule.profile,
        base: day,
        hijri: inputs.hijri,
      ),
      origin: PassportOrigin.local,
      focus: event,
    );
  }
}
