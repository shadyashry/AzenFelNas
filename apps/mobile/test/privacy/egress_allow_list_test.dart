import 'dart:convert';
import 'dart:io';

import 'package:daily_muslim/features/packages/data/http_cdn_channel.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter_test/flutter_test.dart';

/// The only hosts the app may contact (REQ-PRIV-006, ADR-017).
const _allowedHosts = {'cdn.dailymuslim.app', 'api.dailymuslim.app'};

/// Shipped source trees, relative to `apps/mobile/` (tests excluded).
const _sourceRoots = [
  'lib',
  'android/app/src/main',
  'android/athan-core/src/main',
  'ios/Runner',
  'ios/AthanKit/Sources',
  '../../packages/dm_civil_time/lib',
  '../../packages/dm_contracts/lib',
  '../../packages/dm_core_types/lib',
  '../../packages/dm_hijri/lib',
  '../../packages/dm_packages/lib',
  '../../packages/dm_ui/lib',
  '../../packages/geo_salah_core/lib',
  '../../packages/geo_salah_profiles/lib',
];

const _sourceExtensions = {
  '.dart',
  '.kt',
  '.kts',
  '.java',
  '.swift',
  '.m',
  '.h',
  '.xml',
  '.plist',
  '.xcprivacy',
  '.entitlements',
  '.json',
};

/// Files allowed to open a network connection: the one CDN adapter.
const _networkAdapters = {'lib/features/packages/data/http_cdn_channel.dart'};

/// APIs that open a connection, in Dart, Kotlin/Java and Swift.
final _networkApi = RegExp(
  r'\bHttpClient\b|\bSocket\.connect|\bRawSocket\b|\bWebSocket\b|'
  r'\bSecureSocket\b|package:http/|package:dio/|package:web_socket|'
  r'\bURLSession\b|\bNWConnection\b|\bHttpURLConnection\b|\bokhttp3\b|'
  r'\bopenConnection\(',
);

final _url = RegExp(r'\b(?:https?|wss?)://([A-Za-z0-9.-]+)');

/// A line that cannot reach the network: a comment, an XML namespace or a
/// DTD reference.
bool _inert(String line) {
  final t = line.trimLeft();
  return t.startsWith('//') ||
      t.startsWith('*') ||
      t.startsWith('/*') ||
      t.startsWith('<!DOCTYPE') ||
      RegExp(r'xmlns(:\w+)?="https?://').hasMatch(line);
}

final _blockComment = RegExp(r'<!--[\s\S]*?-->|/\*[\s\S]*?\*/');

/// The lines of [file] with block comments blanked, line numbers kept.
List<String> _codeLines(File file) => file
    .readAsStringSync()
    .replaceAllMapped(
      _blockComment,
      (m) => '\n' * '\n'.allMatches(m.group(0) ?? '').length,
    )
    .split('\n');

Iterable<File> _sources() sync* {
  for (final root in _sourceRoots) {
    final dir = Directory(root);
    expect(dir.existsSync(), isTrue, reason: '$root is missing');
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final path = entity.path;
      if (path.contains('/.build/') || path.contains('/Spike/')) continue;
      final dot = path.lastIndexOf('.');
      if (dot < 0 || !_sourceExtensions.contains(path.substring(dot))) {
        continue;
      }
      yield entity;
    }
  }
}

void main() {
  test('REQ-PRIV-006 every URL in shipped code names an allowed host', () {
    final offenders = <String>[];
    var files = 0;
    for (final file in _sources()) {
      files++;
      final lines = _codeLines(file);
      for (var i = 0; i < lines.length; i++) {
        if (_inert(lines[i])) continue;
        for (final m in _url.allMatches(lines[i])) {
          final host = m.group(1) ?? '';
          if (!_allowedHosts.contains(host) && host != '127.0.0.1') {
            offenders.add('${file.path}:${i + 1} $host');
          }
        }
      }
    }

    expect(files, greaterThan(300));
    expect(offenders, isEmpty);
  });

  test('REQ-PRIV-006 only the CDN adapter opens network connections', () {
    final offenders = <String>[
      for (final file in _sources())
        // Forward slashes, so the allow-list also matches on Windows.
        if (!_networkAdapters.contains(file.path.replaceAll(r'\', '/')) &&
            _codeLines(file).any(
              (line) => !_inert(line) && _networkApi.hasMatch(line),
            ))
          file.path,
    ];

    expect(offenders, isEmpty);
  });

  test('REQ-PRIV-006 no analytics, crash, ads or HTTP SDK is a runtime '
      'dependency of the app', () {
    final graph = jsonDecode(
      File('../../.dart_tool/package_graph.json').readAsStringSync(),
    );
    final packages = switch (graph) {
      {'packages': final List<Object?> p} => p,
      _ => const <Object?>[],
    };
    final deps = <String, List<String>>{
      for (final package in packages)
        if (package case {
          'name': final String name,
          'dependencies': final List<Object?> d,
        })
          name: [for (final n in d) '$n'],
    };
    // Desktop and web plugin implementations (e.g. geolocator_linux, which
    // pulls package_info_plus and http) are registered only for their own
    // platform, so the Android and iOS binaries never contain them.
    final desktopOrWeb = RegExp(r'_(linux|windows|macos|web)$');
    final runtime = <String>{};
    final queue = ['daily_muslim'];
    while (queue.isNotEmpty) {
      final name = queue.removeLast();
      if (desktopOrWeb.hasMatch(name)) continue;
      if (runtime.add(name)) queue.addAll(deps[name] ?? const []);
    }
    final banned = RegExp(
      r'^(firebase\w*|\w*analytics\w*|\w*crashlytics\w*|sentry\w*|'
      r'google_mobile_ads|\w*_ads|amplitude\w*|mixpanel\w*|segment\w*|'
      r'appsflyer\w*|adjust\w*|http|dio|web_socket_channel|'
      r'device_info_plus|advertising_id\w*)$',
    );

    expect(runtime, contains('geolocator'));
    expect(runtime.where(banned.hasMatch), isEmpty);
  });

  test('REQ-PRIV-006 the CDN channel connects to cdn.dailymuslim.app over '
      'HTTPS and nowhere else', () async {
    final attempts = <Uri>[];
    final client = HttpClient()
      ..connectionFactory = (uri, proxyHost, proxyPort) {
        attempts.add(uri);
        throw const SocketException('egress blocked in tests');
      };
    final channel = HttpCdnChannel('lab', client);

    await channel.metadata(MetadataRole.timestamp, maxBytes: 1024);
    await channel.package(
      PackageType.gazetteer,
      '2026.10.1',
      'ab' * 32,
      maxBytes: 1024,
    );

    expect(attempts, hasLength(2));
    for (final uri in attempts) {
      expect(uri.scheme, 'https');
      expect(uri.host, 'cdn.dailymuslim.app');
    }
    client.close(force: true);
  });

  test('REQ-PRIV-006 cleartext traffic and arbitrary loads are never '
      'enabled', () {
    for (final path in [
      'android/app/src/main/AndroidManifest.xml',
      'android/athan-core/src/main/AndroidManifest.xml',
    ]) {
      final manifest = File(path).readAsStringSync();
      expect(manifest, isNot(contains('usesCleartextTraffic="true"')));
      expect(manifest, isNot(contains('networkSecurityConfig')));
    }
    final plist = File('ios/Runner/Info.plist').readAsStringSync();
    expect(plist, isNot(contains('NSAllowsArbitraryLoads')));
    expect(plist, isNot(contains('NSExceptionDomains')));
  });
}
