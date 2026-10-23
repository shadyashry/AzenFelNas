import 'dart:async';

import 'package:daily_muslim/features/qibla/domain/heading_event.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';
import 'package:flutter/services.dart';

/// [HeadingSource] over the `dm/heading` event channel (§7.8, §15 D78):
/// `onListen` starts the sensor (`HeadingApi.start`), `onCancel` stops it.
///
/// Each event is a map: `{"heading": double?, "accuracy": double?}` or
/// `{"unavailable": true}`. Anything else, a platform error or a missing
/// native side is [HeadingUnavailable]. Moves to pigeon with the other
/// platform APIs in S20.
final class ChannelHeadingSource implements HeadingSource {
  /// The adapter over [channel].
  const new({
    this.channel = const EventChannel(channelName),
    this.firstEventTimeout = defaultFirstEventTimeout,
  });

  /// The channel name of §7.8.
  static const channelName = 'dm/heading';

  /// The platform channel.
  final EventChannel channel;

  /// How long the first message may take before the compass counts as
  /// unavailable: the platform reports a missing native side only to the
  /// error log, never to the stream (§15 D78).
  static const defaultFirstEventTimeout = Duration(seconds: 5);

  /// The first-message timeout in use.
  final Duration firstEventTimeout;

  @override
  Stream<HeadingEvent> watch({
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    late final StreamController<HeadingEvent> out;
    StreamSubscription<Object?>? sub;
    Timer? firstEvent;
    void end({required bool unavailable}) {
      firstEvent?.cancel();
      if (out.isClosed) return;
      if (unavailable) out.add(const HeadingUnavailable());
      unawaited(sub?.cancel());
      unawaited(out.close());
    }

    out = StreamController<HeadingEvent>(
      onListen: () {
        firstEvent = Timer(firstEventTimeout, () => end(unavailable: true));
        sub = channel
            .receiveBroadcastStream({'lat': latitudeDeg, 'lon': longitudeDeg})
            .listen(
              (message) {
                firstEvent?.cancel();
                final event = parse(message);
                if (event is HeadingUnavailable) {
                  end(unavailable: true);
                } else if (!out.isClosed) {
                  out.add(event);
                }
              },
              onError: (Object _) => end(unavailable: true),
              onDone: () => end(unavailable: false),
            );
      },
      onCancel: () async {
        firstEvent?.cancel();
        await sub?.cancel();
      },
    );
    return out.stream;
  }

  /// The [HeadingEvent] of one channel message.
  static HeadingEvent parse(Object? event) {
    if (event is! Map<Object?, Object?> || event['unavailable'] == true) {
      return const HeadingUnavailable();
    }
    final heading = event['heading'];
    final accuracy = event['accuracy'];
    if ((heading != null && heading is! double) ||
        (accuracy != null && accuracy is! double)) {
      return const HeadingUnavailable();
    }
    final h = heading is double && heading.isFinite && heading >= 0
        ? heading % 360
        : null;
    final a = accuracy is double && accuracy.isFinite && accuracy >= 0
        ? accuracy
        : null;
    return HeadingReading(trueHeadingDeg: h, accuracyDeg: a);
  }
}
