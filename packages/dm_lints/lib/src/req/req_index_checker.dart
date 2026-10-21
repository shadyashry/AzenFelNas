import 'dart:io';

import 'package:dm_lints/src/check_report.dart';
import 'package:dm_lints/src/finding.dart';
import 'package:dm_lints/src/source_files.dart';
import 'package:path/path.dart' as p;

/// Checks that every `REQ-*` ID used in the repository is defined in
/// `DESIGN.md` Appendix F, and that Appendix F defines each ID once
/// (DESIGN.md §0.1 item 3, §12 "REQ index").
final class ReqIndexChecker {
  /// Creates a checker.
  const new();

  /// Extensions of the text files that are scanned for IDs.
  static const Set<String> scannedExtensions = {
    '.dart',
    '.go',
    '.json',
    '.kt',
    '.kts',
    '.md',
    '.py',
    '.sh',
    '.swift',
    '.toml',
    '.yaml',
    '.yml',
  };

  static final RegExp _reqId = RegExp(r'REQ-[A-Z]+-\d{3}');
  static final RegExp _definition = RegExp(r'^- `(REQ-[A-Z]+-\d{3})`');

  /// Checks the repository rooted at [root].
  CheckReport check(Directory root) {
    final design = File(p.join(root.path, 'DESIGN.md'));
    if (!design.existsSync()) {
      return const CheckReport(
        filesChecked: 0,
        findings: [
          Finding(
            path: 'DESIGN.md',
            line: 0,
            rule: 'req-design-missing',
            message: 'DESIGN.md not found at the repository root',
          ),
        ],
      );
    }
    final findings = <Finding>[];
    final defined = _definedIds(design.readAsLinesSync(), findings);
    final files = filesBelow(
      root,
      scannedExtensions,
    ).where((f) => !p.equals(f.path, design.path)).toList();
    for (final file in files) {
      final List<String> lines;
      try {
        lines = file.readAsLinesSync();
      } on FileSystemException {
        continue; // Not UTF-8 text; it cannot cite a REQ ID.
      }
      for (var i = 0; i < lines.length; i++) {
        for (final match in _reqId.allMatches(lines[i])) {
          final id = match.group(0) ?? '';
          if (defined.contains(id)) continue;
          findings.add(
            Finding(
              path: relativePath(file, root),
              line: i + 1,
              rule: 'req-unknown',
              message: '$id is not defined in DESIGN.md Appendix F',
            ),
          );
        }
      }
    }
    return CheckReport(filesChecked: files.length + 1, findings: findings);
  }

  /// IDs defined in Appendix F; reports duplicates and an empty appendix.
  Set<String> _definedIds(List<String> lines, List<Finding> out) {
    final start = lines.indexWhere((l) => l.startsWith('## Appendix F'));
    final defined = <String>{};
    if (start < 0) {
      out.add(
        const Finding(
          path: 'DESIGN.md',
          line: 0,
          rule: 'req-appendix-missing',
          message: 'DESIGN.md has no "## Appendix F" section',
        ),
      );
      return defined;
    }
    for (var i = start + 1; i < lines.length; i++) {
      if (lines[i].startsWith('## ')) break;
      final id = _definition.firstMatch(lines[i])?.group(1);
      if (id == null) continue;
      if (!defined.add(id)) {
        out.add(
          Finding(
            path: 'DESIGN.md',
            line: i + 1,
            rule: 'req-duplicate',
            message: '$id is defined more than once in Appendix F',
          ),
        );
      }
    }
    if (defined.isEmpty) {
      out.add(
        Finding(
          path: 'DESIGN.md',
          line: start + 1,
          rule: 'req-appendix-empty',
          message: 'Appendix F defines no REQ IDs',
        ),
      );
    }
    return defined;
  }
}
