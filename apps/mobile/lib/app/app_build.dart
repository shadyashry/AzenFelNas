import 'package:dm_packages/dm_packages.dart';

/// Facts about this build that the package client checks `compat` against
/// (§10.3). [version] equals `pubspec.yaml` (a test keeps them equal).
abstract final class AppBuild {
  /// The app version, `major.minor.patch`.
  static const version = '0.1.0';

  /// The prayer-profile schema the engine reads (`minEngineSchema` gate).
  static const engineSchema = 1;

  /// The compatibility the client checks: only types with a payload reader
  /// in `PackagePayloadChecks` are listed.
  static final compat = AppCompat(
    appVersion: version,
    engineSchema: engineSchema,
    schemaVersions: const {PackageType.gazetteer: 1},
  );
}
