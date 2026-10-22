import 'dart:convert';

import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/dm_packages.dart';

/// [ReadBundledSeeds] over the app's assets: the index
/// `assets/packages/seeds.json` lists each seed's type, version, schema
/// version, payload asset (relative to `assets/packages/`) and SHA-256
/// (REQ-PKG-003, §15 D74). [_load] reads one asset by key (`rootBundle` in
/// the app, files in tests); an index that does not parse lists nothing.
final class AssetBundledSeeds implements ReadBundledSeeds {
  /// The seeds read with [_load].
  const new(this._load);

  final Future<List<int>> Function(String key) _load;

  /// The index asset.
  static const String indexKey = 'assets/packages/seeds.json';

  @override
  Future<List<BundledSeed>> seeds() async => [
    for (final (seed, _) in await _index()) seed,
  ];

  @override
  Future<Result<List<int>, PackageFailure>> payload(BundledSeed seed) async {
    for (final (listed, key) in await _index()) {
      if (listed.type == seed.type && listed.version == seed.version) {
        try {
          return Result.ok(await _load(key));
        } on Exception catch (error) {
          return Result.err(PackageFailure.storage('$key: $error'));
        }
      }
    }
    return Result.err(PackageFailure.storage('$seed is not bundled'));
  }

  Future<List<(BundledSeed, String)>> _index() async {
    try {
      return switch (jsonDecode(utf8.decode(await _load(indexKey)))) {
        {'schemaVersion': 1, 'seeds': final List<Object?> seeds} => [
          for (final entry in seeds) ?_entry(entry),
        ],
        _ => const [],
      };
    } on Exception {
      return const []; // no index: no seeds, and the app still calculates
    }
  }

  static (BundledSeed, String)? _entry(Object? json) => switch (json) {
    {
      'type': final String type,
      'version': final String version,
      'schemaVersion': final int schemaVersion,
      'payload': final String payload,
      'sha256': final String sha256,
    } =>
      switch (PackageType.fromWire(type)) {
        final packageType? => (
          BundledSeed(
            type: packageType,
            version: version,
            schemaVersion: schemaVersion,
            sha256: sha256,
          ),
          'assets/packages/$payload',
        ),
        null => null,
      },
    _ => null,
  };
}
