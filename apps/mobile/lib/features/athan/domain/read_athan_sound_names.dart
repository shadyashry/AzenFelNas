import 'package:meta/meta.dart';

/// The name of a bundled Athan sound in English and Arabic (§15 D124).
@immutable
final class SoundName {
  /// The name.
  const new({required this.en, required this.ar});

  /// The English name.
  final String en;

  /// The Arabic name.
  final String ar;

  /// The name in [languageCode] (`ar` or English).
  String of(String languageCode) => languageCode == 'ar' ? ar : en;
}

/// The names the audio manifest gives its bundled sounds (§15 D124).
abstract interface class ReadAthanSoundNames {
  /// The name of every bundled sound that has one, by `soundId`.
  Future<Map<String, SoundName>> call();
}
