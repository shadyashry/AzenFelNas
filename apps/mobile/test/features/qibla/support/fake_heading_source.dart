import 'dart:async';

import 'package:daily_muslim/features/qibla/domain/heading_event.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';

/// A [HeadingSource] fake at the port: replays [events] to each listener,
/// then stays open like a running sensor; records the coordinates asked for
/// and whether a listener is active.
final class FakeHeadingSource implements HeadingSource {
  /// A fake that emits [events].
  new([this.events = const []]);

  /// What each subscription receives, in order.
  final List<HeadingEvent> events;

  /// The coordinates of every `watch` call.
  final List<(double, double)> requests = [];

  /// Whether a subscription is active (the sensor would be running).
  bool listening = false;

  @override
  Stream<HeadingEvent> watch({
    required double latitudeDeg,
    required double longitudeDeg,
  }) {
    requests.add((latitudeDeg, longitudeDeg));
    late final StreamController<HeadingEvent> controller;
    controller = StreamController<HeadingEvent>(
      onListen: () {
        listening = true;
        for (final event in events) {
          controller.add(event);
          if (event is HeadingUnavailable) {
            unawaited(controller.close());
            return;
          }
        }
      },
      onCancel: () => listening = false,
    );
    return controller.stream;
  }
}
