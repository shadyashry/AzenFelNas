import 'package:dm_packages/src/client/package_type.dart';
import 'package:dm_packages/src/tuf/tuf_target.dart';
import 'package:meta/meta.dart';

/// A verified target the client has chosen to install.
@immutable
final class TargetChoice {
  /// [type] [version] with its signed entry [target].
  const new({required this.type, required this.version, required this.target});

  /// The package type.
  final PackageType type;

  /// The version.
  final String version;

  /// The signed `targets.json` entry.
  final TufTarget target;

  /// The target name, `<type>/<version>`.
  String get name => '${type.wire}/$version';

  @override
  String toString() => 'TargetChoice($name)';
}
