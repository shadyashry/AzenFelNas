import 'package:dm_lints/src/finding.dart';

/// Result of one repository check.
final class CheckReport {
  /// Creates a report covering [filesChecked] files.
  const new({required this.filesChecked, required this.findings});

  /// Number of files the check read.
  final int filesChecked;

  /// Every problem found; empty when the repository passes.
  final List<Finding> findings;

  /// Whether the check passed.
  bool get passed => findings.isEmpty;
}
