import 'dart:io';

import 'package:dm_lints/dm_lints.dart';

/// `dart run dm_lints:req_index [root]` — exits 1 when an ID is unknown.
void main(List<String> args) {
  final root = Directory(args.isEmpty ? '.' : args.first);
  final report = const ReqIndexChecker().check(root);
  report.findings.forEach(stderr.writeln);
  stdout.writeln(
    'req_index: ${report.filesChecked} files checked, '
    '${report.findings.length} problem(s)',
  );
  exitCode = report.passed ? 0 : 1;
}
