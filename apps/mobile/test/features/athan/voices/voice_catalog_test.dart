import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/athan/data/asset_voice_catalog.dart';
import 'package:daily_muslim/features/athan/data/io_voice_disk.dart';
import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/fake_voices.dart';

String _read(String path) => File(path).readAsStringSync();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('The bundled voice catalog (§15 D111)', () {
    test('REQ-ALM-050 every voice names its creator, source, a licence that '
        'allows redistribution with changes, and the changes made', () {
      final voices = AssetVoiceCatalog.decode(
        _read('assets/athan/voice_catalog.json'),
      );
      expect(voices, isNotEmpty);
      for (final v in voices) {
        expect(v.credit.creator, isNotEmpty);
        expect(v.credit.sourcePage, startsWith('https://'));
        expect(v.credit.licence, isIn(['CC0-1.0', 'CC-BY-3.0', 'CC-BY-4.0']));
        expect(v.credit.changes, isNotEmpty);
        expect(v.path, '${v.soundId}/1/${v.soundId}.m4a');
      }
    });

    test('REQ-ALM-050 every voice is credited on the licences page', () {
      final notices = jsonEncode(
        jsonDecode(_read('assets/legal/attributions.v1.json')),
      );
      for (final v in AssetVoiceCatalog.decode(
        _read('assets/athan/voice_catalog.json'),
      )) {
        expect(notices, contains(v.nameEn));
      }
    });

    test(
      'REQ-ALM-050 a voice awaiting its listening review is offered on '
      'dev and lab only, and nothing where the alarm cannot play it',
      () async {
        final pending = await AssetVoiceCatalog(
          rootBundle,
          includePending: true,
          supported: true,
        )();
        expect(pending.map((v) => v.review), contains(VoiceReview.pending));
        final release = await AssetVoiceCatalog(
          rootBundle,
          includePending: false,
          supported: true,
        )();
        expect(release.where((v) => v.review == VoiceReview.pending), isEmpty);
        expect(
          await AssetVoiceCatalog(
            rootBundle,
            includePending: true,
            supported: false,
          )(),
          isEmpty,
        );
      },
    );

    test('the schema fixtures decode as the catalog does: the valid one '
        'reads, a path that escapes the voices directory does not', () {
      const dir = '../../schemas/fixtures/athan_voice_catalog';
      expect(
        AssetVoiceCatalog.decode(_read('$dir/valid/one_fajr_voice.json')),
        hasLength(1),
      );
      expect(
        () => AssetVoiceCatalog.decode(
          _read('$dir/invalid/REQ-ALM-051_path_escapes_voices.json'),
        ),
        throwsFormatException,
      );
      expect(
        () => AssetVoiceCatalog.decode(
          _read('$dir/invalid/REQ-ALM-052_unknown_designation.json'),
        ),
        throwsFormatException,
      );
    });
  });

  group('IoVoiceDisk (§15 D111)', () {
    late Directory root;
    setUp(() => root = Directory.systemTemp.createTempSync('voices'));
    tearDown(() => root.deleteSync(recursive: true));

    AthanVoice voiceOf(List<int> bytes) => AthanVoice(
      soundId: 'malmo',
      nameEn: 'x',
      nameAr: 'x',
      designation: VoiceDesignation.fajr,
      review: VoiceReview.pending,
      path: 'malmo/1/malmo.m4a',
      bytes: bytes.length,
      sha256: sha256.convert(bytes).toString(),
      durationMs: 1000,
      credit: fakeVoice('x').credit,
    );

    test('REQ-ALM-051 a part becomes the voice in one rename only when its '
        'size and SHA-256 match; a damaged file is reported', () async {
      final disk = IoVoiceDisk(root);
      final voice = voiceOf(utf8.encode('the recording'));
      File(disk.partPath(voice)).writeAsStringSync('the recordinG');
      expect(await disk.commit(voice), isA<Err<void, VoiceFailure>>());
      expect(File(disk.partPath(voice)).existsSync(), isFalse);

      File(disk.partPath(voice)).writeAsStringSync('the recording');
      expect(await disk.partBytes(voice), 13);
      expect(await disk.commit(voice), isA<Ok<void, VoiceFailure>>());
      expect(await disk.check(voice), VoiceFileState.verified);

      File(disk.filePath(voice)).writeAsStringSync('changed');
      expect(await disk.check(voice), VoiceFileState.damaged);
      await disk.remove(voice);
      expect(await disk.check(voice), VoiceFileState.absent);
    });
  });
}
