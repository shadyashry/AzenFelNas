import 'package:dm_packages/src/client/package_file.dart';
import 'package:meta/meta.dart';

/// A verified package ready to activate: its catalog [file] and the
/// inflated [payload] that passed the type's schema check.
@immutable
final class StagedPackage {
  /// The staged package.
  const new({required this.file, required this.payload});

  /// The catalog entry (state `staged`).
  final PackageFile file;

  /// The payload bytes.
  final List<int> payload;

  @override
  String toString() => 'StagedPackage($file)';
}
