import 'package:meta/meta.dart';

/// Which Athan a downloadable voice is, as its source states it (§15 D111).
enum VoiceDesignation {
  /// The Athan of every prayer.
  standard,

  /// The Fajr Athan (with «الصلاة خير من النوم»); offered for Fajr only
  /// (REQ-ALM-052).
  fajr,
}

/// Whether the whole recording has been listened to and accepted (§15 D111).
enum VoiceReview {
  /// Not yet: the voice is offered on `dev` and `lab` only (REQ-ALM-050).
  pending,

  /// Listened to in full: offered on every channel.
  passed,
}

/// Who made a recording and under which licence, as its source states it
/// (§15 D111); shown beside the voice and on the licences page.
@immutable
final class VoiceCredit {
  /// The credit.
  const new({
    required this.creator,
    required this.sourcePage,
    required this.licence,
    required this.licenceUrl,
    required this.changes,
  });

  /// The author the source names, never assumed to be the muezzin.
  final String creator;

  /// The page the recording was taken from.
  final String sourcePage;

  /// SPDX id of the licence, e.g. `CC-BY-3.0`.
  final String licence;

  /// The licence deed.
  final String licenceUrl;

  /// What was changed from the source (the licence's notice of changes).
  final String changes;
}

/// One downloadable Athan recording of the voice catalog (§15 D111): pinned
/// by size and SHA-256, so only those exact bytes are ever played.
@immutable
final class AthanVoice {
  /// The voice.
  const new({
    required this.soundId,
    required this.nameEn,
    required this.nameAr,
    required this.designation,
    required this.review,
    required this.path,
    required this.bytes,
    required this.sha256,
    required this.durationMs,
    required this.credit,
  });

  /// The plan's `soundId` (`^[a-z0-9_]+$`); also the file name on disk.
  final String soundId;

  /// The English name.
  final String nameEn;

  /// The Arabic name.
  final String nameAr;

  /// Standard or Fajr Athan.
  final VoiceDesignation designation;

  /// Whether it has been listened to in full.
  final VoiceReview review;

  /// Path of the file under the CDN's voices directory.
  final String path;

  /// Size of the file.
  final int bytes;

  /// Lowercase hex SHA-256 of the file.
  final String sha256;

  /// Playing time.
  final int durationMs;

  /// Source and licence.
  final VoiceCredit credit;

  /// The name in [languageCode] (`ar` or English).
  String name(String languageCode) => languageCode == 'ar' ? nameAr : nameEn;

  /// Whether the voice may play for Fajr only.
  bool get fajrOnly => designation == VoiceDesignation.fajr;
}
