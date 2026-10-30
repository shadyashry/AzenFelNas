import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/quran/application/download_quran_package.dart';
import 'package:daily_muslim/features/quran/data/bundled_quran_origin.dart';
import 'package:daily_muslim/features/quran/data/io_quran_package_disk.dart';
import 'package:daily_muslim/features/quran/data/quran_manifest_codec.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Assets in memory, with the `AssetManifest.bin` Flutter writes.
final class _Bundle extends AssetBundle {
  new(this.assets);

  final Map<String, List<int>> assets;

  @override
  Future<ByteData> load(String key) async {
    if (key == 'AssetManifest.bin') {
      return const StandardMessageCodec().encodeMessage(<String, Object>{
        for (final k in assets.keys) k: const <Object>[],
      })!;
    }
    final bytes = assets[key];
    if (bytes == null) throw FlutterError('Unable to load asset: "$key".');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

/// The CDN; a test fails if a bundled build calls it.
final class _Cdn implements QuranOrigin {
  int calls = 0;

  @override
  Future<Result<List<int>, QuranFailure>> manifest({
    required int maxBytes,
  }) async {
    calls++;
    return const Result.err(QuranOffline());
  }

  @override
  Future<Result<void, QuranFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async {
    calls++;
    return const Result.err(QuranOffline());
  }
}

final class _Index implements BuildSearchIndex {
  @override
  Future<Result<void, QuranFailure>> call(String directory) async => Result.ok(
    File('$directory/$searchIndexFileName').writeAsStringSync('ix'),
  );
}

final class _Space implements ReadFreeSpace {
  @override
  Future<int?> call(String directory) async => null;
}

/// A two-page package: its manifest and files.
({List<int> manifest, Map<String, List<int>> files}) _package() {
  final files = {
    'pages/001.webp': List<int>.generate(5000, (i) => i % 251),
    'pages/002.webp': List<int>.generate(7000, (i) => (i * 7) % 253),
    'quran.sqlite': utf8.encode('verses'),
  };
  final manifest = {
    'schemaVersion': 1,
    'packageId': 'test-pkg',
    'version': '1',
    'layoutId': 'test-layout',
    'edition': {
      'riwayah': 'hafs',
      'publisher': 'test',
      'printEdition': '1',
      'pageCount': 2,
      'suraCount': 1,
      'verseCount': 1,
      'sources': <Object>[],
    },
    'pageImage': {
      'format': 'webp-lossless',
      'width': 10,
      'height': 14,
      'pathPattern': 'pages/{page:03}.webp',
    },
    'files': [
      for (final MapEntry(:key, :value) in files.entries)
        {
          'path': key,
          'bytes': value.length,
          'sha256': '${sha256.convert(value)}',
        },
    ],
  };
  return (manifest: utf8.encode(jsonEncode(manifest)), files: files);
}

void main() {
  late Directory root;
  final pkg = _package();

  setUp(() => root = Directory.systemTemp.createTempSync('quran_bundle'));
  tearDown(() => root.deleteSync(recursive: true));

  Map<String, List<int>> bundled(Map<String, List<int>> files) => {
    'assets/quran/manifest.json': pkg.manifest,
    for (final MapEntry(:key, :value) in files.entries)
      'assets/quran/$key': value,
  };

  Future<List<QuranPackageStatus>> install(
    QuranOrigin origin,
    IoQuranPackageDisk disk,
  ) => DownloadQuranPackage(
    disk: disk,
    origin: origin,
    freeSpace: _Space(),
    buildIndex: _Index(),
    accept: QuranManifestCodec.decode,
    extraBytes: 0,
  )(DownloadCancel()).toList();

  IoQuranPackageDisk disk() => IoQuranPackageDisk(
    root,
    pinnedManifestSha256: '${sha256.convert(pkg.manifest)}',
  );

  test('REQ-QRN-015: the bundled copy installs with no network, every file '
      'verified and the index built', () async {
    final cdn = _Cdn();
    final origin = BundledQuranOrigin(_Bundle(bundled(pkg.files)), cdn);
    final d = disk();

    expect(await origin.available(), isTrue);
    final statuses = await install(origin, d);

    expect(statuses.last, isA<QuranReady>());
    expect(cdn.calls, 0);
    final active = await d.active();
    expect(await d.fullCheck(active!), isEmpty);
  });

  test('REQ-QRN-015: a bundled file that does not match the manifest is '
      'refused, never installed', () async {
    final files = {...pkg.files, 'pages/002.webp': List<int>.filled(7000, 0)};
    final origin = BundledQuranOrigin(_Bundle(bundled(files)), _Cdn());
    final d = disk();

    final statuses = await install(origin, d);

    expect(
      statuses.last,
      isA<QuranPaused>().having(
        (s) => s.failure,
        'failure',
        isA<QuranIntegrityFailed>(),
      ),
    );
    expect(await d.active(), isNull);
  });

  test(
    'REQ-QRN-015: a build without the copy downloads from the CDN',
    () async {
      final cdn = _Cdn();
      final origin = BundledQuranOrigin(_Bundle(const {}), cdn);

      expect(await origin.available(), isFalse);
      final result = await origin.manifest(maxBytes: 1 << 20);

      expect(result, isA<Err<List<int>, QuranFailure>>());
      expect(cdn.calls, 1);
    },
  );
}
