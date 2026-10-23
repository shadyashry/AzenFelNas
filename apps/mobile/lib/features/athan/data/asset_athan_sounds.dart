import 'dart:convert';

import 'package:daily_muslim/features/athan/application/read_athan_sounds.dart';
import 'package:dm_contracts/dm_contracts.dart';
import 'package:flutter/services.dart';

/// [ReadAthanSounds] over the bundled `athan_audio_manifest.v1` asset. No
/// asset yet means no sounds (Content owes the recordings, §15 D83), which
/// Health reports as `noSoundAsset`.
final class AssetAthanSounds implements ReadAthanSounds {
  /// The adapter reading [manifestKey] through [_load].
  const new(this._load, {this.manifestKey = defaultKey});

  /// Where the manifest is bundled.
  static const String defaultKey = 'assets/athan/athan_audio_manifest.json';

  final Future<String> Function(String key) _load;

  /// The asset key of the manifest.
  final String manifestKey;

  @override
  Future<List<AthanSound>> call() async {
    final String text;
    try {
      text = await _load(manifestKey);
    } on FlutterError {
      return const [];
    }
    return switch (jsonDecode(text)) {
      final Map<String, Object?> json => AthanAudioManifest.fromJson(
        json,
      ).sounds,
      _ => const [],
    };
  }
}
