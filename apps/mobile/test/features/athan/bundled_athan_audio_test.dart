import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/athan/data/asset_athan_sounds.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

AthanAudioManifest _manifest() => AthanAudioManifest.fromJson(
  jsonDecode(File('assets/athan/athan_audio_manifest.json').readAsStringSync())
      as Map<String, Object?>,
);

bool _isTest(AthanSound sound) =>
    sound.licenceRef.startsWith(AssetAthanSounds.testLicencePrefix);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Bundled Athan audio (§15 D93, D94)', () {
    test('every bundled sound file exists and matches its manifest sha256', () {
      // None is bundled since S43 (§15 D111); any that returns is checked.
      final sounds = _manifest().sounds;
      for (final sound in sounds) {
        final file = File('assets/${sound.file}');
        expect(file.existsSync(), isTrue, reason: sound.file);
        expect(
          sha256.convert(file.readAsBytesSync()).toString(),
          sound.sha256,
          reason: sound.file,
        );
      }
    });

    test('no test sound is bundled once the app reaches 1.0.0: licensed '
        'recordings replace it before release', () {
      final version = RegExp(
        r'^version: (\d+)\.',
        multiLine: true,
      ).firstMatch(File('pubspec.yaml').readAsStringSync())?.group(1);
      final major = int.parse(version ?? '0');
      if (major >= 1) {
        expect(_manifest().sounds.where(_isTest), isEmpty);
      } else {
        expect(major, 0);
      }
    });

    test('a test sound is offered on dev and lab only', () async {
      final tests = [
        for (final s in _manifest().sounds)
          if (_isTest(s)) s.soundId,
      ];

      expect(
        await AssetAthanSounds(rootBundle, includeTestSounds: true)(),
        containsAll(tests),
      );
      expect(
        await AssetAthanSounds(rootBundle, includeTestSounds: false)(),
        isNot(anyElement(isIn(tests))),
      );
    });
  });
}
