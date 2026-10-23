import 'package:daily_muslim/features/qibla/data/channel_heading_source.dart';
import 'package:daily_muslim/features/qibla/domain/heading_event.dart';
import 'package:daily_muslim/features/qibla/domain/heading_source.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_heading_source.dart';

const _reading = HeadingReading(trueHeadingDeg: 136.5, accuracyDeg: 8);
const _calibrating = HeadingReading(trueHeadingDeg: null, accuracyDeg: null);

/// One implementation under the contract, with a probe of its sensor.
typedef _Subject = ({
  HeadingSource source,
  bool Function() listening,
  List<(double, double)> Function() requests,
});

/// The [HeadingSource] contract (§17.7: a fake at a port passes the same
/// tests as the adapter).
void _contract(String name, _Subject Function(List<HeadingEvent>) make) {
  group('$name honours the HeadingSource contract', () {
    test('samples arrive in order with the observer coordinates', () async {
      final s = make([_reading, _calibrating]);
      final got = await s.source
          .watch(latitudeDeg: 30.04, longitudeDeg: 31.24)
          .take(2)
          .toList();
      expect(got, [_reading, _calibrating]);
      expect(s.requests(), [(30.04, 31.24)]);
    });

    test('unavailable is the last event', () async {
      final s = make([const HeadingUnavailable(), _reading]);
      final got = await s.source
          .watch(latitudeDeg: 0, longitudeDeg: 0)
          .toList();
      expect(got, [const HeadingUnavailable()]);
    });

    test('cancelling stops the sensor', () async {
      final s = make([_reading]);
      final sub = s.source
          .watch(latitudeDeg: 0, longitudeDeg: 0)
          .listen((_) {});
      await pumpEventQueue();
      expect(s.listening(), isTrue);
      await sub.cancel();
      await pumpEventQueue();
      expect(s.listening(), isFalse);
    });
  });
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const channel = EventChannel(ChannelHeadingSource.channelName);

  _contract('FakeHeadingSource', (events) {
    final fake = FakeHeadingSource(events);
    return (
      source: fake,
      listening: () => fake.listening,
      requests: () => fake.requests,
    );
  });

  _contract('ChannelHeadingSource', (events) {
    var listening = false;
    final requests = <(double, double)>[];
    messenger.setMockStreamHandler(
      channel,
      MockStreamHandler.inline(
        onListen: (arguments, sink) {
          listening = true;
          final args = _as<Map<Object?, Object?>>(arguments);
          requests.add((_as<double>(args['lat']), _as<double>(args['lon'])));
          for (final event in events) {
            sink.success(switch (event) {
              HeadingUnavailable() => {'unavailable': true},
              HeadingReading(:final trueHeadingDeg, :final accuracyDeg) => {
                'heading': trueHeadingDeg,
                'accuracy': accuracyDeg,
              },
            });
          }
        },
        onCancel: (_) => listening = false,
      ),
    );
    return (
      source: const ChannelHeadingSource(),
      listening: () => listening,
      requests: () => requests,
    );
  });

  group('ChannelHeadingSource.parse', () {
    test('malformed messages are unavailable, invalid values unknown', () {
      expect(ChannelHeadingSource.parse(null), const HeadingUnavailable());
      expect(
        ChannelHeadingSource.parse({'heading': 'north'}),
        const HeadingUnavailable(),
      );
      expect(
        ChannelHeadingSource.parse({'heading': -1.0, 'accuracy': -1.0}),
        _calibrating,
      );
      expect(
        ChannelHeadingSource.parse({'heading': 370.0, 'accuracy': 5.0}),
        const HeadingReading(trueHeadingDeg: 10, accuracyDeg: 5),
      );
    });

    test('a native side that never answers is unavailable', () async {
      messenger.setMockStreamHandler(
        channel,
        MockStreamHandler.inline(onListen: (arguments, sink) {}),
      );
      final got = await const ChannelHeadingSource(
        firstEventTimeout: Duration(milliseconds: 20),
      ).watch(latitudeDeg: 0, longitudeDeg: 0).toList();
      expect(got, [const HeadingUnavailable()]);
    });
  });
}

/// [value] as [T]; fails the test otherwise.
T _as<T>(Object? value) =>
    value is T ? value : throw StateError('not $T: $value');
