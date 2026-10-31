import 'dart:convert';

import 'package:daily_muslim/features/athan/data/asset_athan_sounds.dart';
import 'package:daily_muslim/features/athan/domain/read_athan_sound_names.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';

/// [ReadAthanSoundNames] over the bundled `athan_audio_manifest.v1` asset
/// (§15 D124). No asset, or a sound without a name, gives no name.
final class AssetAthanSoundNames implements ReadAthanSoundNames {
  /// The adapter reading [manifestKey] from [_bundle].
  const new(this._bundle, {this.manifestKey = AssetAthanSounds.defaultKey});

  final AssetBundle _bundle;

  /// The asset key of the manifest.
  final String manifestKey;

  @override
  Future<Map<String, SoundName>> call() async {
    final assets = await AssetManifest.loadFromAssetBundle(_bundle);
    if (!assets.listAssets().contains(manifestKey)) return const {};
    return switch (jsonDecode(await _bundle.loadString(manifestKey))) {
      final Map<String, Object?> json => {
        for (final s in AthanAudioManifest.fromJson(json).sounds)
          if (s.name case final AthanSoundName name)
            s.soundId: SoundName(en: name.en, ar: name.ar),
      },
      _ => const {},
    };
  }
}
