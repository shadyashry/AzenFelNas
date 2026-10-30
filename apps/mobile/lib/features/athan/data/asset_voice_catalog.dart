import 'dart:convert';

import 'package:daily_muslim/features/athan/domain/athan_voice.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:flutter/services.dart';

/// [ReadVoiceCatalog] over the bundled `athan_voice_catalog.v1` asset
/// (§15 D111). A voice whose listening review is pending is listed only when
/// [includePending] is set, on the `dev` and `lab` channels (REQ-ALM-050);
/// nothing is listed when [supported] is false (iOS until AthanKit installs
/// downloaded voices, §15 D111). A malformed catalog lists nothing.
final class AssetVoiceCatalog implements ReadVoiceCatalog {
  /// The adapter reading [catalogKey] from [_bundle].
  const new(
    this._bundle, {
    required this.includePending,
    required this.supported,
    this.catalogKey = defaultKey,
  });

  /// Where the catalog is bundled.
  static const String defaultKey = 'assets/athan/voice_catalog.json';

  /// Whether voices awaiting their listening review are offered.
  final bool includePending;

  /// Whether this platform can play downloaded voices as alarms.
  final bool supported;

  final AssetBundle _bundle;

  /// The asset key of the catalog.
  final String catalogKey;

  @override
  Future<List<AthanVoice>> call() async {
    if (!supported) return const [];
    final assets = await AssetManifest.loadFromAssetBundle(_bundle);
    if (!assets.listAssets().contains(catalogKey)) return const [];
    try {
      return [
        for (final voice in decode(await _bundle.loadString(catalogKey)))
          if (includePending || voice.review == VoiceReview.passed) voice,
      ];
    } on FormatException {
      return const [];
    }
  }

  /// The voices of an `athan_voice_catalog.v1` document; throws
  /// [FormatException] when it does not have the schema's shape.
  static List<AthanVoice> decode(String json) => switch (jsonDecode(json)) {
    {'schemaVersion': 1, 'voices': final List<Object?> voices} => [
      for (final v in voices) _voice(v),
    ],
    _ => throw const FormatException('not an athan_voice_catalog.v1'),
  };

  static AthanVoice _voice(Object? json) => switch (json) {
    {
      'soundId': final String soundId,
      'name': {'en': final String en, 'ar': final String ar},
      'designation': final String designation,
      'review': final String review,
      'file': {
        'path': final String path,
        'bytes': final int bytes,
        'sha256': final String sha256,
        'durationMs': final int durationMs,
      },
      'credit': {
        'creator': final String creator,
        'sourcePage': final String sourcePage,
        'licence': final String licence,
        'licenceUrl': final String licenceUrl,
        'changes': final String changes,
      },
    }
        when _soundId.hasMatch(soundId) &&
            _path.hasMatch(path) &&
            _sha256.hasMatch(sha256) &&
            bytes > 0 =>
      AthanVoice(
        soundId: soundId,
        nameEn: en,
        nameAr: ar,
        designation: switch (designation) {
          'STANDARD' => VoiceDesignation.standard,
          'FAJR' => VoiceDesignation.fajr,
          _ => throw FormatException('designation $designation'),
        },
        review: switch (review) {
          'PENDING' => VoiceReview.pending,
          'PASSED' => VoiceReview.passed,
          _ => throw FormatException('review $review'),
        },
        path: path,
        bytes: bytes,
        sha256: sha256,
        durationMs: durationMs,
        credit: VoiceCredit(
          creator: creator,
          sourcePage: sourcePage,
          licence: licence,
          licenceUrl: licenceUrl,
          changes: changes,
        ),
      ),
    _ => throw const FormatException('voice'),
  };

  static final RegExp _soundId = RegExp(r'^[a-z0-9_]+$');
  static final RegExp _path = RegExp(r'^[a-z0-9_]+/[0-9]+/[a-z0-9_]+[.]m4a$');
  static final RegExp _sha256 = RegExp(r'^[a-f0-9]{64}$');
}
