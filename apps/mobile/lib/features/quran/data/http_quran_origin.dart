import 'dart:async';
import 'dart:io';

import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// [QuranOrigin] over HTTPS to `cdn.azenfelnas.app` only (§0.2, §15 D106),
/// with its own [HttpClient]: no cookies, no identifiers, no redirects, a
/// 30 s limit per read. A partial file resumes with an HTTP `Range`
/// request; a server that ignores the range restarts the file.
final class HttpQuranOrigin implements QuranOrigin {
  /// The package at [packagePath] (e.g. `quran/<id>/<version>/`) on the
  /// CDN [channel] (`dev`, `lab`, `beta` or `production`).
  new cdn(String channel, String packagePath)
    : this._(
        Uri.https('cdn.azenfelnas.app', '/${_checked(channel)}/$packagePath'),
        HttpClient(),
      );

  /// `cdn` with the given [client], so a test can watch its connections.
  @visibleForTesting
  new cdnWith(String channel, String packagePath, HttpClient client)
    : this._(
        Uri.https('cdn.azenfelnas.app', '/${_checked(channel)}/$packagePath'),
        client,
      );

  /// A plain-HTTP server on the loopback [port], for adapter tests and the
  /// dev-channel emulator check (`adb reverse`). `app/di.dart` allows it
  /// only on the dev channel, so beta and production builds never use it.
  new loopback(int port, String channel, String packagePath)
    : this._(
        Uri.http('127.0.0.1:$port', '/${_checked(channel)}/$packagePath'),
        HttpClient(),
      );

  new _(this._base, this._client);

  final Uri _base;
  final HttpClient _client;

  /// The longest wait for a response or the next chunk.
  static const Duration timeout = Duration(seconds: 30);

  @override
  Future<Result<List<int>, QuranFailure>> manifest({
    required int maxBytes,
  }) async {
    try {
      final response = await _get('manifest.json', from: 0);
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        return Result.err(QuranServerRefused(response.statusCode));
      }
      final body = <int>[];
      await for (final chunk in response.timeout(timeout)) {
        body.addAll(chunk);
        if (body.length > maxBytes) {
          return Result.err(QuranServerRefused(response.statusCode));
        }
      }
      return Result.ok(body);
    } on IOException {
      return const Result.err(QuranOffline());
    } on TimeoutException {
      return const Result.err(QuranOffline());
    }
  }

  @override
  Future<Result<void, QuranFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async {
    final part = File(partPath);
    IOSink? sink;
    try {
      await part.parent.create(recursive: true);
      var from = part.existsSync() ? part.lengthSync() : 0;
      if (from >= totalBytes) return const Result.ok(null);
      final response = await _get(path, from: from);
      final status = response.statusCode;
      if (status == HttpStatus.ok && from > 0) {
        // The server sent the whole file: start the part again.
        onBytes(-from);
        from = 0;
      } else if (status != HttpStatus.ok &&
          status != HttpStatus.partialContent) {
        await response.drain<void>();
        return Result.err(QuranServerRefused(status));
      }
      sink = part.openWrite(mode: from == 0 ? FileMode.write : FileMode.append);
      var written = from;
      await for (final chunk in response.timeout(timeout)) {
        if (cancelled()) return const Result.err(QuranCancelled());
        written += chunk.length;
        if (written > totalBytes) {
          return Result.err(QuranServerRefused(status));
        }
        sink.add(chunk);
        onBytes(chunk.length);
      }
      return const Result.ok(null);
    } on FileSystemException catch (error) {
      final code = error.osError?.errorCode;
      if (code == 28 || code == 112 || code == 39) {
        return Result.err(QuranNoSpace(neededBytes: totalBytes));
      }
      return Result.err(QuranStorageFailed(error.message));
    } on IOException {
      return const Result.err(QuranOffline());
    } on TimeoutException {
      return const Result.err(QuranOffline());
    } finally {
      await sink?.flush();
      await sink?.close();
    }
  }

  Future<HttpClientResponse> _get(String path, {required int from}) async {
    final request = await _client.getUrl(_base.resolve(path)).timeout(timeout);
    request.followRedirects = false;
    if (from > 0) request.headers.set(HttpHeaders.rangeHeader, 'bytes=$from-');
    return await request.close().timeout(timeout);
  }

  static String _checked(String channel) => switch (channel) {
    'dev' || 'lab' || 'beta' || 'production' => channel,
    _ => throw ArgumentError.value(channel, 'channel', 'unknown channel'),
  };
}
