import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:path/path.dart' as p;

/// Directory names never descended into by repository checks.
const Set<String> ignoredDirectoryNames = {
  '.dart_tool',
  '.git',
  '.gradle',
  '.idea',
  '.mypy_cache',
  '.pytest_cache',
  '.ruff_cache',
  '.venv',
  '__pycache__',
  'build',
  'node_modules',
  'Pods',
};

/// Every file below [directory] whose name ends with one of [extensions],
/// skipping [ignoredDirectoryNames]; sorted by path for stable output.
List<File> filesBelow(Directory directory, Set<String> extensions) {
  if (!directory.existsSync()) return const [];
  final files = <File>[];
  void walk(Directory dir) {
    final entries = dir.listSync(followLinks: false)
      ..sort((a, b) => a.path.compareTo(b.path));
    for (final entry in entries) {
      final name = p.basename(entry.path);
      if (entry is Directory && !ignoredDirectoryNames.contains(name)) {
        walk(entry);
      } else if (entry is File && extensions.contains(p.extension(name))) {
        files.add(entry);
      }
    }
  }

  walk(directory);
  return files;
}

/// [file]'s path relative to [root], with forward slashes.
String relativePath(FileSystemEntity file, Directory root) =>
    p.split(p.relative(file.path, from: root.path)).join('/');

/// A URI referenced by an import, export or part directive.
typedef DirectiveUri = ({String uri, int line});

/// URIs of every import, export and part directive in [file], including
/// conditional-import configurations.
List<DirectiveUri> readDirectiveUris(File file) {
  final result = parseString(
    content: file.readAsStringSync(),
    throwIfDiagnostics: false,
  );
  final uris = <DirectiveUri>[];
  for (final directive in result.unit.directives) {
    if (directive is! UriBasedDirective) continue;
    final line = result.lineInfo.getLocation(directive.offset).lineNumber;
    final candidates = [
      directive.uri.stringValue,
      if (directive is NamespaceDirective)
        for (final configuration in directive.configurations)
          configuration.uri.stringValue,
    ];
    for (final uri in candidates) {
      if (uri != null) uris.add((uri: uri, line: line));
    }
  }
  return uris;
}
