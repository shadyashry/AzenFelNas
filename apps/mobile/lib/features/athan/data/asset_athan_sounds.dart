import 'dart:convert';

import 'package:daily_muslim/features/athan/domain/read_athan_sounds.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';

/// [ReadAthanSounds] over the bundled `athan_audio_manifest.v1` asset. No
/// asset yet means no sounds (Content owes the recordings, §15 D83), which
/// Health reports as `noSoundAsset`. A test sound (its `licenceRef` starts
/// with [testLicencePrefix]) is listed only when [includeTestSounds] is set,
/// on the `dev` and `lab` channels (§15 D94).
final class AssetAthanSounds implements ReadAthanSounds {
  /// The adapter reading [manifestKey] from [_bundle].
  const new(
    this._bundle, {
    required this.includeTestSounds,
    this.manifestKey = defaultKey,
  });

  /// Where the manifest is bundled.
  static const String defaultKey = 'assets/athan/athan_audio_manifest.json';

  /// The `licenceRef` prefix of a sound bundled for testing only.
  static const String testLicencePrefix = 'TEST-';

  /// Whether test sounds are offered.
  final bool includeTestSounds;

  final AssetBundle _bundle;

  /// The asset key of the manifest.
  final String manifestKey;

  @override
  Future<List<String>> call() async {
    final assets = await AssetManifest.loadFromAssetBundle(_bundle);
    if (!assets.listAssets().contains(manifestKey)) return const [];
    return switch (jsonDecode(await _bundle.loadString(manifestKey))) {
      final Map<String, Object?> json => [
        for (final s in AthanAudioManifest.fromJson(json).sounds)
          if (includeTestSounds || !s.licenceRef.startsWith(testLicencePrefix))
            s.soundId,
      ],
      _ => const [],
    };
  }
}
