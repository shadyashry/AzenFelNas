import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:daily_muslim/features/quran/application/download_quran_package.dart';
import 'package:daily_muslim/features/quran/data/io_quran_package_disk.dart';
import 'package:daily_muslim/features/quran/data/quran_manifest_codec.dart';
import 'package:daily_muslim/features/quran/domain/build_search_index.dart';
import 'package:daily_muslim/features/quran/domain/download_cancel.dart';
import 'package:daily_muslim/features/quran/domain/quran_failure.dart';
import 'package:daily_muslim/features/quran/domain/quran_origin.dart';
import 'package:daily_muslim/features/quran/domain/quran_package_status.dart';
import 'package:dm_core_types/dm_core_types.dart';
import 'package:flutter_test/flutter_test.dart';

/// A package of three small files under [version].
({List<int> manifest, Map<String, List<int>> files}) _package(String version) {
  final files = {
    'pages/001.webp': List<int>.generate(5000, (i) => i % 251),
    'pages/002.webp': List<int>.generate(7000, (i) => (i * 7) % 253),
    'quran.sqlite': utf8.encode('verses of $version'),
  };
  final manifest = {
    'schemaVersion': 1,
    'packageId': 'test-pkg',
    'version': version,
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

/// The CDN in memory: resumes from the bytes already in a part file and
/// records every request; can lose the connection, corrupt a file, or let
/// the test cancel after some files.
final class _FakeOrigin implements QuranOrigin {
  new(this.manifestBytes, this.files);

  final List<int> manifestBytes;
  final Map<String, List<int>> files;
  final requests = <(String, int)>[];
  String? corrupt;
  int? offlineAfter;
  void Function()? onFileStart;

  @override
  Future<Result<List<int>, QuranFailure>> manifest({
    required int maxBytes,
  }) async => Result.ok(manifestBytes);

  @override
  Future<Result<void, QuranFailure>> download(
    String path,
    String partPath, {
    required int totalBytes,
    required void Function(int bytes) onBytes,
    required bool Function() cancelled,
  }) async {
    if (offlineAfter case final n? when requests.length >= n) {
      return const Result.err(QuranOffline());
    }
    onFileStart?.call();
    final part = File(partPath);
    await part.parent.create(recursive: true);
    final from = part.existsSync() ? part.lengthSync() : 0;
    requests.add((path, from));
    final bytes = [...?files[path]];
    if (path == corrupt) bytes[0] ^= 0xFF;
    // Half a file, then a cancel check, then the rest.
    final half = from + (bytes.length - from) ~/ 2;
    part.writeAsBytesSync(bytes.sublist(from, half), mode: FileMode.append);
    onBytes(half - from);
    if (cancelled()) return const Result.err(QuranCancelled());
    part.writeAsBytesSync(bytes.sublist(half), mode: FileMode.append);
    onBytes(bytes.length - half);
    return const Result.ok(null);
  }
}

final class _Index implements BuildSearchIndex {
  bool fail = false;

  @override
  Future<Result<void, QuranFailure>> call(String directory) async => fail
      ? const Result.err(QuranSearchUnavailable())
      : Result.ok(
          File('$directory/$searchIndexFileName').writeAsStringSync('ix'),
        );
}

final class _Space implements ReadFreeSpace {
  new(this.bytes);

  final int? bytes;

  @override
  Future<int?> call(String directory) async => bytes;
}

void main() {
  late Directory root;
  final pkg = _package('1');

  setUp(() => root = Directory.systemTemp.createTempSync('quran_dl'));
  tearDown(() => root.deleteSync(recursive: true));

  IoQuranPackageDisk disk(List<int> manifest) => IoQuranPackageDisk(
    root,
    pinnedManifestSha256: '${sha256.convert(manifest)}',
  );

  DownloadQuranPackage download(
    IoQuranPackageDisk disk,
    _FakeOrigin origin, {
    int? free,
    _Index? index,
  }) => DownloadQuranPackage(
    disk: disk,
    origin: origin,
    freeSpace: _Space(free),
    buildIndex: index ?? _Index(),
    accept: QuranManifestCodec.decode,
    extraBytes: 0,
  );

  test(
    'REQ-QRN-010: every file verified, the index built, then ready',
    () async {
      final d = disk(pkg.manifest);
      final origin = _FakeOrigin(pkg.manifest, pkg.files);

      final statuses = await download(d, origin)(DownloadCancel()).toList();

      expect(
        switch (statuses.last) {
          QuranPaused(failure: QuranStorageFailed(:final detail)) => detail,
          QuranPaused(:final failure) => '$failure',
          _ => 'ready',
        },
        'ready',
      );
      final active = await d.active();
      expect(active?.manifest.version, '1');
      expect(await d.fullCheck(active!), isEmpty);
      expect(
        File('${active.directory}/$searchIndexFileName').existsSync(),
        isTrue,
      );
      expect(await d.staging(), isNull);
    },
  );

  test(
    'REQ-QRN-012: a cancelled download resumes from the bytes it kept',
    () async {
      final d = disk(pkg.manifest);
      final origin = _FakeOrigin(pkg.manifest, pkg.files);
      final cancel = DownloadCancel();
      origin.onFileStart = () {
        if (origin.requests.length == 1) cancel.cancel();
      };

      final first = await download(d, origin)(cancel).toList();
      origin.onFileStart = null;
      final second = await download(d, origin)(DownloadCancel()).toList();

      expect(first.last, isA<QuranPaused>());
      expect((first.last as QuranPaused).failure, const QuranCancelled());
      expect(second.last, isA<QuranReady>());
      // pages/002 was cut at its half, then resumed from there.
      expect(origin.requests.where((r) => r.$1 == 'pages/002.webp'), [
        ('pages/002.webp', 0),
        ('pages/002.webp', 3500),
      ]);
    },
  );

  test('REQ-QRN-012: a lost connection pauses, and verified files are not '
      'fetched again', () async {
    final d = disk(pkg.manifest);
    final origin = _FakeOrigin(pkg.manifest, pkg.files)..offlineAfter = 1;

    final first = await download(d, origin)(DownloadCancel()).toList();
    origin.offlineAfter = null;
    final second = await download(d, origin)(DownloadCancel()).toList();

    expect((first.last as QuranPaused).failure, const QuranOffline());
    expect(second.last, isA<QuranReady>());
    expect(origin.requests.map((r) => r.$1).toList(), [
      'pages/001.webp',
      'pages/002.webp',
      'quran.sqlite',
    ]);
  });

  test('REQ-QRN-011: a file that does not match the manifest is discarded '
      'and nothing is activated', () async {
    final d = disk(pkg.manifest);
    final origin = _FakeOrigin(pkg.manifest, pkg.files)
      ..corrupt = 'pages/002.webp';

    final statuses = await download(d, origin)(DownloadCancel()).toList();

    expect(
      (statuses.last as QuranPaused).failure,
      const QuranIntegrityFailed('pages/002.webp'),
    );
    expect(
      origin.requests.where((r) => r.$1 == 'pages/002.webp'),
      hasLength(2),
    );
    expect(await d.active(), isNull);
    final staged = await d.staging();
    expect(staged?.verified, {'pages/001.webp'});
    expect(staged?.partialBytes, isEmpty);
  });

  test(
    'REQ-QRN-011: a manifest other than the pinned one is refused',
    () async {
      final other = _package('2');
      final d = disk(pkg.manifest);
      final origin = _FakeOrigin(other.manifest, other.files);

      final statuses = await DownloadQuranPackage(
        disk: d,
        origin: origin,
        freeSpace: _Space(null),
        buildIndex: _Index(),
        accept: QuranManifestCodec.acceptPinned,
      )(DownloadCancel()).toList();

      expect(
        (statuses.last as QuranNotInstalled).failure,
        const QuranIntegrityFailed('manifest.json'),
      );
      expect(origin.requests, isEmpty);
    },
  );

  test('REQ-QRN-010: too little free space stops before any file', () async {
    final d = disk(pkg.manifest);
    final origin = _FakeOrigin(pkg.manifest, pkg.files);

    final statuses = await download(d, origin, free: 100)(DownloadCancel())
        .toList();

    expect((statuses.last as QuranPaused).failure, isA<QuranNoSpace>());
    expect(origin.requests, isEmpty);
  });

  test('REQ-QRN-010: no search index, no ready package', () async {
    final d = disk(pkg.manifest);
    final origin = _FakeOrigin(pkg.manifest, pkg.files);

    final statuses = await download(d, origin, index: _Index()..fail = true)(
      DownloadCancel(),
    ).toList();

    expect(
      (statuses.last as QuranPaused).failure,
      const QuranSearchUnavailable(),
    );
    expect(await d.active(), isNull);
  });

  test('REQ-QRN-014: the installed package stays readable until its '
      'replacement is verified, then the old one is removed', () async {
    final old = disk(pkg.manifest);
    await download(old, _FakeOrigin(pkg.manifest, pkg.files))(DownloadCancel())
        .drain<void>();
    final next = _package('2');
    final d = disk(next.manifest);
    final origin = _FakeOrigin(next.manifest, next.files)
      ..corrupt = 'quran.sqlite';

    final failed = await download(d, origin)(DownloadCancel()).toList();
    final during = await d.active();
    final duringCheck = await d.fullCheck(during!);
    origin.corrupt = null;
    final done = await download(d, origin)(DownloadCancel()).toList();

    expect(failed.last, isA<QuranPaused>());
    expect((failed.last as QuranPaused).current?.manifest.version, '1');
    expect(during.manifest.version, '1');
    expect(duringCheck, isEmpty);
    expect(done.last, isA<QuranReady>());
    expect((await d.active())?.manifest.version, '2');
    expect(
      (await d.active())?.directory,
      isNot(during.directory),
    );
    expect(Directory(during.directory).existsSync(), isFalse);
  });

  test(
    'REQ-QRN-013: a missing file is found at start and blocks reading',
    () async {
      final d = disk(pkg.manifest);
      await download(d, _FakeOrigin(pkg.manifest, pkg.files))(DownloadCancel())
          .drain<void>();
      final installed = await d.active();
      File('${installed!.directory}/pages/002.webp').deleteSync();
      File('${installed.directory}/pages/001.webp').writeAsBytesSync([1, 2, 3]);

      expect(await d.quickCheck(installed), [
        'pages/001.webp',
        'pages/002.webp',
      ]);
    },
  );
}
