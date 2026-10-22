import 'dart:convert';

import 'package:daily_muslim/features/settings/domain/attribution.dart';
import 'package:daily_muslim/features/settings/domain/read_attributions.dart';

/// [ReadAttributions] from `assets/legal/attributions.v1.json`.
final class AssetAttributions implements ReadAttributions {
  /// The reader over [_load], which returns the asset's text.
  const new(this._load);

  /// The asset key.
  static const asset = 'assets/legal/attributions.v1.json';

  final Future<String> Function(String key) _load;

  @override
  Future<List<Attribution>> call() async => decode(await _load(asset));

  /// The entries of [json]; throws `FormatException` on another shape.
  static List<Attribution> decode(String json) => switch (jsonDecode(json)) {
    {'schemaVersion': 1, 'sources': final List<Object?> sources} => [
      for (final s in sources)
        switch (s) {
          {
            'package': final String package,
            'name': final String name,
            'licence': final String licence,
            'notice': final String notice,
          } =>
            Attribution(
              package: package,
              name: name,
              licence: licence,
              notice: notice,
            ),
          _ => throw const FormatException('attribution entry'),
        },
    ],
    _ => throw const FormatException('attributions.v1'),
  };
}
