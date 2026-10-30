import 'package:daily_muslim/features/athan/application/check_voices.dart';
import 'package:daily_muslim/features/athan/application/download_voice.dart';
import 'package:daily_muslim/features/athan/application/remove_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_download_status.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_voices.dart';

void main() {
  late FakeVoiceDisk disk;
  late FakeVoiceOrigin origin;
  late FakeVoiceAudioHost host;
  final voice = fakeVoice('malmo');

  DownloadVoice download({int? free}) => DownloadVoice(
    disk: disk,
    origin: origin,
    host: host,
    freeSpace: FakeFreeSpace(free),
  );

  setUp(() {
    disk = FakeVoiceDisk();
    origin = FakeVoiceOrigin(disk);
    host = FakeVoiceAudioHost();
  });

  group('DownloadVoice (§15 D111)', () {
    test('REQ-ALM-051 a download is verified, then handed to the alarm '
        'player, and only then reported downloaded', () async {
      final statuses = await download()(voice, DownloadCancel()).toList();

      expect(statuses.last, isA<VoiceDownloaded>());
      expect(statuses.first, isA<VoiceDownloading>());
      expect(disk.files[voice.soundId], VoiceFileState.verified);
      expect(host.installed, {voice.soundId});
      expect(origin.requested, [voice.path]);
    });

    test('REQ-ALM-051 an interrupted download resumes from the bytes kept '
        'and reports them', () async {
      origin.failAfterBytes = 400;
      final first = await download()(voice, DownloadCancel()).toList();
      expect(
        (first.last as VoiceDownloadFailed).failure,
        isA<VoiceOffline>(),
      );
      expect(disk.parts[voice.soundId], 400);
      expect(host.installed, isEmpty);

      final second = await download()(voice, DownloadCancel()).toList();
      expect(
        second.first,
        const VoiceDownloading(doneBytes: 400, totalBytes: 1000),
      );
      expect(second.last, isA<VoiceDownloaded>());
    });

    test('REQ-ALM-051 bytes that do not match the pin are deleted and never '
        'reach the alarm player', () async {
      disk.corruptNextCommit = true;
      final statuses = await download()(voice, DownloadCancel()).toList();

      expect(
        (statuses.last as VoiceDownloadFailed).failure,
        isA<VoiceIntegrityFailed>(),
      );
      expect(disk.files, isEmpty);
      expect(disk.parts, isEmpty);
      expect(host.installed, isEmpty);
    });

    test('REQ-ALM-051 low storage stops before any byte is fetched', () async {
      final statuses = await download(free: 100)(
        voice,
        DownloadCancel(),
      ).toList();

      expect(
        (statuses.single as VoiceDownloadFailed).failure,
        isA<VoiceNoSpace>(),
      );
      expect(origin.requested, isEmpty);
    });

    test('REQ-ALM-051 when the alarm player refuses the file it is removed, '
        'so a voice is never shown downloaded but silent', () async {
      host.refuse = true;
      final statuses = await download()(voice, DownloadCancel()).toList();

      expect(
        (statuses.last as VoiceDownloadFailed).failure,
        isA<VoiceStorageFailed>(),
      );
      expect(disk.files, isEmpty);
    });
  });

  group('CheckVoices and RemoveVoice (§15 D111)', () {
    test('REQ-ALM-051 a verified file is handed to the alarm player again '
        'and a damaged one is deleted from both and reported', () async {
      final good = fakeVoice('good');
      final bad = fakeVoice('bad');
      disk.files
        ..[good.soundId] = VoiceFileState.verified
        ..[bad.soundId] = VoiceFileState.damaged;
      host.installed.add(bad.soundId);

      final inventory = await CheckVoices(disk: disk, host: host)([
        good,
        bad,
        fakeVoice('absent'),
      ]);

      expect(inventory.installed, {'good'});
      expect(inventory.damaged, {'bad'});
      expect(disk.files.keys, ['good']);
      expect(host.installed, {'good'});
    });

    test(
      'removing a voice deletes the file and the alarm player copy',
      () async {
        disk.files[voice.soundId] = VoiceFileState.verified;
        host.installed.add(voice.soundId);

        await RemoveVoice(disk: disk, host: host)(voice);

        expect(disk.files, isEmpty);
        expect(host.installed, isEmpty);
      },
    );
  });
}
