import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/radio/domain/radio_failure.dart';
import 'package:daily_muslim/features/radio/domain/radio_ports.dart';
import 'package:daily_muslim/features/radio/domain/radio_station.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:meta/meta.dart';

/// [RadioCatalogOrigin] over HTTPS to MP3Quran's documented radios endpoint
/// (§15 D122, REQ-PRIV-006): `www.mp3quran.net/api/v3/radios?language=…`,
/// no key (the provider documents none), no cookies, no identifiers.
///
/// A redirect is followed only to another HTTPS address on
/// [allowedHosts], at most twice. Each read waits at most [timeout]; an
/// answer over [maxBytes] is refused. A dropped connection, a timeout or a
/// 5xx answer is tried again after 1 s and then 3 s, no more.
final class HttpRadioCatalogOrigin implements RadioCatalogOrigin {
  /// The provider's endpoint over its own [HttpClient].
  new standard() : this.withClient(HttpClient());

  /// The endpoint over [_client], so a test can watch its connections.
  @visibleForTesting
  new withClient(this._client, {Duration Function(int attempt)? backoff})
    : _backoff = backoff ?? _defaultBackoff;

  final HttpClient _client;
  final Duration Function(int attempt) _backoff;

  /// The provider's hosts the request may reach.
  static const Set<String> allowedHosts = {'www.mp3quran.net', 'mp3quran.net'};

  /// The documented endpoint (the bare host redirects to `www`).
  static final Uri endpoint = Uri.https('www.mp3quran.net', '/api/v3/radios');

  /// The longest wait for a response or the next chunk.
  static const Duration timeout = Duration(seconds: 15);

  /// The largest answer read (the full list is about 40 KB).
  static const int maxBytes = 1 << 20;

  /// Tries after the first one.
  static const int retries = 2;

  static Duration _defaultBackoff(int attempt) =>
      Duration(seconds: attempt == 1 ? 1 : 3);

  @override
  Future<Result<Object?, RadioCatalogFailure>> radios(
    RadioLanguage language,
  ) async {
    final uri = endpoint.replace(
      queryParameters: {
        'language': switch (language) {
          RadioLanguage.ar => 'ar',
          RadioLanguage.en => 'eng',
        },
      },
    );
    var attempt = 0;
    while (true) {
      final result = await _once(uri);
      final again = switch (result) {
        Err(failure: RadioCatalogOffline() || RadioCatalogTimedOut()) => true,
        Err(failure: RadioCatalogRefused(:final status)) => status >= 500,
        _ => false,
      };
      if (!again || attempt >= retries) return result;
      attempt++;
      await Future<void>.delayed(_backoff(attempt));
    }
  }

  Future<Result<Object?, RadioCatalogFailure>> _once(Uri first) async {
    try {
      var uri = first;
      for (var hops = 0; ; hops++) {
        final request = await _client.getUrl(uri).timeout(timeout);
        request
          ..followRedirects = false
          ..persistentConnection = false;
        request.headers.set(HttpHeaders.acceptHeader, 'application/json');
        final response = await request.close().timeout(timeout);
        if (response.isRedirect) {
          await response.drain<void>();
          final location = response.headers.value(HttpHeaders.locationHeader);
          final next = location == null ? null : uri.resolve(location);
          if (hops >= 2 || next == null || !_allowed(next)) {
            return Result.err(RadioCatalogRefused(response.statusCode));
          }
          uri = next;
          continue;
        }
        if (response.statusCode != HttpStatus.ok) {
          await response.drain<void>();
          return Result.err(RadioCatalogRefused(response.statusCode));
        }
        final body = <int>[];
        await for (final chunk in response.timeout(timeout)) {
          body.addAll(chunk);
          if (body.length > maxBytes) {
            return const Result.err(RadioCatalogMalformed('too large'));
          }
        }
        try {
          return Result.ok(jsonDecode(utf8.decode(body)));
        } on FormatException {
          return const Result.err(RadioCatalogMalformed('not JSON'));
        }
      }
    } on TimeoutException {
      return const Result.err(RadioCatalogTimedOut());
    } on IOException {
      return const Result.err(RadioCatalogOffline());
    }
  }

  static bool _allowed(Uri uri) =>
      uri.scheme == 'https' &&
      allowedHosts.contains(uri.host.toLowerCase()) &&
      (!uri.hasPort || uri.port == 443);
}
