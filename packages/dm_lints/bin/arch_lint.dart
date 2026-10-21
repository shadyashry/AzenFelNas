import 'dart:io';

import 'package:dm_lints/dm_lints.dart';

/// `dart run dm_lints:arch_lint [root]` — exits 1 on any violation.
void main(List<String> args) {
  final root = Directory(args.isEmpty ? '.' : args.first);
  final report = const ArchChecker(ArchRules.dailyMuslim).check(root);
  report.findings.forEach(stderr.writeln);
  stdout.writeln(
    'arch_lint: ${report.filesChecked} files checked, '
    '${report.findings.length} violation(s)',
  );
  exitCode = report.passed ? 0 : 1;
}
