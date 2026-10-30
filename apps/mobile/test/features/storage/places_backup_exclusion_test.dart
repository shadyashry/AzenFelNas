// S16 done-test (backup exclusion, REQ-PRIV-003): places.sqlite lives in the
// one directory the platform rules exclude, and dm.sqlite does not.
// The device half (adb bmgr / iCloud backup listing) is owed: s16-handover.md.
import 'dart:io';

import 'package:daily_muslim/features/storage/data/database_files.dart';
import 'package:daily_muslim/features/storage/data/method_channel_backup_exclusion.dart';
import 'package:daily_muslim/features/storage/data/places_database.dart';
import 'package:daily_muslim/features/storage/data/static_rules_backup_exclusion.dart';
import 'package:daily_muslim/features/storage/domain/exclude_from_backup.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

final class _RecordingExclusion implements ExcludeFromBackup {
  final excluded = <String>[];

  @override
  Future<bool> call(String directoryPath) async {
    excluded.add(directoryPath);
    return true;
  }
}

/// The `<exclude …/>` elements inside [section] of [xml].
List<String> _excludes(String xml, String section) {
  final body = RegExp(
    '<$section>(.*?)</$section>',
    dotAll: true,
  ).firstMatch(xml)?.group(1);
  return [
    for (final m in RegExp(r'<exclude\s+(.*?)\s*/>').allMatches(body ?? ''))
      (m.group(1) ?? '').replaceAll(RegExp(r'\s+'), ' ').trim(),
  ];
}

void main() {
  const res = 'android/app/src/main/res/xml';
  const placesRule = 'domain="file" path="${PlacesDatabase.directoryName}/"';
  const quranRule = 'domain="file" path="quran/"';

  group('Android rules exclude places/ from backup (REQ-PRIV-003)', () {
    final manifest = File(
      'android/app/src/main/AndroidManifest.xml',
    ).readAsStringSync();

    test('the manifest names both rule files', () {
      expect(
        manifest,
        contains('android:fullBackupContent="@xml/backup_rules"'),
      );
      expect(
        manifest,
        contains('android:dataExtractionRules="@xml/data_extraction_rules"'),
      );
      expect(manifest, isNot(contains('android:allowBackup="true"')));
    });

    test('Auto Backup up to API 30 (fullBackupContent)', () {
      final xml = File('$res/backup_rules.xml').readAsStringSync();
      // The offline Quran package (§15 D107) is downloaded again instead.
      expect(_excludes(xml, 'full-backup-content'), [placesRule, quranRule]);
    });

    test('API 31+ cloud backup and device transfer (dataExtractionRules)', () {
      final xml = File('$res/data_extraction_rules.xml').readAsStringSync();
      expect(_excludes(xml, 'cloud-backup'), [placesRule, quranRule]);
      expect(_excludes(xml, 'device-transfer'), [placesRule]);
    });
  });

  group('DatabaseFiles places the files (REQ-PRIV-003)', () {
    late Directory root;
    setUp(() => root = Directory.systemTemp.createTempSync('dm_backup'));
    tearDown(() => root.deleteSync(recursive: true));

    test(
      'places.sqlite is inside the excluded directory, which is excluded '
      'before the file is created; dm.sqlite stays backed up',
      () async {
        final exclusion = _RecordingExclusion();
        final created = <String>[];
        final open = DatabaseFiles(
          supportDirectory: () async => root,
          excludeFromBackup: exclusion,
          executorFor: (file) {
            created.add(file.path);
            expect(exclusion.excluded, isNotEmpty);
            return NativeDatabase(file);
          },
        );

        final opened = switch (await open()) {
          Ok(:final value) => value,
          Err(:final failure) => fail('$failure'),
        };

        final placesDir = '${root.path}/${PlacesDatabase.directoryName}';
        expect(exclusion.excluded, [placesDir]);
        expect(created, [
          '${root.path}/dm.sqlite',
          '$placesDir/${PlacesDatabase.fileName}',
        ]);
        expect(opened.placesExcludedFromBackup, isTrue);
        await opened.close();
        expect(
          Directory(placesDir).listSync().map((e) => e.uri.pathSegments.last),
          everyElement(startsWith(PlacesDatabase.fileName)),
        );
      },
    );

    test('a refused exclusion is recorded, not fatal', () async {
      final open = DatabaseFiles(
        supportDirectory: () async => root,
        excludeFromBackup: const _Refusing(),
        executorFor: NativeDatabase.new,
      );
      final opened = switch (await open()) {
        Ok(:final value) => value,
        Err(:final failure) => fail('$failure'),
      };
      expect(opened.placesExcludedFromBackup, isFalse);
      await opened.close();
    });
  });

  group('ExcludeFromBackup contract (REQ-PRIV-003)', () {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel(MethodChannelBackupExclusion.channelName);
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    tearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final adapters = <String, ExcludeFromBackup>{
      'fake': _RecordingExclusion(),
      'android static rules': const StaticRulesBackupExclusion(),
      'iOS method channel': const MethodChannelBackupExclusion(),
    };
    for (final MapEntry(:key, :value) in adapters.entries) {
      test('$key: confirms an exclusion and is idempotent', () async {
        messenger.setMockMethodCallHandler(channel, (_) async => true);
        expect(await value('/data/places'), isTrue);
        expect(await value('/data/places'), isTrue);
      });
    }

    test('iOS sends the directory to the Swift handler', () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return true;
      });
      await const MethodChannelBackupExclusion()('/x/places');
      expect(calls.single.method, MethodChannelBackupExclusion.method);
      expect(calls.single.arguments, {'path': '/x/places'});
    });

    test(
      'iOS: a platform error or a missing handler is false, not a throw',
      () async {
        messenger.setMockMethodCallHandler(
          channel,
          (_) async => throw PlatformException(code: 'denied'),
        );
        expect(await const MethodChannelBackupExclusion()('/x'), isFalse);
        messenger.setMockMethodCallHandler(channel, null);
        expect(await const MethodChannelBackupExclusion()('/x'), isFalse);
      },
    );

    test('the Swift handler uses the same channel and method names', () {
      final swift = File('ios/Runner/AppDelegate.swift').readAsStringSync();
      expect(
        swift,
        contains('"${MethodChannelBackupExclusion.channelName}"'),
      );
      expect(swift, contains('"${MethodChannelBackupExclusion.method}"'));
      expect(swift, contains('isExcludedFromBackup = true'));
    });
  });
}

final class _Refusing implements ExcludeFromBackup {
  const new();

  @override
  Future<bool> call(String directoryPath) async => false;
}
