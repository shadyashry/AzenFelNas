import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/quran/data/bundled_quran_origin.dart';
import 'package:daily_muslim/features/quran/data/io_quran_package_disk.dart';
import 'package:daily_muslim/features/quran/data/quran_manifest_codec.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:daily_muslim/features/quran/presentation/quran_providers.dart';
import 'package:daily_muslim/features/settings/domain/app_settings.dart';
import 'package:daily_muslim/features/settings/domain/setting_key.dart';
import 'package:daily_muslim/features/settings/domain/settings_ports.dart';
import 'package:daily_muslim/features/settings/presentation/settings_providers.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

final class _Offline implements QuranOrigin {
  @override
  Future<Result<List<int>, QuranFailure>> manifest({
    required int maxBytes,
  }) async => const Result.err(QuranOffline());

  @override
  Future<Result<void, QuranFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async => const Result.err(QuranOffline());
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

/// Settings in memory, kept across containers like the database.
final class _Settings implements WatchSetting, WriteSetting {
  final values = <String, Object?>{};

  @override
  Stream<T> watch<T>(SettingKey<T> key) async* {
    yield (values.containsKey(key.wire) ? values[key.wire] : key.defaultValue)
        as T;
  }

  @override
  Future<void> write<T>(SettingKey<T> key, T value) async =>
      values[key.wire] = value;
}

void main() {
  late Directory root;
  final page = List<int>.generate(4000, (i) => i % 241);
  final manifest = utf8.encode(
    jsonEncode({
      'schemaVersion': 1,
      'packageId': 'test-pkg',
      'version': '1',
      'layoutId': 'test-layout',
      'edition': {
        'riwayah': 'hafs',
        'publisher': 'test',
        'printEdition': '1',
        'pageCount': 1,
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
        {
          'path': 'pages/001.webp',
          'bytes': page.length,
          'sha256': '${sha256.convert(page)}',
        },
      ],
    }),
  );
  final origin = BundledQuranOrigin(
    _Bundle({
      'assets/quran/manifest.json': manifest,
      'assets/quran/pages/001.webp': page,
    }),
    _Offline(),
  );

  setUp(() => root = Directory.systemTemp.createTempSync('quran_auto'));
  tearDown(() => root.deleteSync(recursive: true));

  ProviderContainer app(_Settings settings) => ProviderContainer(
    overrides: [
      quranPackageDiskProvider.overrideWithValue(
        IoQuranPackageDisk(
          root,
          pinnedManifestSha256: '${sha256.convert(manifest)}',
        ),
      ),
      quranOriginProvider.overrideWithValue(origin),
      quranBundleProvider.overrideWithValue(origin.available),
      acceptManifestProvider.overrideWithValue(QuranManifestCodec.decode),
      readFreeSpaceProvider.overrideWithValue(_Space()),
      buildSearchIndexProvider.overrideWithValue(_Index()),
      searchIndexIsCurrentProvider.overrideWithValue(
        (dir) => File('$dir/$searchIndexFileName').existsSync(),
      ),
      watchSettingProvider.overrideWithValue(settings),
      writeSettingProvider.overrideWithValue(settings),
    ],
  );

  /// Waits until the status is a [T].
  Future<void> until<T extends QuranPackageStatus>(ProviderContainer c) async {
    final done = Completer<void>();
    final sub = c.listen(quranPackageProvider, (_, next) {
      if (next is T && !done.isCompleted) done.complete();
    }, fireImmediately: true);
    await done.future.timeout(const Duration(seconds: 10));
    sub.close();
  }

  test('REQ-QRN-015: the Quran is ready at first start with no download '
      'and no tap', () async {
    final c = app(_Settings());
    addTearDown(c.dispose);

    await until<QuranReady>(c);
  });

  test('REQ-QRN-015: a Quran the reader removed stays removed at the next '
      'start until they install it', () async {
    final settings = _Settings();
    final first = app(settings);
    await until<QuranReady>(first);
    await first.read(quranPackageProvider.notifier).remove();
    first.dispose();

    final second = app(settings);
    addTearDown(second.dispose);
    await until<QuranNotInstalled>(second);
    // The start-up check and its decision have run; nothing was installed.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    expect(second.read(quranPackageProvider), isA<QuranNotInstalled>());
    expect(settings.values[AppSettings.quranRemoved.wire], isTrue);

    second.read(quranPackageProvider.notifier).download();
    await until<QuranReady>(second);
    expect(settings.values[AppSettings.quranRemoved.wire], isFalse);
  });
}
