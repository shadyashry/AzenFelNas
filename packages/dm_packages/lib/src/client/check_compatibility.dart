import 'package:dm_core_types/dm_core_types.dart';
import 'package:dm_packages/src/client/app_compat.dart';
import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/tuf/tuf_target_custom.dart';
import 'package:dm_packages/src/verify/package_failure.dart';

/// Checks a target's `compat` and `schemaVersion` against the running build
/// before it is downloaded or activated (REQ-PKG-006). Pure.
final class CheckCompatibility {
  /// The use case for the build described by [_app].
  const new(this._app);

  final AppCompat _app;

  /// Ok when this build can use a [type] target with [custom]; otherwise
  /// `PKG_INCOMPATIBLE` naming the first unmet requirement.
  Result<void, PackageFailure> call(PackageType type, TufTargetCustom custom) {
    final supported = _app.schemaVersions[type];
    if (supported == null) {
      return Result.err(
        PackageFailure.incompatible('${type.wire} is not read by this build'),
      );
    }
    if (custom.schemaVersion > supported) {
      return Result.err(
        PackageFailure.incompatible(
          '${type.wire} schemaVersion ${custom.schemaVersion} > $supported',
        ),
      );
    }
    final (int, int, int) minApp;
    try {
      minApp = AppCompat.parseVersion(custom.compat.minApp);
    } on FormatException {
      return Result.err(
        PackageFailure.incompatible('minApp "${custom.compat.minApp}"'),
      );
    }
    if (_after(minApp, _app.appVersion)) {
      return Result.err(
        PackageFailure.incompatible(
          'needs app ${custom.compat.minApp} or later',
        ),
      );
    }
    if (custom.compat.minEngineSchema > _app.engineSchema) {
      return Result.err(
        PackageFailure.incompatible(
          'needs engine schema ${custom.compat.minEngineSchema}, '
          'this build has ${_app.engineSchema}',
        ),
      );
    }
    return const Result.ok(null);
  }

  static bool _after((int, int, int) a, (int, int, int) b) =>
      a.$1 != b.$1 ? a.$1 > b.$1 : (a.$2 != b.$2 ? a.$2 > b.$2 : a.$3 > b.$3);
}
