import 'dart:async';

import 'package:daily_muslim/features/radio/domain/radio_playback.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:flutter/services.dart';

/// [RadioAudio] over the `dm/radio` channels (§15 D122): the native player
/// (Media3 `RadioService` on Android, `RadioPlayer` on iOS) owns playback,
/// so it carries on with no screen, and with no Dart, alive. States arrive
/// on `dm/radio/state` as `{phase, stationId, attempt, sleepMinutes,
/// sleepDeadlineUtcMs}`; anything unreadable reads as [RadioPlayback.idle].
final class ChannelRadioAudio implements RadioAudio {
  /// The adapter.
  const new();

  static const _methods = MethodChannel('dm/radio');
  static const _events = EventChannel('dm/radio/state');

  @override
  Future<RadioPlayback> current() async {
    try {
      return decode(await _methods.invokeMethod<Object?>('state'));
    } on PlatformException {
      return RadioPlayback.idle;
    } on MissingPluginException {
      return RadioPlayback.idle;
    }
  }

  /// Listens only where a native player answers, so a host without one
  /// (tests, desktop) gets no states rather than a reported error.
  @override
  Stream<RadioPlayback> get changes async* {
    try {
      await _methods.invokeMethod<Object?>('state');
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
    yield* _events
        .receiveBroadcastStream()
        .map(decode)
        .handleError((Object _) {}, test: (e) => e is PlatformException);
  }

  @override
  Future<void> play(RadioPlayRequest request) => _call('play', {
    'stationId': request.stationId.wire,
    'url': request.url.toString(),
    'title': request.title,
    'subtitle': request.subtitle,
  });

  @override
  Future<void> pause() => _call('pause');

  @override
  Future<void> resume() => _call('resume');

  @override
  Future<void> stop() => _call('stop');

  @override
  Future<void> sleep(RadioSleepOption option) =>
      _call('sleep', {'minutes': option.minutes});

  Future<void> _call(String method, [Map<String, Object?>? arguments]) async {
    try {
      await _methods.invokeMethod<void>(method, arguments);
    } on PlatformException {
      // The native player reports its own state; nothing to add here.
    } on MissingPluginException {
      // No native player (tests, desktop): nothing plays.
    }
  }

  /// The state of one channel message.
  static RadioPlayback decode(Object? message) {
    if (message case {'phase': final String wire}) {
      final phase = _phase(wire);
      if (phase == null) return RadioPlayback.idle;
      final station = switch (message['stationId']) {
        final String id => RadioStationId.parse(id),
        _ => null,
      };
      final attempt = switch (message['attempt']) {
        final int n when n >= 0 => n,
        _ => 0,
      };
      final sleep = switch ((
        message['sleepMinutes'],
        message['sleepDeadlineUtcMs'],
      )) {
        (final int minutes, final int deadline)
            when RadioSleepOption.ofMinutes(minutes) != RadioSleepOption.off =>
          RadioSleep(
            option: RadioSleepOption.ofMinutes(minutes),
            deadlineUtcMs: deadline,
          ),
        _ => null,
      };
      return RadioPlayback(
        phase: phase,
        stationId: station,
        attempt: attempt,
        sleep: sleep,
      );
    }
    return RadioPlayback.idle;
  }

  static RadioPhase? _phase(String wire) {
    for (final phase in RadioPhase.values) {
      if (phase.name == wire) return phase;
    }
    return null;
  }
}
