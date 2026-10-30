import 'package:daily_muslim/features/athan/domain/voice_failure.dart';
import 'package:daily_muslim/features/athan/domain/voice_ports.dart';
import 'package:daily_muslim/features/quran/data/http_quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// [VoiceOrigin] over the Quran download's HTTPS client (§15 D107, D111):
/// `cdn.azenfelnas.app/<channel>/athan/voices/` only, no cookies, no
/// redirects, HTTP `Range` resume.
final class HttpVoiceOrigin implements VoiceOrigin {
  /// Voices on the CDN [channel].
  new cdn(String channel) : this.over(HttpQuranOrigin.cdn(channel, cdnPath));

  /// Voices on a loopback [port] (dev only, as the Quran download).
  new loopback(int port, String channel)
    : this.over(HttpQuranOrigin.loopback(port, channel, cdnPath));

  /// Voices read through [_files] (tests pass a fake).
  const new over(this._files);

  /// The voices directory under a channel.
  static const String cdnPath = 'athan/voices/';

  final QuranOrigin _files;

  @override
  Future<Result<void, VoiceFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async {
    final result = await _files.download(
      path,
      partPath,
      totalBytes: totalBytes,
      onBytes: onBytes,
      cancelled: cancelled,
    );
    return switch (result) {
      Ok() => const Result.ok(null),
      Err(:final failure) => Result.err(switch (failure) {
        QuranOffline() => const VoiceOffline(),
        QuranServerRefused(:final status) => VoiceServerRefused(status),
        QuranNoSpace(:final neededBytes) => VoiceNoSpace(
          neededBytes: neededBytes,
        ),
        QuranIntegrityFailed() => const VoiceIntegrityFailed(),
        QuranStorageFailed(:final detail) => VoiceStorageFailed(detail),
        QuranSearchUnavailable() => const VoiceStorageFailed('search'),
        QuranCancelled() => const VoiceCancelled(),
      }),
    };
  }
}
