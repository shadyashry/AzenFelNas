import 'package:dm_packages/src/client/package_type.dart';
import 'package:meta/meta.dart';

/// What the running build can use, checked against a target's `compat` and
/// `schemaVersion` before download and activation (REQ-PKG-006).
@immutable
final class AppCompat {
  /// The build at [appVersion] (`major.minor.patch`) with engine profile
  /// schema [engineSchema], reading each type up to its [schemaVersions]
  /// entry. A type missing from [schemaVersions] is not read by this build.
  /// Throws [FormatException] when [appVersion] is not `\d+.\d+.\d+`.
  new({
    required String appVersion,
    required this.engineSchema,
    required Map<PackageType, int> schemaVersions,
  }) : appVersion = parseVersion(appVersion),
       schemaVersions = Map.unmodifiable(schemaVersions);

  /// `(major, minor, patch)` of the running build.
  final (int, int, int) appVersion;

  /// The highest `minEngineSchema` this build accepts.
  final int engineSchema;

  /// The highest payload `schemaVersion` this build reads, per type.
  final Map<PackageType, int> schemaVersions;

  /// `(major, minor, patch)` of [text]; throws [FormatException] otherwise.
  static (int, int, int) parseVersion(String text) {
    final match = _semver.firstMatch(text);
    if (match == null) throw FormatException('not major.minor.patch', text);
    int part(int i) => int.parse(match.group(i) ?? '');
    return (part(1), part(2), part(3));
  }

  static final RegExp _semver = RegExp(r'^(\d{1,9})\.(\d{1,9})\.(\d{1,9})$');
}
