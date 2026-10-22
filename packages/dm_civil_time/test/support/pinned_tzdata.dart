import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dm_civil_time/dm_civil_time.dart';
import 'package:dm_core_types/dm_core_types.dart';

/// The pinned `tzdata` build committed under `data/tzdata/<version>/` by the
/// data pipeline (§15 D66). Tests run from the package directory.
final class PinnedTzdata {
  const new _(this.version, this.directory);

  /// The single pinned version; fails when there is not exactly one.
  factory load() {
    final versions = Directory('data/tzdata')
        .listSync()
        .whereType<Directory>()
        .toList();
    if (versions.length != 1) {
      throw StateError('expected one pinned tzdata, got ${versions.length}');
    }
    final directory = versions.single;
    return PinnedTzdata._(
      directory.uri.pathSegments.lastWhere((s) => s != ''),
      directory,
    );
  }

  /// IANA release name, e.g. `2026e`.
  final String version;

  /// `data/tzdata/<version>`.
  final Directory directory;

  /// The `.tzf` payload bytes.
  Uint8List get payload =>
      File('${directory.path}/tzdata.tzf').readAsBytesSync();

  /// The payload read by [ReadTzfDatabase]; fails the test when invalid.
  PinnedTzDatabase get database => switch (const ReadTzfDatabase()(
    payload,
    version: version,
  )) {
    Ok(:final value) => value,
    Err(:final failure) => throw StateError('pinned tzdata: $failure'),
  };

  /// The decoded `dst_oracle.json` (schema `tz_transition_oracle.v1`).
  Map<String, Object?> get oracle => switch (jsonDecode(
    File('${directory.path}/dst_oracle.json').readAsStringSync(),
  )) {
    final Map<String, Object?> json => json,
    _ => throw const FormatException('oracle is not an object'),
  };
}
