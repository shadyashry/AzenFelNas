import 'package:daily_muslim/features/passport/domain/calculation_link.dart';
import 'package:daily_muslim/features/passport/domain/passport_entry.dart';
import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:geo_salah_core/geo_salah_core.dart';
import 'package:meta/meta.dart';

/// One event of a [PassportView], with local times already derived from
/// the app's pinned TZDB (REQ-TIME-020).
@immutable
final class PassportEventView {
  /// Creates a [PassportEventView].
  const new({
    required this.time,
    required this.rounding,
    required this.rawLocal,
    required this.displayedLocal,
    required this.adjustments,
    required this.sensitivitySeconds,
  });

  /// The engine's time with origin, confidence and flags.
  final PrayerTime time;

  /// The rounding mode applied.
  final RoundingMode rounding;

  /// Raw instant, local `HH:MM:SS.mmm`, or `null` without a time.
  final String? rawLocal;

  /// Displayed time, local `HH:MM`, or `null` without a time.
  final String? displayedLocal;

  /// The adjustment trace steps of this event, in order.
  final List<AdjustmentStep> adjustments;

  /// Whole seconds the raw instant moves within ±1 km (rounded up), or
  /// `null` when not measured.
  final int? sensitivitySeconds;
}

/// The Passport entry as shown (US-08): inputs, versions, every event, the
/// share link.
@immutable
final class PassportView {
  /// Creates a [PassportView].
  const new({
    required this.calculationId,
    required this.origin,
    required this.inputs,
    required this.provenance,
    required this.events,
    required this.shareLink,
    this.focus,
  });

  /// Builds the view of [entry] with [tzdb] local times.
  factory of(PassportEntry entry, PinnedTzDatabase tzdb) {
    String clock(int utcMs, {required bool seconds}) {
      final ms = tzdb.localDateTimeOf(entry.zoneId, utcMs).millisecondOfDay;
      String two(int v) => v.toString().padLeft(2, '0');
      final hm = '${two(ms ~/ 3600000)}:${two(ms ~/ 60000 % 60)}';
      if (!seconds) return hm;
      final frac = (ms % 1000).toString().padLeft(3, '0');
      return '$hm:${two(ms ~/ 1000 % 60)}.$frac';
    }

    final trace = entry.day.provenance.adjustmentTrace;
    final events = [
      for (final time in entry.day.times)
        PassportEventView(
          time: time,
          rounding: entry.roundingOf(time.event),
          rawLocal: switch (time.rawUtcMs) {
            final int ms => clock(ms, seconds: true),
            null => null,
          },
          displayedLocal: switch (time.displayedUtcMs) {
            final int ms => clock(ms, seconds: false),
            null => null,
          },
          adjustments: [
            for (final step in trace)
              if (step.event == time.event) step,
          ],
          sensitivitySeconds: switch (entry.sensitivityMs[time.event]) {
            final int ms => (ms + 999) ~/ 1000,
            null => null,
          },
        ),
    ];
    final focus = entry.focus;
    return PassportView(
      calculationId: entry.day.calculationId,
      origin: entry.origin,
      inputs: entry.inputs,
      provenance: entry.day.provenance,
      events: [
        ...events.where((e) => e.time.event == focus),
        ...events.where((e) => e.time.event != focus),
      ],
      shareLink: CalculationLink.of(
        calculationId: entry.day.calculationId,
        inputs: entry.inputs,
        event: focus,
      ),
      focus: focus,
    );
  }

  /// The Calculation ID.
  final String calculationId;

  /// Local or a matching import.
  final PassportOrigin origin;

  /// The hashed inputs.
  final CalculationInputs inputs;

  /// Engine, ΔT model, profile, TZDB versions and the inputs hash.
  final Provenance provenance;

  /// Every event, the focused one first.
  final List<PassportEventView> events;

  /// `dailymuslim://app/calc/<id>?i=…#<event>`.
  final Uri shareLink;

  /// The addressed event, or `null`.
  final PrayerEvent? focus;
}
