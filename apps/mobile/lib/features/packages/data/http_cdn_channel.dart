import 'dart:async';
import 'dart:io';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:meta/meta.dart';

/// [FetchChannel] over HTTPS to `cdn.dailymuslim.app` only (§0.2, §9.1),
/// with `dart:io`'s [HttpClient]: no cookies, no identifiers, a 30 s limit
/// per request and the body cut at the caller's limit.
final class HttpCdnChannel implements FetchChannel {
  /// The [channel] (`dev`, `lab`, `beta` or `production`) on the CDN.
  /// Throws [ArgumentError] for another channel.
  new(String channel, this._client)
    : _base = Uri.https('cdn.dailymuslim.app', '/${_checked(channel)}/');

  /// A plain-HTTP server on the loopback [port], for adapter tests only.
  @visibleForTesting
  new loopback(int port, String channel, this._client)
    : _base = Uri.http('127.0.0.1:$port', '/${_checked(channel)}/');

  final Uri _base;
  final HttpClient _client;

  /// The longest a request may take.
  static const Duration timeout = Duration(seconds: 30);

  @override
  Future<Result<FetchedFile, PackageFailure>> metadata(
    MetadataRole role, {
    required int maxBytes,
  }) => _get('metadata/${role.name}.json', maxBytes);

  @override
  Future<Result<FetchedFile, PackageFailure>> package(
    PackageType type,
    String version,
    String sha256, {
    required int maxBytes,
  }) => _get('packages/${type.wire}/$version/$sha256.dmpkg', maxBytes);

  Future<Result<FetchedFile, PackageFailure>> _get(
    String path,
    int maxBytes,
  ) async {
    try {
      final request = await _client
          .getUrl(_base.resolve(path))
          .timeout(timeout);
      request.followRedirects = false;
      final response = await request.close().timeout(timeout);
      if (response.statusCode != HttpStatus.ok) {
        await response.drain<void>();
        return Result.err(
          PackageFailure.network('$path: HTTP ${response.statusCode}'),
        );
      }
      final body = <int>[];
      await for (final chunk in response.timeout(timeout)) {
        body.addAll(chunk);
        if (body.length > maxBytes) {
          return Result.err(
            PackageFailure.network('$path: more than $maxBytes bytes'),
          );
        }
      }
      return Result.ok(
        FetchedFile(body, serverDateUtcMs: _date(response.headers)),
      );
    } on IOException catch (error) {
      return Result.err(PackageFailure.network('$path: $error'));
    } on TimeoutException {
      return Result.err(PackageFailure.network('$path: timed out'));
    }
  }

  static int? _date(HttpHeaders headers) {
    final value = headers.value(HttpHeaders.dateHeader);
    if (value == null) return null;
    try {
      return HttpDate.parse(value).millisecondsSinceEpoch;
    } on HttpException {
      return null;
    }
  }

  static String _checked(String channel) => switch (channel) {
    'dev' || 'lab' || 'beta' || 'production' => channel,
    _ => throw ArgumentError.value(channel, 'channel', 'unknown channel'),
  };
}
