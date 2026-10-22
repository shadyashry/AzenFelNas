// The CDN adapter against a loopback HTTP server: paths of §9.1, the Date
// header sample (REQ-TIME-010), and PKG_NETWORK for every bad answer.
import 'dart:io';

import 'package:daily_muslim/features/packages/data/http_cdn_channel.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late HttpServer server;
  late HttpCdnChannel channel;
  final paths = <String>[];
  final date = DateTime.utc(2026, 10, 22, 12);

  setUp(() async {
    paths.clear();
    server = (await HttpServer.bind(InternetAddress.loopbackIPv4, 0))
      ..listen((request) async {
        paths.add(request.uri.path);
        final response = request.response;
        switch (request.uri.path) {
          case '/lab/metadata/timestamp.json':
            response.headers.date = date;
            response.write('{"signed":{}}');
          case '/lab/packages/tzdata/2026e/abc.dmpkg':
            response.add(List.filled(100, 7));
          default:
            response.statusCode = HttpStatus.notFound;
        }
        await response.close();
      });
    channel = HttpCdnChannel.loopback(server.port, 'lab', HttpClient());
  });
  tearDown(() => server.close(force: true));

  test('metadata comes from <channel>/metadata with the CDN Date '
      '(REQ-TIME-010)', () async {
    final result = await channel.metadata(
      MetadataRole.timestamp,
      maxBytes: 100,
    );

    expect(paths, ['/lab/metadata/timestamp.json']);
    expect(
      result,
      isA<Ok<FetchedFile, PackageFailure>>().having(
        (o) => o.value.serverDateUtcMs,
        'date',
        date.millisecondsSinceEpoch,
      ),
    );
  });

  test(
    'a package comes from <channel>/packages/<type>/<version>/<sha>.dmpkg',
    () async {
      final result = await channel.package(
        PackageType.tzdata,
        '2026e',
        'abc',
        maxBytes: 100,
      );

      expect(paths, ['/lab/packages/tzdata/2026e/abc.dmpkg']);
      expect(
        result,
        isA<Ok<FetchedFile, PackageFailure>>().having(
          (o) => o.value.bytes.length,
          'length',
          100,
        ),
      );
    },
  );

  final failures =
      <String, Future<Result<FetchedFile, PackageFailure>> Function()>{
        'HTTP 404': () => channel.metadata(MetadataRole.root, maxBytes: 100),
        'a body over the limit': () => channel.package(
          PackageType.tzdata,
          '2026e',
          'abc',
          maxBytes: 99,
        ),
      };
  for (final MapEntry(key: name, value: fetch) in failures.entries) {
    test('$name is PKG_NETWORK', () async {
      expect(
        await fetch(),
        isA<Err<FetchedFile, PackageFailure>>().having(
          (e) => e.failure.code,
          'code',
          FailureCode.pkgNetwork,
        ),
      );
    });
  }

  test('an unreachable server is PKG_NETWORK', () async {
    final port = server.port;
    await server.close(force: true);
    final closed = HttpCdnChannel.loopback(port, 'lab', HttpClient());

    final result = await closed.metadata(MetadataRole.root, maxBytes: 100);

    expect(result, isA<Err<FetchedFile, PackageFailure>>());
  });

  test('only the four channels of §9.1 are accepted', () {
    expect(() => HttpCdnChannel('staging', HttpClient()), throwsArgumentError);
  });
}
