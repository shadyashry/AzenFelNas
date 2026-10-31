import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:meta/meta.dart';

/// Where the one radio player is (§15 D122, REQ-RADIO-010). It comes from
/// the native player, so "playing" is said only once audio really plays.
enum RadioPhase {
  /// Nothing playing; a station may be chosen.
  ready,

  /// Opening the stream after the listener asked for it.
  connecting,

  /// Audio is playing.
  playing,

  /// Paused by the listener, a call, the Athan or the headphones going.
  paused,

  /// The stream broke; trying the same station again.
  reconnecting,

  /// Stopped by the listener or the sleep timer.
  stopped,

  /// The station could not be played after the retries.
  unavailable,
}

/// The sleep timer's choices (§15 D122).
enum RadioSleepOption {
  /// No timer.
  off(0),

  /// 15 minutes.
  minutes15(15),

  /// 30 minutes.
  minutes30(30),

  /// 60 minutes.
  minutes60(60);

  new(this.minutes);

  /// The length in minutes; 0 for [off].
  final int minutes;

  /// The option of [minutes], or [off] for any other value.
  static RadioSleepOption ofMinutes(int minutes) {
    for (final option in values) {
      if (option.minutes == minutes) return option;
    }
    return off;
  }
}

/// A running sleep timer: the chosen [option] and when it stops the radio.
@immutable
final class RadioSleep {
  /// The timer.
  const new({required this.option, required this.deadlineUtcMs});

  /// The chosen length.
  final RadioSleepOption option;

  /// When playback stops (UTC epoch ms), kept by the native player so it
  /// fires with the screen locked.
  final int deadlineUtcMs;

  @override
  bool operator ==(Object other) =>
      other is RadioSleep &&
      other.option == option &&
      other.deadlineUtcMs == deadlineUtcMs;

  @override
  int get hashCode => Object.hash(option, deadlineUtcMs);
}

/// The player's state as the native side reports it.
@immutable
final class RadioPlayback {
  /// The state.
  const new({
    required this.phase,
    this.stationId,
    this.attempt = 0,
    this.sleep,
  });

  /// Nothing loaded.
  static const RadioPlayback idle = RadioPlayback(phase: RadioPhase.ready);

  /// The phase.
  final RadioPhase phase;

  /// The station loaded in the player, if any.
  final RadioStationId? stationId;

  /// The reconnection attempt (1-based) while [RadioPhase.reconnecting].
  final int attempt;

  /// The running sleep timer, if any.
  final RadioSleep? sleep;

  /// Whether a listening session exists (connecting, playing, paused or
  /// reconnecting): the mini player shows only then.
  bool get session => switch (phase) {
    RadioPhase.connecting ||
    RadioPhase.playing ||
    RadioPhase.paused ||
    RadioPhase.reconnecting => true,
    RadioPhase.ready || RadioPhase.stopped || RadioPhase.unavailable => false,
  };

  /// Whether the listener wants sound now (Pause is the action to show).
  bool get wantsSound => switch (phase) {
    RadioPhase.connecting ||
    RadioPhase.playing ||
    RadioPhase.reconnecting => true,
    RadioPhase.paused ||
    RadioPhase.ready ||
    RadioPhase.stopped ||
    RadioPhase.unavailable => false,
  };

  @override
  bool operator ==(Object other) =>
      other is RadioPlayback &&
      other.phase == phase &&
      other.stationId == stationId &&
      other.attempt == attempt &&
      other.sleep == sleep;

  @override
  int get hashCode => Object.hash(phase, stationId, attempt, sleep);
}
