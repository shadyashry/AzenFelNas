// The WriteWidgetSnapshot contract (§7.7, §7.8): never throws, a refusal
// or a missing host is false. The Kotlin and Swift `SnapshotStore` tests hold
// the native store to the same rules (validated, whole-document replace).
import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/athan/application/write_widget_snapshot.dart';
import 'package:daily_muslim/features/athan/data/pigeon_write_widget_snapshot.dart';
import 'package:dm_contracts/athan_scheduler_api.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_widget_host.dart';

const _channel =
    'dev.flutter.pigeon.dm_contracts.AthanSchedulerApi.writeSnapshot';

Snapshot _fixture() => Snapshot.fromJson(
  jsonDecode(
        File(
          '../../schemas/fixtures/snapshot/valid/'
          'REQ-WID-002_across_midnight.json',
        ).readAsStringSync(),
      )
      as Map<String, Object?>,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void contract(String name, WriteWidgetSnapshot Function() port) {
    test('REQ-WID-001 $name never throws and answers a bool', () async {
      expect(await port()(_fixture()), isA<bool>());
    });
  }

  contract('the fake', FakeWidgetHost.new);
  contract('the pigeon adapter without a host', () {
    return PigeonWriteWidgetSnapshot(AthanSchedulerApi());
  });

  group('pigeon adapter', () {
    tearDown(() => messenger.setMockMessageHandler(_channel, null));

    test('REQ-WID-001 no host is a refusal', () async {
      expect(
        await PigeonWriteWidgetSnapshot(AthanSchedulerApi())(_fixture()),
        isFalse,
      );
    });

    test('REQ-WID-001 the host receives the snapshot.v1 document and its '
        'answer is passed on', () async {
      Object? received;
      messenger.setMockMessageHandler(_channel, (message) async {
        final args =
            AthanSchedulerApi.pigeonChannelCodec.decodeMessage(message)
                as List<Object?>;
        received = args.single;
        return AthanSchedulerApi.pigeonChannelCodec.encodeMessage(<Object?>[
          true,
        ]);
      });
      final snapshot = _fixture();
      expect(
        await PigeonWriteWidgetSnapshot(AthanSchedulerApi())(snapshot),
        isTrue,
      );
      final json = received;
      expect(json, isA<String>());
      if (json is String) {
        expect(
          Snapshot.fromJson(jsonDecode(json) as Map<String, Object?>),
          snapshot,
        );
      }
    });
  });
}
