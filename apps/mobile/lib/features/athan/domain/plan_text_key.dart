import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// Which copy a plan entry carries (§7.7 `title`/`body`). The copy itself is
/// a product decision in the ARB files (§7.11), read through `PlanTexts`.
@immutable
sealed class PlanTextKey {
  const new();
}

/// The Athan of [event].
final class AthanText extends PlanTextKey {
  /// The Athan copy of [event].
  const new(this.event);

  /// The prayer.
  final PrayerEvent event;
}

/// The Imsak alert.
final class ImsakText extends PlanTextKey {
  /// The Imsak copy.
  const new();
}

/// The reminder [minutes] before the Athan of [event].
final class PreReminderText extends PlanTextKey {
  /// The pre-reminder copy.
  const new(this.event, this.minutes);

  /// The prayer.
  final PrayerEvent event;

  /// Minutes before the Athan.
  final int minutes;
}

/// The warning that the plan ends soon (REQ-ALM-010).
final class HorizonText extends PlanTextKey {
  /// The horizon-warning copy.
  const new();
}
