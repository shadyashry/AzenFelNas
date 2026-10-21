import 'package:geo_salah_core/src/model/confidence_label.dart';
import 'package:geo_salah_core/src/model/event_origin.dart';
import 'package:geo_salah_core/src/model/no_event_reason.dart';
import 'package:geo_salah_core/src/model/prayer_event.dart';
import 'package:geo_salah_core/src/model/result_flag.dart';
import 'package:meta/meta.dart';

/// One event of a prayer day (§6.2).
///
/// Invariant (§15 D19, D21): [rawUtcMs], [displayedUtcMs] and [dayOffset]
/// are absent exactly when [origin] is [NoEvent] — a missing event has no
/// instant at all, never an invented one (REQ-DOM-002, §0.2 rule 10).
/// [rawUtcMs] is the rule's instant truncated to 1 ms (REQ-DOM-004);
/// [displayedUtcMs] is it after the adjustments and rounding (REQ-DOM-003).
/// Immutable value type.
@immutable
final class PrayerTime {
  /// A time with an instant, from [origin] `primary` or `fallback`.
  ///
  /// [dayOffset] is the local date of [displayedUtcMs] minus the prayer day,
  /// −1…1. Throws [ArgumentError] when [origin] is [NoEvent] or [dayOffset]
  /// is out of range.
  factory timed({
    required PrayerEvent event,
    required int rawUtcMs,
    required int displayedUtcMs,
    required int dayOffset,
    required EventOrigin origin,
    required ConfidenceLabel confidence,
    Set<ResultFlag> flags = const {},
  }) {
    if (origin is NoEvent) {
      throw ArgumentError.value(origin, 'origin', 'a timed event has a root');
    }
    if (dayOffset < -1 || dayOffset > 1) {
      throw ArgumentError.value(dayOffset, 'dayOffset', 'not in [-1, 1]');
    }
    return PrayerTime._(
      event: event,
      origin: origin,
      confidence: confidence,
      flags: Set.unmodifiable(flags),
      rawUtcMs: rawUtcMs,
      displayedUtcMs: displayedUtcMs,
      dayOffset: dayOffset,
    );
  }

  /// An event without a time on this day, for [reason].
  factory noEvent({
    required PrayerEvent event,
    required NoEventReason reason,
    required ConfidenceLabel confidence,
    Set<ResultFlag> flags = const {},
  }) => PrayerTime._(
    event: event,
    origin: EventOrigin.noEvent(reason),
    confidence: confidence,
    flags: Set.unmodifiable(flags),
    rawUtcMs: null,
    displayedUtcMs: null,
    dayOffset: null,
  );

  const new _({
    required this.event,
    required this.origin,
    required this.confidence,
    required this.flags,
    required this.rawUtcMs,
    required this.displayedUtcMs,
    required this.dayOffset,
  });

  /// The event.
  final PrayerEvent event;

  /// How the time was obtained (REQ-DOM-002).
  final EventOrigin origin;

  /// The label shown with the time (REQ-DOM-010).
  final ConfidenceLabel confidence;

  /// Facts the Passport explains.
  final Set<ResultFlag> flags;

  /// The rule's instant, UTC epoch milliseconds truncated to 1 ms; `null`
  /// for [NoEvent].
  final int? rawUtcMs;

  /// The instant shown and alarmed (REQ-ALM-001); `null` for [NoEvent].
  final int? displayedUtcMs;

  /// Local date of [displayedUtcMs] minus the prayer day; `null` for
  /// [NoEvent].
  final int? dayOffset;

  @override
  bool operator ==(Object other) =>
      other is PrayerTime &&
      other.event == event &&
      other.origin == origin &&
      other.confidence == confidence &&
      other.flags.length == flags.length &&
      other.flags.containsAll(flags) &&
      other.rawUtcMs == rawUtcMs &&
      other.displayedUtcMs == displayedUtcMs &&
      other.dayOffset == dayOffset;

  @override
  int get hashCode => Object.hash(
    event,
    origin,
    confidence,
    Object.hashAllUnordered(flags),
    rawUtcMs,
    displayedUtcMs,
    dayOffset,
  );

  @override
  String toString() =>
      'PrayerTime(${event.name}, $origin, raw: $rawUtcMs, '
      'displayed: $displayedUtcMs, dayOffset: $dayOffset)';
}
