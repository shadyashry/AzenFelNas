import 'dart:io';

import 'package:daily_muslim/features/home/presentation/display_style.dart';
import 'package:daily_muslim/features/quran/domain/installed_quran.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/l10n/app_localizations.dart';
import 'package:flutter/services.dart';

/// Sizes, numbers and failures written for the reader.
abstract final class QuranFormat {
  /// [bytes] in decimal megabytes with one decimal, e.g. `119.2 MB`, in
  /// [style]'s digits.
  static String bytes(int bytes, DisplayStyle style) =>
      style.digits.apply('${(bytes / 1e6).toStringAsFixed(1)} MB');

  /// [n] in [style]'s digits.
  static String number(int n, DisplayStyle style) =>
      style.digits.apply(n.toString());

  /// The message for [failure].
  static String failure(
    AppLocalizations l,
    QuranFailure failure,
    DisplayStyle style,
  ) => switch (failure) {
    QuranOffline() => l.quranFailOffline,
    QuranServerRefused(:final status) => l.quranFailServer(
      style.digits.apply('$status'),
    ),
    QuranNoSpace(:final neededBytes, availableBytes: final int available) =>
      l.quranFailSpace(bytes(neededBytes, style), bytes(available, style)),
    QuranNoSpace() => l.quranFailSpaceFull,
    QuranIntegrityFailed() => l.quranFailIntegrity,
    QuranStorageFailed() => l.quranFailStorage,
    QuranSearchUnavailable() => l.quranFailSearch,
    QuranCancelled() => l.quranFailCancelled,
  };
}

/// The KFGQPC Hafs font, loaded from the downloaded package (never from the
/// network) for surah names and search results (§15 D107). The font file is
/// shipped unmodified, as its licence requires.
abstract final class QuranFont {
  /// The family registered by [load].
  static const family = 'KFGQPC Hafs';

  /// Registers the font of [installed]; `false` when the file is missing.
  static Future<bool> load(InstalledQuran installed) async {
    final file = File('${installed.directory}/fonts/kfgqpc-hafs-v30.ttf');
    if (!file.existsSync()) return false;
    final bytes = await file.readAsBytes();
    await (FontLoader(
      family,
    )..addFont(Future.value(ByteData.sublistView(bytes)))).load();
    return true;
  }
}
