import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/athan/application/athan_preferences.dart';
import 'package:daily_muslim/features/athan/data/asset_athan_sound_names.dart';
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
      final sounds = _manifest().sounds;
      expect(sounds, isNotEmpty);
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

    test("REQ-ALM-055 the owner's five voices are bundled and Ahmed "
        'El-Taraboulsy is the Athan sound until the user chooses '
        '(§15 D124, D129)', () async {
      expect(_manifest().sounds.map((s) => s.soundId), [
        'ahmed_eltaraboulsy',
        'abdelbasit',
        'mashary_alafasy',
        'mostafa_ismail',
        'ahmed_elhadad',
      ]);
      final offered = await AssetAthanSounds(
        rootBundle,
        includeTestSounds: true,
      )();
      expect(
        AthanPreferences.effectiveSound(null, offered),
        'ahmed_eltaraboulsy',
      );
      // A voice the user chose stays theirs.
      expect(
        AthanPreferences.effectiveSound('abdelbasit', offered),
        'abdelbasit',
      );
      final names = await AssetAthanSoundNames(rootBundle)();
      expect(names['ahmed_eltaraboulsy']?.of('en'), 'Ahmed El-Taraboulsy');
      expect(names['abdelbasit']?.of('en'), 'Abdul Basit Abdus Samad');
      expect(names['abdelbasit']?.of('ar'), 'عبد الباسط عبد الصمد');
      expect(names.keys, unorderedEquals(offered));
    });

    test('every bundled voice is named and credited on the licences page, '
        'and its licence is still under review (§15 D124)', () {
      final notices = jsonEncode(
        jsonDecode(
          File('assets/legal/attributions.v1.json').readAsStringSync(),
        ),
      );
      for (final s in _manifest().sounds) {
        expect(s.name, isNotNull, reason: s.soundId);
        expect(notices, contains(s.name?.en), reason: s.soundId);
        expect(_isTest(s), isTrue, reason: s.soundId);
      }
    });

    test('the schema fixture of a named sound decodes; a name without Arabic '
        'does not', () {
      const dir = '../../schemas/fixtures/athan_audio_manifest';
      Map<String, Object?> read(String f) =>
          jsonDecode(File('$dir/$f').readAsStringSync())
              as Map<String, Object?>;
      expect(
        AthanAudioManifest.fromJson(
          read('valid/named_sound.json'),
        ).sounds.single.name?.ar,
        'صوت الاختبار',
      );
      expect(
        () => AthanAudioManifest.fromJson(
          read('invalid/name_without_arabic.json'),
        ),
        throwsA(anything),
      );
    });
  });
}
